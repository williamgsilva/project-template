# Git, branches, commits e versões

## Branches — trunk-based development

- `main` é sempre **implantável** e protegida.
- Branches de trabalho curtas (horas a poucos dias): `<tipo>/<issue>-<descricao>`
  - `feat/42-login-sso`, `fix/57-timeout-pagamento`, `chore/update-deps`
- Integre cedo: features incompletas atrás de **feature flag**, não em branch longa.
- Merge via PR com **squash** → histórico linear, 1 commit por PR.

### Proteção da `main` (configurar no GitHub)

- Require pull request + 1 aprovação (+ Code Owners)
- Require status checks: `Lint`, `Test`, `Build`, `Secrets`, `trivy`
- Require linear history · Block force pushes · Require conversation resolution
- Habilitar: *Secret scanning*, *Push protection*, *Dependabot alerts*, *Private vulnerability reporting*

## Commits — [Conventional Commits](https://www.conventionalcommits.org/pt-br/)

```text
<tipo>(<escopo opcional>): <descrição no imperativo, minúscula, sem ponto>

[corpo opcional: o porquê da mudança]

[rodapé opcional: Closes #42 / BREAKING CHANGE: ...]
```

| Tipo       | Uso                                         | Versão |
| ---------- | ------------------------------------------- | ------ |
| `feat`     | nova funcionalidade                          | MINOR  |
| `fix`      | correção de bug                              | PATCH  |
| `perf`     | melhoria de performance                      | PATCH  |
| `refactor` | mudança sem alterar comportamento            | —      |
| `test`     | testes                                       | —      |
| `docs`     | documentação                                 | —      |
| `build`    | build, dependências                          | —      |
| `ci`       | pipelines                                    | —      |
| `chore`    | manutenção geral                             | —      |
| `feat!` / `BREAKING CHANGE:` | quebra de compatibilidade  | MAJOR  |

Validado automaticamente pelo hook `commit-msg` (pre-commit).

## Versionamento — [SemVer](https://semver.org/lang/pt-BR/)

`MAJOR.MINOR.PATCH`. Tags `vX.Y.Z` na `main`. A versão e o CHANGELOG podem ser
automatizados com [release-please](https://github.com/googleapis/release-please)
ou [semantic-release](https://semantic-release.gitbook.io) a partir dos commits.

## Template e branches de linguagem

- `main` (template genérico) → `lang/<stack>` (herda via merge).
- Melhoria genérica: PR na `main`, depois `git checkout lang/x && git merge main`.
- Melhoria específica da stack: PR direto na `lang/<stack>`.
