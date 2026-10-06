#!/usr/bin/env bash
# PostToolUse (Write|Edit): formata o código depois que a IA edita arquivos.
# Fica inativo enquanto o alvo `make format` não estiver implementado (branch lang/<stack>).
set -uo pipefail

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
grep -q 'call todo,formatter' Makefile 2>/dev/null && exit 0
make -s format >/dev/null 2>&1 || echo "make format falhou; rode-o manualmente para ver o erro." >&2
exit 0
