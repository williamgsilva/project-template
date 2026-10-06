# Git, branches, commits e versões

## Branches — trunk-based development

- `main` é sempre **implantável** e protegida.
- Branches de trabalho curtas (horas a poucos dias): `<tipo>/<issue>-<descricao>`
  - `feat/42-login-sso`, `fix/57-timeout-pagamento`, `chore/update-deps`
- Integre cedo: features incompletas atrás de **feature flag**, não em branch longa.
- Merge via PR com **squash** → histórico linear, 1 commit por PR.

### Proteção da `main` (configurar no GitHub)

- Require pull request + 1 aprovação (+ Code Owners)
- Require status checks (nomes dos jobs): `Lint`, `Test`, `Build`, `Secrets`, `Vulnerabilities`, `Workflows`
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

`MAJOR.MINOR.PATCH`. Tags `vX.Y.Z` na `main`. A versão, o `CHANGELOG.md` e a tag são
**automatizados** pelo [release-please](https://github.com/googleapis/release-please)
(`.github/workflows/release.yml`): ele lê os Conventional Commits e mantém um PR de release
aberto; ao fazer merge desse PR, a versão é publicada com SBOM assinado.
**Não edite o CHANGELOG à mão** — escreva bons commits.

## Template e branches de linguagem

- `main` (template genérico) → `lang/<stack>` (herda via merge).
- Melhoria genérica: PR na `main`, depois `git checkout lang/x && git merge main`.
- Melhoria específica da stack: PR direto na `lang/<stack>`.

## Feature flags

Permitem integrar código incompleto na `main` (trunk-based) e separar **deploy** de **release**.

- **Tipos:** *release* (esconder feature em construção — vida curta), *experimento* (A/B),
  *operacional* (kill switch para desligar algo pesado em incidente — vida longa).
- **Padrão desligado** em produção; o código precisa funcionar com a flag ligada **e** desligada
  (teste os dois caminhos).
- **Toda flag de release tem dono e data de remoção**; ao ligar 100%, abra a issue para remover
  a flag e o código morto. Flags esquecidas viram dívida técnica e risco.
- Comece simples (configuração/variável de ambiente); use um serviço (Unleash, Flagsmith,
  OpenFeature como padrão aberto) quando precisar ligar por usuário ou percentual.
