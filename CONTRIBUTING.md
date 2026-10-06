# Como contribuir

## Fluxo de trabalho (trunk-based)

> Esta é a fonte única do fluxo; os outros documentos apenas apontam para cá.

1. Crie/pegue uma issue com critérios de aceite (formato QUANDO … ENTÃO o sistema DEVE …).
2. Planeje: tarefa pequena → `/planejar` ([06-plano](docs/prompts/06-plano.md));
   feature média/grande → `/spec` ([09-spec](docs/prompts/09-spec.md)).
3. Branch curta a partir de `main`: `<tipo>/<issue>-<descricao-curta>`
   (ex.: `feat/42-cadastro-usuario`, `fix/57-timeout-login`).
4. Commits seguindo [Conventional Commits](https://www.conventionalcommits.org/pt-br/).
5. `make check` local passando, `/verificar` (evidência em execução) e `/revisar`.
6. Abra PR pequeno (ideal < 400 linhas) usando o template.
7. CI verde + 1 aprovação → *squash merge*. Branch apagada após merge.

Detalhes: [docs/standards/git.md](docs/standards/git.md).

## Definition of Done

Uma tarefa só está pronta quando:

- [ ] Critérios de aceite da issue atendidos
- [ ] Testes novos/ajustados; cobertura não caiu
- [ ] Verificado em execução, com evidência no PR (`docs/prompts/07-verificar.md`)
- [ ] `make check` passa (lint, testes, segurança)
- [ ] Sem segredos, sem `TODO` sem issue vinculada
- [ ] Logs/métricas adequados para operar a feature
- [ ] Docs atualizadas (README, ADR, OpenAPI, glossário, runbook) quando aplicável
- [ ] Feature sensível: modelagem de ameaças feita ([threat-model](docs/security/threat-model.md))
- [ ] Mudança de banco segue [expand → contract](docs/standards/dados-e-migracoes.md)
- [ ] Revisado por outra pessoa (ou pela IA com `/revisar` / `docs/prompts/04-review.md` + você)

## Trabalho com IA

Regras para agentes: [AGENTS.md](AGENTS.md). Prompts, skills e plugins recomendados:
[docs/prompts/](docs/prompts/). Loops autônomos só com limites:
[docs/prompts/10-loop-autonomo.md](docs/prompts/10-loop-autonomo.md).

## Padrões

Leia [docs/standards/](docs/standards/) antes do primeiro PR.
