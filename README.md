# {{PROJECT_NAME}}

> {{ONE_LINE_DESCRIPTION}}

[![CI](https://github.com/{{GITHUB_OWNER}}/{{PROJECT_SLUG}}/actions/workflows/ci.yml/badge.svg)](https://github.com/{{GITHUB_OWNER}}/{{PROJECT_SLUG}}/actions/workflows/ci.yml)

<!-- template:start -->
## Sobre este template

Base **agnóstica de linguagem** para todos os projetos. Ela define o *alicerce*:
estrutura de pastas, padrões, segurança, CI, documentação e instruções para IA.
A linguagem é adicionada depois, em branches dedicadas:

| Branch          | Conteúdo                                                   |
| --------------- | ---------------------------------------------------------- |
| `main`          | Template genérico (este)                                   |
| `lang/<stack>`  | Ex.: `lang/python`, `lang/node`, `lang/go`, `lang/java`… — herda de `main` e adiciona tooling da linguagem |

> Regra: **melhorias genéricas vão para `main`** e depois são propagadas
> (`git merge main`) para as branches `lang/*`. Nunca o contrário.

## Criando um projeto novo a partir do template

```bash
git clone <url-do-template> meu-projeto && cd meu-projeto
git checkout lang/<stack>          # opcional, se já existir a branch da stack
./scripts/init-project.sh          # substitui os {{PLACEHOLDERS}} e reinicia o git
make setup                         # instala hooks e dependências
```

<!-- template:end -->

**Comece por aqui → [docs/00-comece-aqui.md](docs/00-comece-aqui.md)**

## Comandos padrão

Todo projeto expõe a **mesma interface** via `make`, independente da linguagem:

| Comando          | O que faz                                        |
| ---------------- | ------------------------------------------------ |
| `make help`      | Lista os comandos                                |
| `make setup`     | Prepara o ambiente local (deps + git hooks)      |
| `make lint`      | Lint + formatação (checagem)                     |
| `make format`    | Formata o código                                 |
| `make test`      | Testes com cobertura                             |
| `make security`  | Varredura de segredos, dependências e IaC        |
| `make build`     | Gera o artefato/imagem                           |
| `make run`       | Executa localmente                               |
| `make check`     | `lint` + `test` + `security` (o mesmo que a CI)  |

## Estrutura

```text
.
├── .github/             # CI/CD, templates de PR/issue, dependabot, CODEOWNERS
├── docs/
│   ├── 00-comece-aqui.md     # roteiro: do zero ao primeiro deploy
│   ├── architecture/         # visão geral (C4) + ADRs (decisões)
│   ├── standards/            # padrões obrigatórios (código, git, segurança, testes…)
│   └── prompts/              # prompts reutilizáveis para trabalhar com IA
├── scripts/             # automações (init, utilitários)
├── src/                 # código-fonte: modules/<modulo>/{domain,application,infrastructure,interfaces}
├── tests/               # unit / integration / e2e
├── AGENTS.md            # regras para agentes de IA (Claude, Copilot, Cursor…)
├── CLAUDE.md            # aponta para AGENTS.md
├── CONTRIBUTING.md      # fluxo de trabalho e Definition of Done
├── SECURITY.md          # política de segurança
└── Makefile             # interface única de comandos
```

## Documentação

- Arquitetura: [docs/architecture/overview.md](docs/architecture/overview.md)
- Decisões (ADRs): [docs/architecture/adr/](docs/architecture/adr/)
- Padrões: [docs/standards/](docs/standards/)
- Como contribuir: [CONTRIBUTING.md](CONTRIBUTING.md)

## Licença

{{LICENSE}} — veja [LICENSE](LICENSE).
