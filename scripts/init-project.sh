#!/usr/bin/env bash
# Inicializa um projeto novo a partir do template:
#   - substitui os {{PLACEHOLDERS}} em todos os arquivos versionáveis
#   - remove a seção "Sobre este template" do README
#   - opcionalmente reinicia o histórico git (projeto novo, sem histórico do template)
set -euo pipefail

cd "$(dirname "$0")/.."

ask() { # ask <var> <pergunta> [padrão]
  local answer
  read -r -p "$2${3:+ [$3]}: " answer
  printf -v "$1" '%s' "${answer:-${3:-}}"
  [[ -n "${!1}" ]] || { echo "Valor obrigatório." >&2; exit 1; }
}

# Escapa o valor para uso no lado direito do sed (delimitador |)
escape() { printf '%s' "$1" | sed -e 's/[\\|&]/\\&/g'; }

ask PROJECT_NAME "Nome do projeto"
default_slug=$(printf '%s' "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-|-$//g')
ask PROJECT_SLUG "Slug (repositório/imagem)" "$default_slug"
ask ONE_LINE_DESCRIPTION "Descrição em uma linha"
ask GITHUB_OWNER "Usuário/organização no GitHub"
ask STACK "Stack principal (ex.: Python/FastAPI, Node/NestJS, Go)" "a definir"
ask LICENSE "Licença (MIT, Apache-2.0, Proprietária…)" "MIT"
ask SECURITY_CONTACT "E-mail para reporte de vulnerabilidades"

vars=(PROJECT_NAME PROJECT_SLUG ONE_LINE_DESCRIPTION GITHUB_OWNER STACK LICENSE SECURITY_CONTACT)
sed_args=()
for v in "${vars[@]}"; do
  sed_args+=(-e "s|{{$v}}|$(escape "${!v}")|g")
done

# Arquivos de texto do projeto (exclui .git e este script)
mapfile -d '' files < <(find . -type f -not -path './.git/*' -not -name 'init-project.sh' -print0)
for f in "${files[@]}"; do
  grep -Iq . "$f" 2>/dev/null || continue # pula binários e vazios
  sed -i "${sed_args[@]}" "$f"
done

# Remove o bloco explicativo do template no README
sed -i '/<!-- template:start -->/,/<!-- template:end -->/d' README.md

echo
echo "Placeholders substituídos."
if grep -rIn --exclude-dir=.git --exclude=init-project.sh -E '\{\{[A-Z_]+\}\}' . ; then
  echo "⚠ Ainda há placeholders acima — revise manualmente."
fi

read -r -p "Reiniciar o histórico git (apaga .git do template)? [s/N]: " reset_git
if [[ "${reset_git,,}" == "s" ]]; then
  rm -rf .git
  git init -b main -q
  echo "Novo repositório git criado na branch main."
fi

cat <<EOF

Próximos passos:
  1. Adicione o arquivo LICENSE ($LICENSE) — https://choosealicense.com
  2. make setup
  3. Siga docs/00-comece-aqui.md (Fase 1 — Descoberta)
  4. Opcional: apague scripts/init-project.sh
EOF
