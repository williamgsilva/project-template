#!/usr/bin/env bash
# PostToolUse (Write|Edit): formata o arquivo que a IA acabou de editar.
# Fica inativo enquanto o alvo `make format` não estiver implementado (branch lang/<stack>).
# Contrato com a stack: `make format FILES="<arquivos>"` formata só esses arquivos
# (sem FILES, formata o projeto inteiro). Assim cada edição custa um arquivo, não o repositório.
set -uo pipefail

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
grep -q 'call todo,formatter' Makefile 2>/dev/null && exit 0

input=$(cat)
if command -v jq >/dev/null 2>&1; then
  file=$(jq -r '.tool_input.file_path // empty' <<<"$input" 2>/dev/null)
else
  file=$(sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' <<<"$input" | head -n 1)
fi
[[ -n "$file" && -f "$file" ]] || exit 0

# Só formata código (docs e configuração não disparam o formatter).
case "$file" in
  *.md | *.json | *.yml | *.yaml | *.txt | */.claude/*) exit 0 ;;
esac
make -s format FILES="$file" >/dev/null 2>&1 || echo "make format falhou para $file; rode-o manualmente para ver o erro." >&2
exit 0
