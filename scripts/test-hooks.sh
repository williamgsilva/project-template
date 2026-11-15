#!/usr/bin/env bash
# Testes de regressão do hook .claude/hooks/protect-secrets.sh.
# Cada linha de tests/hooks/protect-secrets.casos: <B|P>|<comando>
#   B = deve bloquear · P = deve passar
# Uso: scripts/test-hooks.sh (chamado por `make lint`). Requer jq.
set -euo pipefail

cd "$(dirname "$0")/.."
hook=.claude/hooks/protect-secrets.sh
cases=tests/hooks/protect-secrets.casos

command -v jq >/dev/null || { echo "test-hooks: jq não instalado — testes do hook pulados" >&2; exit 0; }

fail=0
total=0
while IFS='|' read -r expected command; do
  [[ -z "$expected" || "$expected" == \#* ]] && continue
  total=$((total + 1))
  if jq -nc --arg c "$command" '{tool_input:{command:$c}}' | bash "$hook" >/dev/null 2>&1; then
    got=P
  else
    got=B
  fi
  if [[ "$got" != "$expected" ]]; then
    echo "FALHOU (esperado $expected, obtido $got): $command" >&2
    fail=$((fail + 1))
  fi
done <"$cases"

echo "test-hooks: $((total - fail))/$total casos ok"
[[ "$fail" -eq 0 ]]
