import base64
import copy
import json
from unittest.mock import MagicMock, patch

import pytest

pytest.importorskip("functions_framework")
pytest.importorskip("google.cloud.storage")

import flask  # noqa: E402
from cloudevents.http import CloudEvent  # noqa: E402

import gcp_handler as gh  # noqa: E402

with patch("google.cloud.logging.Client"):
    import main as main_mod  # noqa: E402

CONFIG = [{
    "id": "sys/ent",
    "attributes": {"ade_source_system": "sys", "ade_source_entity": "ent",
                   "folder_path": "sys/ent/", "max_files_per_manifest": 10},
    "manifest_parameters": {},
}]


@pytest.fixture(autouse=True)
def no_sleep():
    with patch.object(gh.time, "sleep"):
        yield


@pytest.fixture
def handler():
    with patch.object(gh.storage, "Client"):
        return gh.GCPFileHandler("bucket", "queued/", max_retries=2)


@pytest.fixture
def env(monkeypatch):
    secret = json.dumps({"base_url": "https://n", "api_key": "k", "api_key_secret": "s"})
    for k, v in {"NOTIFIER_BUCKET": "nb", "CONFIG_PREFIX": "config/", "FILE_URL_PREFIX": "gs://",
                 "NOTIFIER_PUBSUB_TOPIC": "projects/p/topics/t",
                 "NOTIFY_API_SECRET_ID": secret, "EXTERNAL_API_SECRET_ID": secret}.items():
        monkeypatch.setenv(k, v)


def blob(name="x", text=""):
    b = MagicMock()
    b.name = name
    b.download_as_text.return_value = text
    return b


def cloud_event(payload):
    data = base64.b64encode(json.dumps(payload).encode()).decode()
    return CloudEvent({"type": "google.cloud.pubsub.topic.v1.messagePublished", "source": "//pubsub"},
                      {"message": {"data": data}})


def test_list_files(handler):
    handler.bucket.list_blobs.return_value = [blob("a.json"), blob("b.yaml")]
    assert handler.list_files_in_folder() == ["a.json", "b.yaml"]
    handler.bucket.list_blobs.assert_called_once_with(prefix="queued/")


def test_load_yaml_files(handler):
    handler.bucket.list_blobs.return_value = [blob("c/a.yaml"), blob("c/b.json")]
    handler.bucket.blob.side_effect = lambda n: blob(n, "k: v\n")
    assert handler.download_and_load_yaml_files() == [{"k": "v"}]


def test_download_retries_then_none(handler):
    b = blob()
    b.download_as_text.side_effect = IOError("net")
    handler.bucket.blob.return_value = b
    assert handler.download_file("x.json") is None
    assert b.download_as_text.call_count == 2


@pytest.mark.parametrize("copied", [True, False])
def test_move_file_deletes_only_after_copy(handler, copied):
    src = MagicMock()
    handler.bucket.blob.return_value = src
    handler.bucket.copy_blob.return_value.exists.return_value = copied
    handler.move_file("queued/s/e/f.json")
    handler.bucket.copy_blob.assert_called_once_with(src, handler.bucket, "processed/s/e/f.json")
    assert src.delete.called is copied


def test_upload(handler):
    b = MagicMock()
    handler.bucket.blob.return_value = b
    assert handler.upload_file("p.json", "{}") is True
    b.upload_from_string.assert_called_once_with(data="{}", content_type="application/json")

    b.upload_from_string.side_effect = IOError("net")
    assert handler.upload_file("p.json", "{}") is False


def test_publish_message():
    with patch.object(gh.pubsub_v1, "PublisherClient") as pc, patch.object(gh.futures, "wait"):
        pc.return_value.publish.return_value.exception.return_value = None
        gh.GCPubSubHandler("projects/p/topics/t").publish_message({"calls": [["s", "e"]]})
    call = pc.return_value.publish.call_args
    assert call.args[0] == "projects/p/topics/t"
    assert json.loads(call.kwargs["data"]) == {"calls": [["s", "e"]]}


@pytest.mark.usefixtures("env")
class TestFileFoldering:
    @pytest.fixture
    def config(self):
        return copy.deepcopy(CONFIG)

    @pytest.fixture
    def file_handler(self, config):
        with patch.object(main_mod, "download_config", return_value=config), \
             patch.object(main_mod, "GCPFileHandler") as cls:
            cls.return_value.upload_file.return_value = True
            yield cls

    def test_queues_identified_file(self, file_handler):
        main_mod.file_foldering(cloud_event({"bucket": "src", "name": "sys/ent/f.csv"}))
        path, body = file_handler.return_value.upload_file.call_args.args
        assert path.startswith("queued/sys/ent/") and path.endswith("/f.csv.json")
        assert json.loads(body)["full_file_path"] == "gs://src/sys/ent/f.csv"

    @pytest.mark.parametrize("name", ["sys/ent/", "other/f.csv"])
    def test_ignored_events(self, file_handler, name):
        main_mod.file_foldering(cloud_event({"bucket": "src", "name": name}))
        file_handler.assert_not_called()

    def test_single_file_manifest_publishes(self, config, file_handler):
        config[0]["attributes"]["single_file_manifest"] = True
        with patch.object(main_mod, "GCPubSubHandler") as ps:
            main_mod.file_foldering(cloud_event({"bucket": "src", "name": "sys/ent/f.csv"}))
        ps.return_value.publish_message.assert_called_once_with({"calls": [["sys", "ent"]]})


@pytest.mark.usefixtures("env")
@pytest.mark.parametrize("payload, code", [
    ({"calls": [["sys", "ent"]]}, 200),
    ({"nope": []}, 400),
    ({"calls": [[1]]}, 400),
])
def test_process_events(payload, code):
    with flask.Flask("t").app_context(), \
         patch.object(main_mod, "download_config", return_value=CONFIG), \
         patch.object(main_mod, "GCPFileHandler") as cls, \
         patch.object(main_mod, "manifest_handler", return_value=[{"manifest_id": "m"}]) as mh, \
         patch.object(main_mod, "upload_notifier_status"), \
         patch.object(main_mod, "dag_trigger_handler"):
        cls.return_value.download_and_list_files.return_value = (
            [{"full_file_path": "gs://src/sys/ent/f.csv"}], ["queued/sys/ent/f.json"])
        response, status_code = main_mod.process_events(payload)
    assert status_code == code
    if code == 200:
        assert mh.call_args.args[3] == 10
        cls.return_value.move_files_to_processed.assert_called_once_with(["queued/sys/ent/f.json"])


def test_add_to_manifest_decodes_pubsub_event():
    with patch.object(main_mod, "process_events", return_value="ok") as pe:
        assert main_mod.add_to_manifest(cloud_event({"calls": [["s", "e"]]})) == "ok"
    pe.assert_called_once_with({"calls": [["s", "e"]]})
