# Como contribuir

## Fluxo de trabalho (trunk-based)

1. Crie/pegue uma issue.
2. Branch curta a partir de `main`: `<tipo>/<issue>-<descricao-curta>`
   (ex.: `feat/42-cadastro-usuario`, `fix/57-timeout-login`).
3. Commits seguindo [Conventional Commits](https://www.conventionalcommits.org/pt-br/).
4. `make check` local passando.
5. Abra PR pequeno (ideal < 400 linhas) usando o template.
6. CI verde + 1 aprovação → *squash merge*. Branch apagada após merge.

Detalhes: [docs/standards/git.md](docs/standards/git.md).

## Definition of Done

Uma tarefa só está pronta quando:

- [ ] Critérios de aceite da issue atendidos
- [ ] Testes novos/ajustados; cobertura não caiu
- [ ] `make check` passa (lint, testes, segurança)
- [ ] Sem segredos, sem `TODO` sem issue vinculada
- [ ] Logs/métricas adequados para operar a feature
- [ ] Docs atualizadas (README, ADR, OpenAPI, CHANGELOG) quando aplicável
- [ ] Revisado por outra pessoa (ou pela IA com `docs/prompts/04-review.md` + você)

## Padrões

Leia [docs/standards/](docs/standards/) antes do primeiro PR.
