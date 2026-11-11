"""Stages function sources into the layout Terraform deploys, so imports resolve as in the cloud."""
import shutil
import sys
import tempfile
from pathlib import Path

FUNCTIONS = Path(__file__).resolve().parent.parent / "functions"
STAGING = Path(tempfile.mkdtemp(prefix="ade-notifier-staging-"))


def _stage():
    azure = STAGING / "azure"
    (azure / "shared").mkdir(parents=True)
    shutil.copy(FUNCTIONS / "azure/shared/azure_handler.py", azure / "shared")
    shutil.copy(FUNCTIONS / "common/notifier_common.py", azure / "shared")
    (azure / "shared/__init__.py").touch()
    for name in ("notify", "queue_file"):
        shutil.copy(FUNCTIONS / f"azure/{name}/{name}.py", azure)

    gcp = STAGING / "gcp"
    (gcp / "common").mkdir(parents=True)
    shutil.copy(FUNCTIONS / "gcp/main.py", gcp)
    shutil.copy(FUNCTIONS / "gcp/gcp_handler.py", gcp)
    shutil.copy(FUNCTIONS / "common/notifier_common.py", gcp / "common")
    (gcp / "common/__init__.py").touch()

    sys.path[:0] = [str(azure), str(gcp)]


_stage()


def pytest_sessionfinish(session, exitstatus):
    shutil.rmtree(STAGING, ignore_errors=True)
