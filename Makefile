# Interface ÚNICA de comandos para todos os projetos.
# Na branch lang/<stack>, substitua os alvos marcados com "TODO(lang)".
# Regra: a CI chama os mesmos alvos que você roda localmente.

SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory

IMAGE ?= {{PROJECT_SLUG}}
TAG   ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo dev)

.PHONY: help setup lint format test security build run check clean

help: ## Lista os comandos disponíveis
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

setup: ## Prepara o ambiente local (git hooks + dependências)
	@command -v pre-commit >/dev/null || { echo "Instale o pre-commit: pipx install pre-commit"; exit 1; }
	pre-commit install
	@[ -f .env ] || cp .env.example .env
	@echo "TODO(lang): instalar dependências da stack"

lint: ## Lint e checagem de formatação
	SKIP=no-commit-to-branch pre-commit run --all-files
	@echo "TODO(lang): linter + type checker da stack"

format: ## Formata o código
	@echo "TODO(lang): formatter da stack"

test: ## Executa testes com cobertura
	@echo "TODO(lang): executar testes com cobertura"

security: ## Segredos, vulnerabilidades em dependências e IaC
	@command -v gitleaks >/dev/null && gitleaks git --redact . || echo "gitleaks não instalado (a CI executa)"
	@command -v trivy >/dev/null && trivy fs --scanners vuln,secret,misconfig --severity HIGH,CRITICAL --exit-code 1 . \
		|| echo "trivy não instalado (a CI executa)"

build: ## Gera artefato / imagem
	@if [ -f Dockerfile ]; then docker build -t $(IMAGE):$(TAG) .; else echo "TODO(lang): build da stack"; fi

run: ## Executa localmente
	@echo "TODO(lang): executar a aplicação"

check: lint test security ## Tudo que a CI valida

clean: ## Remove artefatos gerados
	rm -rf dist build out coverage reports tmp
