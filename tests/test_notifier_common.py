from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest
import requests
import yaml
from adenotifier import notifier

from shared import notifier_common as nc

CONFIG_DIR = Path(__file__).resolve().parent.parent / "config"


def load_example(name):
    return [yaml.safe_load((CONFIG_DIR / name).read_text())]


@pytest.fixture
def config():
    return nc.translate_dict(load_example("example_1.yaml"))


@pytest.mark.parametrize("name", ["example_1.yaml", "example_2.yaml"])
def test_example_configs_translate(name):
    assert nc.translate_dict(load_example(name))


def test_translate_entity_overrides_system(config):
    params = {c["id"]: c["manifest_parameters"] for c in config}
    assert params["digitraffic/metadata_vessels_test"]["format"] == "JSON"
    assert "delim" not in params["digitraffic/metadata_vessels_test"]
    assert params["digitraffic/locations_latest_test"]["format"] == "CSV"
    assert params["digitraffic/locations_latest_test"]["delim"] == "PIPE"


@pytest.mark.parametrize("bad", [[None], [{}], [{"source_systems": None}]])
def test_translate_invalid_input(bad):
    with pytest.raises(ValueError):
        nc.translate_dict(bad)


@pytest.mark.parametrize("path, expected", [
    ("digitraffic/metadata_vessels/batch.1.json", ["digitraffic/metadata_vessels_test"]),
    ("digitraffic/metadata_vessels/data.csv", ["digitraffic/locations_latest_test"]),
    ("barentswatch/latest_combined/f.csv", ["barentswatch/latest_combined_test"]),
    ("other/f.csv", []),
])
def test_identify_sources(config, path, expected):
    url = f"https://acct.blob.core.windows.net/raw/{path}"
    assert [s["id"] for s in nc.identify_sources(url, config)] == expected


def test_get_matching_configs(config):
    assert len(nc.get_matching_configs(config, "digitraffic", "")) == 2
    assert [c["id"] for c in nc.get_matching_configs(config, "digitraffic", "locations_latest_test")] \
        == ["digitraffic/locations_latest_test"]


def test_manifest_handler_splits_entries():
    entries = [{"sourceFile": f"f{i}"} for i in range(5)]
    secrets = {"base_url": "https://api", "api_key": "k", "api_key_secret": "s"}
    with patch.object(nc.notifier, "add_multiple_entries_to_manifest",
                      side_effect=[MagicMock(id=f"m{i}") for i in range(3)]):
        result = nc.manifest_handler({"id": "x"}, entries, secrets, 2)
    assert [(m["manifest_id"], m["entry_amount"]) for m in result] == [("m0", 2), ("m1", 2), ("m2", 1)]


def test_dag_trigger_handler_triggers_each_dag_once():
    status = [{"config": {"attributes": {"dag_trigger": d}}} for d in ("a", "a", "b", None)]
    secrets = {"base_url": "https://ext", "api_key": "k", "api_key_secret": "s"}
    with patch.object(nc, "start_dag_run_v2", return_value={}) as start:
        assert sorted(nc.dag_trigger_handler(status, secrets)) == ["a", "b"]
    assert start.call_count == 2
    assert start.call_args.args[0].headers["X-API-KEY-ID"] == "k"


@pytest.mark.parametrize("code, raises", [(201, False), (401, True), (500, True)])
def test_start_dag_run(code, raises):
    session = MagicMock()
    session.post.return_value = MagicMock(status_code=code, text="{}")
    if raises:
        with pytest.raises(requests.exceptions.HTTPError):
            nc.start_dag_run_v2(session, "https://ext", "dag1")
    else:
        nc.start_dag_run_v2(session, "https://ext", "dag1")
    session.post.assert_called_once_with("https://ext/dagger/v2/dags/dag1/dag-runs")


def test_adenotifier_parses_batch_per_entry():
    # Fails on adenotifier < v0.2.3
    source = {"attributes": {"ade_source_system": "s", "ade_source_entity": "e",
                              "batch_from_file_path_regex": r"batch\.(\d+)\.csv"},
              "manifest_parameters": {"format": "CSV"}}
    entries = [{"sourceFile": "a/batch.1.csv"}, {"sourceFile": "a/batch.2.csv"}]
    with patch.object(notifier, "Manifest"):
        notifier.add_multiple_entries_to_manifest(entries, source, "https://api", "k", "s")
    assert [e["batch"] for e in entries] == [1, 2]
