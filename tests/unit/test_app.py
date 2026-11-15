import logging

import pytest

from app.bootstrap.app import READY_MESSAGE, main


def test_main_sobe_e_avisa_que_esta_pronto(caplog: pytest.LogCaptureFixture) -> None:
    with caplog.at_level(logging.INFO):
        exit_code = main()

    assert exit_code == 0
    assert READY_MESSAGE in caplog.messages
