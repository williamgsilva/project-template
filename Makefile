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

.PHONY: help setup lint format test security sbom build _build-todo run check check-rapido clean

help: ## Lista os comandos disponíveis
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-13s\033[0m %s\n", $$1, $$2}'

setup: ## Prepara o ambiente local (git hooks + dependências)
	@command -v pre-commit >/dev/null || { echo "Instale o pre-commit: pipx install pre-commit"; exit 1; }
	pre-commit install
	@[ -f .env ] || cp .env.example .env
	$(call todo,instalar dependências da stack) # TODO(lang)

lint: ## Lint e checagem de formatação (todos os arquivos) + testes dos hooks da IA
	@command -v pre-commit >/dev/null || { echo "Instale o pre-commit: pipx install pre-commit"; exit 1; }
	SKIP=no-commit-to-branch pre-commit run --all-files
	@scripts/test-hooks.sh
	$(call todo,linter + type checker da stack) # TODO(lang)

format: ## Formata o código (FILES="a b" para formatar só esses arquivos)
	$(call todo,formatter da stack) # TODO(lang)

test: ## Executa testes com cobertura
	$(call todo,executar testes com cobertura) # TODO(lang)

security: ## Segredos (histórico git), vulnerabilidades, misconfig e licenças (falha se encontrar algo)
	@if command -v gitleaks >/dev/null; then gitleaks git --redact .; \
		else $(MAKE) -s _skip MSG="varredura de segredos (gitleaks não instalado)"; fi
	@if command -v trivy >/dev/null; then \
		trivy fs --scanners vuln,secret,misconfig,license --severity HIGH,CRITICAL --exit-code 1 .; \
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
	$(call todo,build da stack) # TODO(lang)

run: ## Executa localmente
	$(call todo,executar a aplicação) # TODO(lang)

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
		git ls-files --others --exclude-standard 2>/dev/null; } | sort -u); \
	if [ -n "$$files" ]; then SKIP=no-commit-to-branch pre-commit run --files $$files; \
	else echo "Nenhum arquivo alterado."; fi
	@$(MAKE) test

clean: ## Remove artefatos gerados
	rm -rf dist build out coverage reports tmp
