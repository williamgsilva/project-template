# {{PROJECT_NAME}}

> {{ONE_LINE_DESCRIPTION}}

[![CI](https://github.com/{{GITHUB_OWNER}}/{{PROJECT_SLUG}}/actions/workflows/ci.yml/badge.svg)](https://github.com/{{GITHUB_OWNER}}/{{PROJECT_SLUG}}/actions/workflows/ci.yml)
[![Security](https://github.com/{{GITHUB_OWNER}}/{{PROJECT_SLUG}}/actions/workflows/security.yml/badge.svg)](https://github.com/{{GITHUB_OWNER}}/{{PROJECT_SLUG}}/actions/workflows/security.yml)

<!-- template:start -->
## Sobre este template

Base **agnóstica de linguagem** para iniciar (ou corrigir) qualquer projeto com boas práticas
de arquitetura, segurança, qualidade, documentação e **desenvolvimento assistido por IA**.
Ela entrega o *alicerce*; o código e as ferramentas da linguagem entram depois, em branches
dedicadas:

| Branch | Conteúdo |
| ------ | -------- |
| `main` | Template genérico (este) |
| `lang/<stack>` | Ex.: `lang/python`, `lang/node`, `lang/go`, `lang/java` — herda de `main` e implementa os `TODO(lang)` |

> Regra: **melhorias genéricas vão para `main`** e são propagadas com `git merge main` para as
> branches `lang/*`. Nunca o contrário.

### Criando um projeto novo

```bash
git clone <url-do-template> meu-projeto && cd meu-projeto
git checkout lang/<stack>          # opcional, se a branch da stack já existir
./scripts/init-project.sh          # pergunta nome, descrição, dono, licença… e substitui os {{PLACEHOLDERS}}
make setup                         # instala os git hooks e cria o .env a partir do .env.example
```

O `init-project.sh` remove esta seção do README, substitui os placeholders em todos os
arquivos e oferece reiniciar o histórico do git. Depois, siga
[Configuração inicial obrigatória](#configuração-inicial-obrigatória).

### Avaliação do template

#### Pontos positivos

- **Agnóstico e consistente:** a mesma interface `make` e a mesma estrutura em qualquer linguagem.
- **Segurança em camadas:** detecção de segredos no commit (gitleaks) e na CI; varredura de
  vulnerabilidades, misconfig e **licenças** (trivy) com resultado na aba *Security*;
  **actions fixadas por SHA**; OpenSSF Scorecard; releases com **SBOM assinado** (Sigstore);
  dependabot; CI com permissões mínimas; e, para a IA, permissões + hook que bloqueia acesso a
  segredos pelo shell + sandbox.
- **Decisões rastreáveis:** ADRs, visão C4, specs versionadas, glossário, modelagem de ameaças,
  Conventional Commits e CHANGELOG/versão gerados automaticamente (release-please).
- **Arquitetura explicada:** catálogo de estilos com critérios de escolha e como cada
  linguagem implementa os mesmos conceitos ([arquitetura.md](docs/standards/arquitetura.md)).
- **Operação:** deploy/rollback, runbook, postmortem e padrão de migrações sem downtime.
- **IA com processo:** regras curtas no `AGENTS.md` (vale para Claude, Copilot, Cursor, Codex),
  10 prompts reutilizáveis e 7 skills (`/planejar`, `/spec`, `/revisar`…), com verificação em
  execução e loop autônomo **limitado**.
- **Didático:** roteiro do zero ao deploy, padrões explicados com o "porquê", modo estudo e
  trilha de referências.
- **Validado:** todos os hooks do pre-commit passam, os workflows passam no actionlint, o hook de
  segredos foi testado (inclusive bloqueando ao vivo no Claude Code) e o `init-project.sh` é
  portável (Linux e macOS) e foi testado com caracteres especiais.
- **Evolui com você:** projetos derivados podem receber melhorias do template
  ([atualizar-do-template.md](docs/atualizar-do-template.md)).

#### Pontos negativos e limitações

- **Sem linguagem, os alvos `make test`, `format`, `run` e `build` não fazem nada.** A CI fica
  verde, mas cada alvo gera uma **anotação de aviso `TODO(lang)` no PR** até a branch
  `lang/<stack>` implementá-los.
- **Volume de documentação:** são cerca de 40 documentos. Para scripts ou protótipos
  descartáveis, a estrutura completa é exagero (veja [Quando não usar](#quando-não-usar-este-template)).
- **Dependência de ferramentas externas:** `pre-commit` (Python), `gitleaks` e `trivy` precisam
  estar instalados para o `make check` local ser completo; sem eles, a varredura só acontece na CI.
- **Hook `no-commit-to-branch`:** bloqueia commit direto na `main` (força PR). Para quem
  trabalha sozinho pode ser incômodo, e o **primeiro commit** de um projeto novo precisa de
  `SKIP=no-commit-to-branch git commit ...`.
- **Actions fixadas por SHA** são menos legíveis; a versão fica no comentário e o Dependabot
  atualiza os dois.
- **Proteções da IA têm limites:** o hook de segredos é baseado em texto (um comando ofuscado
  de propósito pode escapar) e o sandbox exige `bubblewrap` e `socat` no Linux — sem eles, o
  Claude Code só avisa e roda sem sandbox. A defesa mais forte continua sendo **não ter
  segredos de produção na máquina**.
- **Scanner de licenças** falha em dependências GPL/AGPL: se o projeto aceitar alguma, registre
  a exceção num ADR (ver [seguranca.md](docs/standards/seguranca.md)).
- **No próprio repositório do template**, `CODEOWNERS` e o link de vulnerabilidade da issue
  ainda têm `{{PLACEHOLDERS}}` (o GitHub mostra aviso); eles só ficam válidos após o init.
- **Skills e permissões são específicas do Claude Code.** Outros agentes leem só o
  `AGENTS.md` e os prompts em `docs/prompts/`.
- **`.claude/settings.json` desativa `--dangerously-skip-permissions`** e pede confirmação para
  `git push`, `docker` e afins. É mais seguro, porém com mais confirmações; ajuste no
  `.claude/settings.local.json` se precisar.
- **Dependabot só cobre GitHub Actions** até a stack ser definida.
- **Arquivo `LICENSE` ausente:** precisa ser criado conforme a licença escolhida.

### Quando não usar este template

- Scripts únicos, provas de conceito descartáveis ou exercícios: comece com um único arquivo.
- Projetos que já têm um framework com estrutura forte (Rails, Django, Next.js, Spring):
  aproveite as partes transversais (CI, segurança, `AGENTS.md`, prompts, ADRs) e mantenha o
  layout de pastas do framework.

### Manutenção do template (ações suas)

- [x] Primeiro commit e publicação no GitHub.
- [ ] Marcar o repositório como *Template repository* no GitHub (Settings → General).
- [ ] Criar a primeira branch `lang/<stack>` e implementar os `TODO(lang)` (veja abaixo).
- [ ] A cada 1–3 meses: `pre-commit autoupdate`, revisar versões das actions e dos plugins.

### Roadmap do template

- **Copier:** converter os placeholders em `copier.yml` para gerar **e atualizar** projetos com
  `copier update` (hoje a atualização é manual — [atualizar-do-template.md](docs/atualizar-do-template.md)).
- **Windows:** o `make` não é nativo; documentar WSL ou oferecer alternativa (`just`/Task).
- **Front-end:** padrões de acessibilidade (WCAG) e performance web, quando houver UI.
- **Assinatura de commits** (SSH/gitsign) e **harden-runner** na CI.
- **Devcontainer** com firewall (fica nas branches `lang/*`).

### O que implementar numa branch `lang/<stack>`

Procure por `TODO(lang)` (`grep -rn "TODO(lang)" .`) e complete:

1. **Makefile:** `setup`, `lint` (linter + type checker), `format`, `test` (com cobertura
   mínima), `build`, `run`.
2. **CI (`.github/workflows/ci.yml`):** instalar o runtime e usar cache de dependências.
3. **Pre-commit:** formatter e linter da linguagem.
4. **`.gitignore` e `.editorconfig`:** padrões da linguagem.
5. **Dependabot:** ecossistema da linguagem (pip, npm, gomod, maven…) e `docker`.
6. **CodeQL:** SAST gratuito para repositórios públicos.
7. **Dockerfile** multi-stage com usuário não-root e, opcionalmente, um **devcontainer**.
8. **Verificação de arquitetura:** ferramenta da tabela em [arquitetura.md](docs/standards/arquitetura.md#4-mapeamento-por-linguagem-guia-para-as-branches-lang).
9. **Release:** trocar `release-type: simple` em `release-please-config.json` pelo da linguagem
   (python, node, go, maven…) e gerar SBOM/assinatura do artefato ou imagem.
10. **`AGENTS.md`:** preencher a stack e os comandos específicos, se houver.

<!-- template:end -->

**Comece por aqui → [docs/00-comece-aqui.md](docs/00-comece-aqui.md)** (roteiro em fases:
ambiente → descoberta → arquitetura → alicerce → primeiro fluxo ponta a ponta → iteração).

---

## Configuração inicial obrigatória

Faça uma vez por projeto, logo após criar o repositório:

| # | Ação | Por quê |
| - | ---- | ------- |
| 1 | Instalar `pre-commit` (`pipx install pre-commit`), `gitleaks` e `trivy` | Sem eles, `make lint` falha e `make security` só avisa |
| 1b | Linux: instalar `bubblewrap` e `socat` (ex.: `sudo apt install bubblewrap socat`); confira com `/sandbox` no Claude Code | Ativa o sandbox da IA configurado no projeto |
| 2 | `make setup` | Instala os git hooks (inclusive validação da mensagem de commit) e cria o `.env` |
| 3 | Criar o arquivo `LICENSE` ([choosealicense.com](https://choosealicense.com)) | O README e o init referenciam a licença |
| 4 | GitHub → Settings → Branches: proteger `main` (PR obrigatório, checks `Lint`, `Test`, `Build`, `Secrets`, `Vulnerabilities`, `Workflows`, 1 aprovação, sem force-push, histórico linear) | Garante o fluxo trunk-based (veja [docs/standards/git.md](docs/standards/git.md)) |
| 4b | GitHub → Settings → Actions → General: marcar *Allow GitHub Actions to create and approve pull requests* | O release-please precisa abrir o PR de release |
| 5 | GitHub → Settings → Code security: *Secret scanning*, *Push protection*, *Dependabot alerts*, *Private vulnerability reporting* | Camada extra além do gitleaks |
| 6 | Se o repositório for de **organização**, criar o secret `GITLEAKS_LICENSE` (gratuita em gitleaks.io) | O job *Secrets* da CI exige a licença nesse caso |
| 6b | Repositório **privado**: em `scorecard.yml`, `publish_results: false` | A publicação no scorecard.dev só funciona em repos públicos |
| 7 | Preencher `docs/architecture/overview.md` (contexto, escopo, requisitos não funcionais), `docs/glossario.md` e o `docs/operations/runbook.md` antes de produção | Base para decisões, para a IA e para o plantão |
| 8 | (Opcional) Instalar os plugins oficiais do Claude Code recomendados em [docs/prompts/README.md](docs/prompts/README.md#plugins-oficiais-recomendados) | Fluxos prontos de feature, review e segurança |

---

## O que existe e para que serve

### Comandos padrão (`make`)

A mesma interface em qualquer linguagem. A CI chama os mesmos alvos que você roda localmente.

| Comando | O que faz | Quando usar |
| ------- | --------- | ----------- |
| `make help` | Lista os comandos | Sempre que esquecer |
| `make setup` | Instala os git hooks e cria o `.env` | Uma vez, ao clonar |
| `make lint` | Hooks do pre-commit em todos os arquivos (+ linter da stack) | Antes de commitar |
| `make format` | Formata o código | Ao editar (a stack define) |
| `make test` | Testes com cobertura | Sempre, antes do PR |
| `make security` | Segredos (gitleaks) e vulnerabilidades, misconfig e licenças (trivy); **falha se encontrar algo** | Antes do PR e ao atualizar dependências |
| `make sbom` | Gera o SBOM (CycloneDX) em `reports/` | Auditoria; o release já gera e assina um SBOM |
| `make build` | Gera a imagem Docker (se houver `Dockerfile`) ou o artefato da stack | Antes de publicar |
| `make run` | Executa localmente | Desenvolvimento |
| `make check` | `lint` + `test` + `security` — o mesmo que a CI valida | **Critério de pronto** de qualquer tarefa |
| `make clean` | Remove artefatos gerados | Quando precisar de um build limpo |

### Automação de qualidade e segurança

| Item | O que faz | Quando roda |
| ---- | --------- | ----------- |
| [.pre-commit-config.yaml](.pre-commit-config.yaml) | Espaços e finais de linha, YAML/JSON/TOML válidos, conflitos de merge, arquivos grandes, chave privada, **gitleaks**, **Conventional Commits** na mensagem, markdownlint, shellcheck, bloqueio de commit na `main` | A cada `git commit` e em `make lint` |
| [ci.yml](.github/workflows/ci.yml) | Jobs *Lint* (pre-commit), *Test* e *Build* | Em todo PR e push na `main` |
| [security.yml](.github/workflows/security.yml) | gitleaks no histórico; trivy (vulnerabilidades, segredos, misconfig e licenças, com resultado na aba *Security* e bloqueio em HIGH/CRITICAL); actionlint com binário verificado por checksum | PR, push na `main` e **toda segunda-feira** (novas CVEs) |
| [release.yml](.github/workflows/release.yml) + [release-please-config.json](release-please-config.json) | release-please mantém um PR de release (versão SemVer + CHANGELOG a partir dos commits); no merge cria a tag/release e anexa **SBOM assinado** (cosign, keyless) | Push na `main` |
| [scorecard.yml](.github/workflows/scorecard.yml) | OpenSSF Scorecard: nota da postura de segurança do repositório | Push na `main`, semanal e ao mudar proteção de branch |
| [dependabot.yml](.github/dependabot.yml) | PRs semanais atualizando as GitHub Actions (SHA + comentário da versão) | Semanal |
| [CODEOWNERS](.github/CODEOWNERS) | Revisão obrigatória em `.github/`, `.claude/`, `AGENTS.md` e arquitetura | Com branch protection ativa |
| [Templates de PR e issue](.github/) | PR com checklist e **evidência de verificação**; issue de feature com critérios QUANDO/ENTÃO; vulnerabilidades redirecionadas para canal privado | Ao abrir PR ou issue |
| [.editorconfig](.editorconfig) / [.gitattributes](.gitattributes) / [.gitignore](.gitignore) | Formatação básica, finais de linha LF, segredos e artefatos fora do git | Sempre (editor e git) |
| [.env.example](.env.example) | Documenta todas as variáveis de ambiente, sem valores reais | Ao adicionar configuração |

### Trabalho com IA

| Item | O que é | Quando usar |
| ---- | ------- | ----------- |
| [AGENTS.md](AGENTS.md) | Contrato com **qualquer** agente: comandos, regras de arquitetura, código, segurança e forma de trabalhar. O [CLAUDE.md](CLAUDE.md) apenas o importa | Lido automaticamente; mantenha curto e atualizado |
| [docs/prompts/](docs/prompts/) | 10 prompts reutilizáveis (descoberta, arquitetura, feature, review, legado, plano, verificar, estudo, spec, loop) | Copie e cole em qualquer ferramenta de IA |
| [.claude/skills/](.claude/skills/) | Os prompts como comandos do Claude Code (tabela abaixo) | No Claude Code |
| [.claude/settings.json](.claude/settings.json) + [.claude/hooks/](.claude/hooks/) | Permissões, sandbox e hooks **determinísticos** (a IA não consegue ignorar) | Sempre ativos no Claude Code |

#### Skills (comandos) do Claude Code

| Comando | Para que serve | Use quando | Não use quando |
| ------- | -------------- | ---------- | -------------- |
| `/planejar <tarefa>` | Plano "decisão completa" sem editar nada | Tarefa que toca vários arquivos | Mudança trivial (1 linha, typo) |
| `/spec <feature>` | Requisitos → design → tarefas em `docs/specs/`, com aprovação a cada fase | Feature média/grande, várias regras de negócio | Bug pontual ou ajuste pequeno |
| `/revisar [geral\|seguranca\|tudo]` | Review por 9 ângulos + review de segurança, só leitura | Antes de todo PR | Como substituto do review humano |
| `/verificar` | Executa o sistema e gera a evidência para o PR | Toda mudança com comportamento observável | Mudanças só de docs ou testes |
| `/adr <decisão>` | Cria o ADR numerado e atualiza o overview | Decisão cara de reverter, tecnologia, fornecedor | Escolhas locais e facilmente reversíveis |
| `/loop-seguro <tarefa>` | Execução autônoma com **limite de iterações** (padrão 10, máx. 25), branch `loop/*`, commit por iteração e parada sem progresso | Tarefa mecânica com critério de pronto verificável (ex.: migrar N arquivos) | Requisito ambíguo, design, segurança, dados |
| `/estudar <tema>` | Modo tutor: você escreve as decisões de design | Aprender uma tecnologia ou padrão | Quando a prioridade é prazo |

#### Proteções da IA

Em camadas: `permissions` (deny/ask) no `settings.json`, hook que **bloqueia comandos de shell
que acessam `.env`/`secrets/`/chaves** (as regras Read/Edit não valem para o Bash), hook de
formatação após edições e sandbox. Detalhes, o que cada camada cobre e suas limitações:
[docs/prompts/README.md](docs/prompts/README.md#proteções-determinísticas-claude).
Ajustes pessoais vão em `.claude/settings.local.json`, ignorado pelo git.

### Documentação e padrões

| Documento | Conteúdo | Quando consultar |
| --------- | -------- | ---------------- |
| [docs/00-comece-aqui.md](docs/00-comece-aqui.md) | Roteiro em 6 fases, como trabalhar com IA, fontes de estudo | Início do projeto e onboarding |
| [docs/architecture/overview.md](docs/architecture/overview.md) | Contexto, escopo do MVP, requisitos não funcionais com números, C4 (Mermaid), módulos, riscos | Descoberta e a cada mudança relevante |
| [docs/architecture/adr/](docs/architecture/adr/) | Registro de decisões: modelo + ADR 0001 (usar ADRs) + ADR 0002 (monólito modular hexagonal) | Ao decidir algo caro de reverter |
| [arquitetura.md](docs/standards/arquitetura.md) | Níveis de padrões, catálogo de estilos (quando usar/evitar) e **mapeamento por linguagem** | Ao escolher a arquitetura e ao criar uma branch `lang/*` |
| [docs/glossario.md](docs/glossario.md) | Linguagem ubíqua: termos de negócio e seus nomes no código | Antes de nomear entidades, tabelas e endpoints |
| [docs/security/threat-model.md](docs/security/threat-model.md) | Modelagem de ameaças STRIDE (inclui riscos de LLM) | Design de feature sensível |
| [docs/specs/](docs/specs/) | Especificações de features (requisitos, design, tarefas) | Features médias/grandes |
| [estrutura-de-pastas.md](docs/standards/estrutura-de-pastas.md) | Módulos por negócio, camadas hexagonais e regra de dependência | Ao criar módulos ou arquivos |
| [codigo.md](docs/standards/codigo.md) | Princípios, nomes, funções, erros, logs, configuração, dependências | Sempre |
| [git.md](docs/standards/git.md) | Trunk-based, branches, Conventional Commits, SemVer, proteção da `main` | Antes do primeiro commit |
| [seguranca.md](docs/standards/seguranca.md) | OWASP/ASVS, segredos, autenticação, LGPD, cadeia de suprimentos, containers | Design e review |
| [testes.md](docs/standards/testes.md) | Pirâmide, regras, cobertura, tipos de teste | Ao escrever testes |
| [api.md](docs/standards/api.md) | REST, OpenAPI, erros RFC 9457, idempotência, paginação | Ao criar APIs |
| [observabilidade-e-performance.md](docs/standards/observabilidade-e-performance.md) | OpenTelemetry, SLOs, checklist de performance | Antes de produção |
| [dados-e-migracoes.md](docs/standards/dados-e-migracoes.md) | Migrações versionadas, *expand → contract*, performance de banco, backups | Toda mudança de banco |
| [docs/operations/](docs/operations/) | [Deploy e rollback](docs/operations/deploy-e-rollback.md), [runbook](docs/operations/runbook.md), [postmortem](docs/operations/postmortem.md) | Antes de produção e em incidentes |
| [atualizar-do-template.md](docs/atualizar-do-template.md) | Como trazer melhorias do template para um projeto existente | Trimestralmente ou em correções de segurança |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Fluxo de trabalho e Definition of Done | Antes do primeiro PR |
| [SECURITY.md](SECURITY.md) | Como reportar vulnerabilidades | Publicado para usuários externos |
| [CHANGELOG.md](CHANGELOG.md) | Histórico de mudanças, **gerado pelo release-please** | Consulta (não editar à mão) |

### Código e testes

| Pasta | Conteúdo |
| ----- | -------- |
| `src/bootstrap/` | *Composition root*: lê a configuração, cria os adaptadores e sobe a aplicação |
| `src/shared/` | Kernel compartilhado (config, observabilidade, erros base) — só o que é transversal |
| `src/modules/<modulo>/` | Um módulo por capacidade de negócio, com `domain/`, `application/`, `infrastructure/`, `interfaces/` (`example/` é só um modelo) |
| `tests/unit` · `integration` · `e2e` | Pirâmide de testes |
| `scripts/init-project.sh` | Inicializa um projeto novo a partir do template |

---

## Fluxo de trabalho

Fonte única: [CONTRIBUTING.md](CONTRIBUTING.md). Resumo:

```text
issue (critérios QUANDO/ENTÃO)
  → /planejar (tarefa pequena) ou /spec (feature média/grande)
  → branch curta → teste falhando → código → refatora
  → make check → /verificar → /revisar
  → PR pequeno (< 400 linhas) → CI verde + review humano → squash merge → deploy
```

| Situação | Caminho |
| -------- | ------- |
| Projeto novo | [00-comece-aqui](docs/00-comece-aqui.md) → [01-descoberta](docs/prompts/01-descoberta.md) → [02-arquitetura](docs/prompts/02-arquitetura.md) / `/adr` → alicerce → primeiro fluxo ponta a ponta |
| Projeto existente (corrigir) | [05-legado](docs/prompts/05-legado.md): diagnóstico só de leitura → plano incremental (rede de segurança primeiro, sem reescrita) |
| Bug ou ajuste pequeno | `/planejar` → teste que reproduz → correção → `make check` → `/verificar` → `/revisar` → PR |
| Feature média/grande | `/spec` → uma tarefa por vez (`/spec executar ...`) → `/verificar` → `/revisar` → PR |
| Trabalho repetitivo | `/loop-seguro` (com critério de pronto) → `/revisar` → PR |
| Decisão de arquitetura | `/adr` |
| Aprender algo | `/estudar` ou o output style *Learning* (`/config`) |
| Feature sensível (auth, dados pessoais, pagamentos, LLM) | `/spec` com [modelagem de ameaças](docs/security/threat-model.md) no design |
| Mudança de banco | [expand → contract](docs/standards/dados-e-migracoes.md) |
| Deploy / incidente | [deploy-e-rollback](docs/operations/deploy-e-rollback.md) → [runbook](docs/operations/runbook.md) → [postmortem](docs/operations/postmortem.md) |
| Trazer melhorias do template | [atualizar-do-template.md](docs/atualizar-do-template.md) |

## Estrutura

```text
.
├── .claude/             # skills (/planejar, /spec, /revisar…), hooks e permissões/sandbox da IA
├── .github/             # CI, segurança, release, scorecard, templates de PR/issue, dependabot, CODEOWNERS
├── docs/
│   ├── 00-comece-aqui.md     # roteiro: do zero ao primeiro deploy
│   ├── atualizar-do-template.md  # como receber melhorias do template
│   ├── glossario.md          # linguagem ubíqua
│   ├── architecture/         # visão geral (C4) + ADRs (decisões)
│   ├── operations/           # deploy/rollback, runbook, postmortem
│   ├── prompts/              # prompts reutilizáveis + skills, plugins, proteções e fontes
│   ├── security/             # modelagem de ameaças
│   ├── specs/                # especificações de features (requirements/design/tasks)
│   └── standards/            # padrões (arquitetura, código, git, segurança, testes, API, dados, observabilidade)
├── scripts/             # automações (init-project.sh)
├── src/                 # bootstrap/, shared/, modules/<modulo>/{domain,application,infrastructure,interfaces}
├── tests/               # unit / integration / e2e
├── AGENTS.md            # regras para agentes de IA (Claude, Copilot, Cursor, Codex…)
├── CLAUDE.md            # importa o AGENTS.md
├── CHANGELOG.md         # histórico de mudanças (gerado pelo release-please)
├── CONTRIBUTING.md      # fluxo de trabalho e Definition of Done
├── SECURITY.md          # política de segurança
├── Makefile             # interface única de comandos
└── release-please-config.json  # configuração do release automatizado
```

## Licença

{{LICENSE}} — veja [LICENSE](LICENSE).
