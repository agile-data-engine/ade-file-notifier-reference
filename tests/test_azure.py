import base64
import copy
import json
from unittest.mock import MagicMock, patch

import pytest

func = pytest.importorskip("azure.functions")

from shared import azure_handler as ah  # noqa: E402
import notify as notify_mod  # noqa: E402
import queue_file as queue_file_mod  # noqa: E402

CONFIG = [{
    "id": "sys/ent",
    "attributes": {"ade_source_system": "sys", "ade_source_entity": "ent",
                   "folder_path": "raw/sys/ent/", "max_files_per_manifest": 10},
    "manifest_parameters": {},
}]
BLOB_URL = "https://acct.blob.core.windows.net/raw/sys/ent/f.csv"


@pytest.fixture(autouse=True)
def no_sleep():
    with patch.object(ah.time, "sleep"):
        yield


@pytest.fixture
def handler():
    with patch.object(ah, "BlobServiceClient"), patch.object(ah, "DefaultAzureCredential"):
        yield ah.AzureFileHandler("container", "queued/", max_retries=2)


def blob_with_text(text):
    blob = MagicMock()
    blob.download_blob.return_value.readall.return_value = text.encode()
    return blob


def queue_message(payload):
    return func.QueueMessage(body=json.dumps(payload).encode())


def test_list_files(handler):
    handler.container_client.list_blobs.return_value = [MagicMock(), MagicMock()]
    for b, name in zip(handler.container_client.list_blobs.return_value, ("a.json", "b.yaml")):
        b.name = name
    assert handler.list_files_in_folder() == ["a.json", "b.yaml"]
    handler.container_client.list_blobs.assert_called_once_with(name_starts_with="queued/")


def test_download_parses_by_extension(handler):
    handler.container_client.get_blob_client.side_effect = [
        blob_with_text('{"a": 1}'), blob_with_text("b: 2\n"), blob_with_text("hi")]
    assert handler.download_file("x.json") == {"a": 1}
    assert handler.download_file("x.yml") == {"b": 2}
    assert handler.download_file("x.txt") is None


def test_download_retries_then_raises(handler):
    blob = MagicMock()
    blob.download_blob.side_effect = IOError("net")
    handler.container_client.get_blob_client.return_value = blob
    with pytest.raises(RuntimeError):
        handler.download_file("x.json")
    assert blob.download_blob.call_count == 2


def test_move_file_copies_then_deletes(handler):
    src, dst = MagicMock(url="https://src"), MagicMock()
    handler.container_client.get_blob_client.side_effect = [src, dst]
    with patch.object(ah, "datetime") as dt:
        dt.now.return_value.strftime.return_value = "2026/11/11/09"
        handler.move_file("queued/sys/ent/2026/11/10/08/f.json")
    handler.container_client.get_blob_client.assert_any_call("processed/sys/ent/2026/11/11/09/f.json")
    dst.start_copy_from_url.assert_called_once_with("https://src")
    src.delete_blob.assert_called_once()


def test_move_file_keeps_source_on_copy_error(handler):
    src, dst = MagicMock(url="u"), MagicMock()
    dst.start_copy_from_url.side_effect = RuntimeError("copy failed")
    handler.container_client.get_blob_client.side_effect = [src, dst]
    with pytest.raises(RuntimeError):
        handler.move_file("queued/s/e/f.json")
    src.delete_blob.assert_not_called()


def test_upload(handler):
    blob = MagicMock()
    handler.container_client.get_blob_client.return_value = blob
    assert handler.upload_file("p.json", "{}") is True
    assert blob.upload_blob.call_args.kwargs["content_settings"].content_type == "application/json"

    blob.upload_blob.side_effect = IOError("net")
    with pytest.raises(RuntimeError):
        handler.upload_file("p.json", "{}")


def test_download_config_translates():
    yaml_data = [{"source_systems": [{"ade_source_system": "s", "entities": [
        {"ade_source_entity": "e", "file_location": "x/"}]}]}]
    with patch.object(ah, "AzureFileHandler") as cls:
        cls.return_value.download_and_load_yaml_files.return_value = yaml_data
        assert ah.download_config("c", "config/")[0]["id"] == "s/e"


class TestQueueFile:
    @pytest.fixture(autouse=True)
    def env(self, monkeypatch):
        monkeypatch.setenv("container_name", "c")
        monkeypatch.setenv("config_prefix", "config/")
        monkeypatch.setenv("AzureWebJobsStorage__queueServiceUri", "https://acct.queue.core.windows.net")
        monkeypatch.setenv("notify_queue", "notify")

    @pytest.fixture
    def config(self):
        return copy.deepcopy(CONFIG)

    @pytest.fixture
    def file_handler(self, config):
        with patch.object(queue_file_mod, "download_config", return_value=config), \
             patch.object(queue_file_mod, "AzureFileHandler") as cls:
            cls.return_value.upload_file.return_value = True
            yield cls

    @pytest.mark.parametrize("key", ["blobUrl", "url"])
    def test_queues_identified_file(self, file_handler, key):
        queue_file_mod.queue_file(queue_message({"data": {key: BLOB_URL}}))
        path, body = file_handler.return_value.upload_file.call_args.args
        assert path.startswith("queued/sys/ent/") and path.endswith("/f.csv.json")
        assert json.loads(body)["full_file_path"].endswith("raw/sys/ent/f.csv")

    def test_unidentified_source_ignored(self, file_handler):
        queue_file_mod.queue_file(queue_message({"data": {"blobUrl": BLOB_URL.replace("sys/ent", "x/y")}}))
        file_handler.assert_not_called()

    def test_single_file_manifest_sends_queue_message(self, config, file_handler):
        config[0]["attributes"]["single_file_manifest"] = True
        with patch.object(queue_file_mod, "DefaultAzureCredential"), \
             patch.object(queue_file_mod, "QueueClient") as qc:
            queue_file_mod.queue_file(queue_message({"data": {"blobUrl": BLOB_URL}}))
        sent = qc.return_value.send_message.call_args.args[0]
        assert json.loads(base64.b64decode(sent)) == {"calls": [["sys", "ent"]]}


def test_notify(monkeypatch):
    for k, v in {"container_name": "c", "config_prefix": "config/", "key_vault_uri": "https://kv",
                 "notify_api_base_url": "https://notify", "external_api_base_url": "https://ext"}.items():
        monkeypatch.setenv(k, v)
    with patch.object(notify_mod, "DefaultAzureCredential"), \
         patch.object(notify_mod, "SecretClient") as sc, \
         patch.object(notify_mod, "download_config", return_value=CONFIG), \
         patch.object(notify_mod, "AzureFileHandler") as cls, \
         patch.object(notify_mod, "manifest_handler", return_value=[{"manifest_id": "m"}]) as mh, \
         patch.object(notify_mod, "upload_notifier_status") as up, \
         patch.object(notify_mod, "dag_trigger_handler") as dag:
        sc.return_value.get_secret.return_value.value = "secret"
        cls.return_value.download_and_list_files.return_value = (
            [{"full_file_path": BLOB_URL}], ["queued/sys/ent/f.json"])
        notify_mod.notify(queue_message({"calls": [["sys", "ent"]]}))
    assert mh.call_args.args[2]["api_key"] == "secret"
    assert mh.call_args.args[3] == 10
    cls.return_value.move_files_to_processed.assert_called_once_with(["queued/sys/ent/f.json"])
    up.assert_called_once()
    dag.assert_called_once()
