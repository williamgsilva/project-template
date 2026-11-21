# Interface ÚNICA de comandos para todos os projetos.
# Na branch lang/<stack>, substitua os alvos marcados com "TODO(lang)".
# Regra: a CI chama os mesmos alvos que você roda localmente.

SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

IMAGE ?= {{PROJECT_SLUG}}
TAG   ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo dev)
# Arquivos para `make format` (vazio = projeto inteiro). O hook da IA passa só o arquivo editado.
FILES ?=

# Etapa que NÃO rodou (alvo não implementado ou ferramenta ausente): avisa no terminal, vira
# anotação visível no PR (GitHub Actions) e é registrada para o resumo do `make check`,
# para nada parecer "verificado" sem ter sido.
define skipped
	@if [ -n "$${GITHUB_ACTIONS:-}" ]; then echo "::warning title=NÃO EXECUTADO::$(1)"; \
		else echo "NÃO EXECUTADO: $(1)"; fi
	@echo "$(1)" >> "$${SKIP_LOG:-/dev/null}"
endef
todo = $(call skipped,$(1) — alvo TODO(lang) ainda não implementado)

# --- Stack Python (uv). --locked: falha se o uv.lock estiver desatualizado. ---
UV := uv run --locked
need_uv = @command -v uv >/dev/null || { echo "Instale o uv: https://docs.astral.sh/uv/"; exit 1; }
# Só arquivos Python de FILES (o hook de formatação passa qualquer arquivo editado).
PY_FILES = $(filter %.py %.pyi,$(FILES))

.PHONY: help setup lint lint-stack format test security sbom build _build-todo run check check-rapido clean

help: ## Lista os comandos disponíveis
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-13s\033[0m %s\n", $$1, $$2}'

setup: ## Prepara o ambiente local (git hooks + dependências)
	@command -v pre-commit >/dev/null || { echo "Instale o pre-commit: pipx install pre-commit"; exit 1; }
	pre-commit install
	@[ -f .env ] || cp .env.example .env
	$(need_uv)
	uv sync --locked

lint: ## Lint e checagem de formatação (todos os arquivos) + testes dos hooks da IA
	@command -v pre-commit >/dev/null || { echo "Instale o pre-commit: pipx install pre-commit"; exit 1; }
	SKIP=no-commit-to-branch pre-commit run --all-files
	@scripts/test-hooks.sh
	@$(MAKE) lint-stack

lint-stack: ## Só o lint da stack (ruff, mypy, import-linter) — a CI chama este alvo
	$(need_uv)
	$(UV) ruff check .
	$(UV) ruff format --check .
	$(UV) mypy
	$(UV) lint-imports

format: ## Formata o código (FILES="a b" para formatar só esses arquivos)
	$(need_uv)
ifeq ($(strip $(FILES)),)
	$(UV) ruff check --fix .
	$(UV) ruff format .
else ifneq ($(strip $(PY_FILES)),)
	$(UV) ruff check --fix $(PY_FILES)
	$(UV) ruff format $(PY_FILES)
endif

test: ## Executa testes com cobertura
	$(need_uv)
	$(UV) pytest

security: ## Segredos (histórico git), vulnerabilidades, misconfig e licenças (falha se encontrar algo)
	@if command -v gitleaks >/dev/null; then gitleaks git --redact .; \
		else $(MAKE) -s _skip MSG="varredura de segredos (gitleaks não instalado)"; fi
	@# Varre só o que vai para o git (versionado + novo não ignorado): fora .venv, .env e afins.
	@# A base do trivy é pública: config Docker vazia evita ler (ou exigir) credenciais.
	@if command -v trivy >/dev/null; then \
		tmp=$$(mktemp -d); trap 'rm -rf "$$tmp"' EXIT; mkdir "$$tmp/src" "$$tmp/docker"; \
		git ls-files -z --cached --others --exclude-standard | \
			while IFS= read -r -d '' f; do [ -f "$$f" ] && printf '%s\0' "$$f"; done | \
			tar --null -T - -cf - | tar -xf - -C "$$tmp/src"; \
		DOCKER_CONFIG="$$tmp/docker" trivy fs --no-progress --skip-version-check --disable-telemetry \
			--scanners vuln,secret,misconfig,license --severity HIGH,CRITICAL --exit-code 1 "$$tmp/src"; \
		else $(MAKE) -s _skip MSG="varredura de vulnerabilidades (trivy não instalado)"; fi

_skip:
	$(call skipped,$(MSG))

sbom: ## Gera o SBOM (CycloneDX) em reports/sbom.cdx.json
	@command -v trivy >/dev/null || { echo "Instale o trivy: https://trivy.dev"; exit 1; }
	@mkdir -p reports
	trivy fs --format cyclonedx --output reports/sbom.cdx.json .

build: ## Gera artefato / imagem
	@if [ -f Dockerfile ]; then docker build -t $(IMAGE):$(TAG) .; \
		else $(MAKE) -s _build-todo; fi

_build-todo:
	$(need_uv)
	uv build

run: ## Executa localmente
	$(need_uv)
	$(UV) python -m app

check: ## Tudo que a CI valida; lista o que NÃO rodou (STRICT=1 falha nesse caso)
	@log=$$(mktemp); trap 'rm -f "$$log"' EXIT; \
	SKIP_LOG="$$log" $(MAKE) lint test security; \
	if [ -s "$$log" ]; then \
		echo; echo "RESUMO — etapas NÃO EXECUTADAS (não conte como verificado):"; sed 's/^/  - /' "$$log"; \
		if [ "$${STRICT:-0}" = 1 ]; then echo "STRICT=1: falhando porque há etapas não executadas."; exit 1; fi; \
	else echo; echo "RESUMO — todas as etapas executadas."; fi

check-rapido: ## Para iterações: lint só dos arquivos alterados + testes (antes do PR: make check)
	@command -v pre-commit >/dev/null || { echo "Instale o pre-commit: pipx install pre-commit"; exit 1; }
	@files=$$( { git diff --name-only --diff-filter=d HEAD 2>/dev/null; \
		git diff --name-only --diff-filter=d main...HEAD 2>/dev/null; \
		git ls-files --others --exclude-standard 2>/dev/null; } | sort -u | \
		while IFS= read -r f; do if [ -f "$$f" ]; then printf '%s\n' "$$f"; fi; done); \
	if [ -n "$$files" ]; then SKIP=no-commit-to-branch pre-commit run --files $$files; \
	else echo "Nenhum arquivo alterado."; fi; \
	py=$$(printf '%s\n' $$files | grep -E '\.pyi?$$' || true); \
	if [ -n "$$py" ]; then $(UV) ruff check $$py && $(UV) ruff format --check $$py; fi
	@$(MAKE) test

clean: ## Remove artefatos gerados
	rm -rf dist build out coverage reports tmp .pytest_cache .mypy_cache .ruff_cache .coverage
