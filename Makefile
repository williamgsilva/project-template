# Interface ÚNICA de comandos para todos os projetos.
# Na branch lang/<stack>, substitua os alvos marcados com "TODO(lang)".
# Regra: a CI chama os mesmos alvos que você roda localmente.

SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

IMAGE ?= {{PROJECT_SLUG}}
TAG   ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo dev)

# Alvo ainda não implementado: avisa no terminal e vira anotação visível no PR (GitHub Actions),
# para a CI não parecer "verde testando algo" quando nada foi testado.
define todo
	@if [ -n "$${GITHUB_ACTIONS:-}" ]; then echo "::warning title=TODO(lang)::$(1) — alvo ainda não implementado"; \
		else echo "TODO(lang): $(1)"; fi
endef

.PHONY: help setup lint format test security sbom build _build-todo run check clean

help: ## Lista os comandos disponíveis
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

setup: ## Prepara o ambiente local (git hooks + dependências)
	@command -v pre-commit >/dev/null || { echo "Instale o pre-commit: pipx install pre-commit"; exit 1; }
	pre-commit install
	@[ -f .env ] || cp .env.example .env
	$(call todo,instalar dependências da stack) # TODO(lang)

lint: ## Lint e checagem de formatação
	@command -v pre-commit >/dev/null || { echo "Instale o pre-commit: pipx install pre-commit"; exit 1; }
	SKIP=no-commit-to-branch pre-commit run --all-files
	$(call todo,linter + type checker da stack) # TODO(lang)

format: ## Formata o código
	$(call todo,formatter da stack) # TODO(lang)

test: ## Executa testes com cobertura
	$(call todo,executar testes com cobertura) # TODO(lang)

security: ## Segredos, vulnerabilidades, misconfig e licenças (falha se encontrar algo)
	@if command -v gitleaks >/dev/null; then gitleaks git --redact .; \
		else echo "AVISO: gitleaks não instalado — varredura de segredos só na CI"; fi
	@if command -v trivy >/dev/null; then \
		trivy fs --scanners vuln,secret,misconfig,license --severity HIGH,CRITICAL --exit-code 1 .; \
		else echo "AVISO: trivy não instalado — varredura de vulnerabilidades só na CI"; fi

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

check: lint test security ## Tudo que a CI valida

clean: ## Remove artefatos gerados
	rm -rf dist build out coverage reports tmp
