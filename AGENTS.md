# AGENTS.md — Regras para agentes de IA

Este arquivo é o contrato entre o projeto e qualquer agente de IA (Claude Code,
Copilot, Cursor, Codex…). Mantenha-o **curto, objetivo e atualizado**.

## Projeto

- **Nome:** {{PROJECT_NAME}}
- **Objetivo:** {{ONE_LINE_DESCRIPTION}}
- **Stack:** {{STACK}} <!-- preenchido na branch lang/<stack> -->
- **Arquitetura:** monólito modular, hexagonal (ports & adapters). Ver `docs/architecture/`.

## Comandos

Use sempre o `Makefile` (nunca invente comandos):

- `make lint` · `make format` · `make test` · `make security` · `make check`

Antes de considerar uma tarefa pronta: **`make check` deve passar.**

## Regras de arquitetura (obrigatórias)

- Dependências apontam **para dentro**: `interfaces → application → domain`;
  `infrastructure` implementa portas definidas em `domain`/`application`.
- `domain` **não** importa framework, ORM, HTTP, SDK de nuvem ou I/O.
- Organize por **módulo de negócio** (feature) primeiro, camada depois. Ver
  `docs/standards/estrutura-de-pastas.md`.
- Um módulo não acessa internals de outro: só sua API pública.

## Regras de código

- Siga `docs/standards/codigo.md`. Nomes claros > comentários.
- Funções pequenas, uma responsabilidade. Sem código morto ou comentado.
- Erros: nunca engolir exceção; logar com contexto; retornar erros tipados.
- Toda mudança de comportamento vem com teste (`docs/standards/testes.md`).
- Não adicione dependências sem justificar (licença, manutenção, tamanho).

## Segurança (não negociável)

- Nunca commitar segredos; usar variáveis de ambiente (`.env.example` documenta).
- Validar toda entrada externa na borda; queries sempre parametrizadas.
- Não logar dados sensíveis (senhas, tokens, PII).
- Ver `docs/standards/seguranca.md`.

## Fluxo

- Commits: Conventional Commits (`feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`…).
- Decisão arquitetural nova → criar ADR em `docs/architecture/adr/`.
- Mudança visível ao usuário → atualizar `CHANGELOG.md` (seção *Unreleased*).
- Em dúvida sobre requisito ou decisão de negócio: **pergunte, não suponha.**
