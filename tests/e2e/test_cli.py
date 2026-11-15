import subprocess
import sys

from app.bootstrap.app import READY_MESSAGE


def test_python_m_app_sobe_e_sai_com_sucesso() -> None:
    result = subprocess.run(
        [sys.executable, "-m", "app"],
        capture_output=True,
        text=True,
        timeout=30,
        check=False,
    )

    assert result.returncode == 0, result.stderr
    assert READY_MESSAGE in result.stderr
