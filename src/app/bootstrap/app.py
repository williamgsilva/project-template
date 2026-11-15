"""Ponto de entrada da aplicação."""

import logging

logger = logging.getLogger(__name__)

READY_MESSAGE = "{{PROJECT_NAME}} pronto."


def main() -> int:
    """Sobe a aplicação e devolve o código de saída do processo."""
    logging.basicConfig(level=logging.INFO, format="%(levelname)s %(name)s: %(message)s")
    logger.info(READY_MESSAGE)
    return 0
