#!/usr/bin/env bash
# PreToolUse (Bash): bloqueia comandos de shell que citam segredos.
# É a 3ª camada: as regras Read()/Edit() do settings.json já valem para cat/head/tail/sed/tee
# e redirecionamentos, e o sandbox nega leitura das pastas de credenciais. Este hook cobre o
# que elas não alcançam (ex.: `source .env`, globs como `.env*`) e funciona sem sandbox.
# Limite: é baseado em texto — código que monta o caminho em tempo de execução escapa.
# Entrada: JSON do Claude Code no stdin. Saída 2 = bloqueia, com o motivo no stderr.
set -euo pipefail

input=$(cat)
# Lê o comando sem o escape do JSON (sem jq, desfaz ao menos as aspas escapadas).
if command -v jq >/dev/null 2>&1; then
  cmd=$(jq -r '.tool_input.command // empty' <<<"$input" 2>/dev/null || printf '%s' "$input")
else
  cmd=${input//\\\"/\"}
fi

# Modelos de variáveis são documentação e podem ser lidos.
cmd=${cmd//.env.example/}
cmd=${cmd//.env.sample/}
cmd=${cmd//.env.template/}

start='(^|[[:space:]/"'\''=:<(])'
end='([[:space:]"'\'';|&>)]|$)'

patterns=(
  # .env, .env.local, .env.<ambiente>, também com glob (.env*)
  "${start}\.env(\.[[:alnum:]_.-]+)?[*?]*${end}"
  # globs que podem casar com .env (.en?, .e*)
  "${start}\.e[[:alnum:]_.-]*[*?[]"
  # diretório secrets/
  "${start}secrets/"
  # arquivos de chave/certificado com nome (server.key, certs/tls.pem) — não casa `jq '.key'`
  "${start}[[:alnum:]_-][[:alnum:]_.-]*\.(pem|key|p12|pfx)${end}"
  "${start}id_(rsa|ecdsa|ed25519)"
  # credenciais na pasta pessoal
  "(~|\\\$HOME|\\\$\{HOME\}|/home/[^/[:space:]]+|/root)/\.(ssh|aws|gnupg|kube|netrc|npmrc|pypirc|git-credentials|azure)"
  "(~|\\\$HOME|\\\$\{HOME\}|/home/[^/[:space:]]+|/root)/\.config/(gh|gcloud)"
  "(~|\\\$HOME|\\\$\{HOME\}|/home/[^/[:space:]]+|/root)/\.docker/config\.json"
  "(~|\\\$HOME|\\\$\{HOME\}|/home/[^/[:space:]]+|/root)/\.claude/\.credentials\.json"
)

for p in "${patterns[@]}"; do
  if grep -Eq -- "$p" <<<"$cmd"; then
    echo "Bloqueado por .claude/hooks/protect-secrets.sh: o comando cita .env, secrets/, chave privada ou credenciais da pasta pessoal. Use .env.example para ver as variáveis." >&2
    exit 2
  fi
done
exit 0
