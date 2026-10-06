#!/usr/bin/env bash
# Inicializa um projeto novo a partir do template:
#   - substitui os {{PLACEHOLDERS}} em todos os arquivos de texto
#   - remove a seção "Sobre este template" do README
#   - opcionalmente reinicia o histórico git, mantendo o template como remote "template"
#     (para receber melhorias depois — ver docs/atualizar-do-template.md)
# Portável: bash 3.2+ (macOS) e GNU/BSD sed/grep/find.
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

# sed "in-place" portável (GNU e BSD têm sintaxes diferentes de -i).
# Reescreve o conteúdo no mesmo arquivo, preservando permissões.
sed_inplace() { # sed_inplace <arquivo> <args do sed...>
  local file=$1 tmp
  shift
  tmp=$(mktemp)
  sed "$@" "$file" >"$tmp"
  cat "$tmp" >"$file"
  rm -f "$tmp"
}

ask PROJECT_NAME "Nome do projeto"
default_slug=$(printf '%s' "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-|-$//g')
ask PROJECT_SLUG "Slug (repositório/imagem)" "$default_slug"
ask ONE_LINE_DESCRIPTION "Descrição em uma linha"
ask GITHUB_OWNER "Usuário/organização no GitHub"
ask STACK "Stack principal (ex.: Python/FastAPI, Node/NestJS, Go)" "a definir"
ask LICENSE "Licença (MIT, Apache-2.0, Proprietária…)" "MIT"
ask SECURITY_CONTACT "E-mail para reporte de vulnerabilidades"

sed_args=()
for v in PROJECT_NAME PROJECT_SLUG ONE_LINE_DESCRIPTION GITHUB_OWNER STACK LICENSE SECURITY_CONTACT; do
  sed_args+=(-e "s|{{$v}}|$(escape "${!v}")|g")
done

# Arquivos de texto do projeto (exclui .git e este script); binários e vazios são pulados.
while IFS= read -r -d '' f; do
  grep -Iq . "$f" 2>/dev/null || continue
  sed_inplace "$f" "${sed_args[@]}"
done < <(find . -type f -not -path './.git/*' -not -name 'init-project.sh' -print0)

# Remove o bloco explicativo do template no README e colapsa linhas em branco duplicadas
sed_inplace README.md '/<!-- template:start -->/,/<!-- template:end -->/d'
sed_inplace README.md -e '/./,/^$/!d'

echo
echo "Placeholders substituídos."
if grep -rIn --exclude-dir=.git --exclude=init-project.sh -E '\{\{[A-Z_]+\}\}' .; then
  echo "AVISO: ainda há placeholders acima — revise manualmente."
fi

template_url=$(git remote get-url origin 2>/dev/null || true)
read -r -p "Reiniciar o histórico git (apaga .git do template)? [s/N]: " reset_git
reset_git=$(printf '%s' "$reset_git" | tr '[:upper:]' '[:lower:]')
if [[ "$reset_git" == "s" ]]; then
  rm -rf .git
  git init -q
  git symbolic-ref HEAD refs/heads/main
  echo "Novo repositório git criado na branch main."
  if [[ -n "$template_url" ]]; then
    git remote add template "$template_url"
    echo "Remote 'template' -> $template_url (para receber atualizações do template)."
  fi
fi

cat <<EOF

Próximos passos:
  1. Adicione o arquivo LICENSE ($LICENSE) — https://choosealicense.com
  2. make setup
  3. Primeiro commit: SKIP=no-commit-to-branch git commit -m "chore: estrutura inicial a partir do template"
  4. Siga a "Configuração inicial obrigatória" do README e docs/00-comece-aqui.md
  5. Opcional: apague scripts/init-project.sh
EOF
