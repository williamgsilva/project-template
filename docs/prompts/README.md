# Prompts reutilizáveis

Prompts testados para cada fase do projeto. Copie, preencha os `<campos>` e use com
qualquer assistente (Claude Code, Copilot Chat, Cursor…). Melhore-os conforme aprender.

| Arquivo | Fase | Uso |
| ------- | ---- | --- |
| [01-descoberta.md](01-descoberta.md) | Descoberta | IA entrevista você para levantar requisitos |
| [02-arquitetura.md](02-arquitetura.md) | Arquitetura | Comparar opções e gerar ADR |
| [03-feature.md](03-feature.md) | Desenvolvimento | Planejar e implementar uma feature com testes |
| [04-review.md](04-review.md) | Revisão | Code review por ângulos + review de segurança |
| [05-legado.md](05-legado.md) | Correção | Diagnosticar e adequar um projeto existente a este template |
| [06-plano.md](06-plano.md) | Desenvolvimento | Plano "decisão completa", em modo somente leitura |
| [07-verificar.md](07-verificar.md) | Verificação | Provar que a mudança funciona executando o sistema |
| [08-estudo.md](08-estudo.md) | Aprendizado | A IA ensina e você implementa as decisões de design |
| [09-spec.md](09-spec.md) | Especificação | Feature média/grande: requisitos → design → tarefas, com aprovação a cada fase |
| [10-loop-autonomo.md](10-loop-autonomo.md) | Automação | Loop autônomo com limites rígidos de iterações e escopo |
| [11-avaliar-externo.md](11-avaliar-externo.md) | Segurança | Avaliar repositório, skill, plugin ou MCP de terceiros antes de adotar |
| [12-briefing.md](12-briefing.md) | Comunicação | Transformar seus planos em documento de trabalho em `docs/planos/` |

Fluxo sugerido por tarefa:

- **Pequena:** `06-plano` → `03-feature` → `make check` → `07-verificar` → `04-review` → PR.
- **Média/grande:** `09-spec` (requisitos → design → tarefas) → uma tarefa por vez → `07-verificar` → `04-review` → PR.
- **Mecânica e repetitiva:** `10-loop-autonomo` (com limite) → `04-review` → PR.

## Skills do projeto (Claude Code)

Os prompts acima também existem como comandos em [`.claude/skills/`](../../.claude/skills/).
Cada skill apenas aponta para o prompt correspondente, que continua sendo a fonte única.

| Comando | Prompt | Observação |
| ------- | ------ | ---------- |
| `/planejar <tarefa>` | 06-plano | Somente leitura |
| `/spec <feature>` · `/spec executar <feature> <n>` | 09-spec | Para a cada fase e pede aprovação |
| `/revisar [geral\|seguranca\|tudo]` | 04-review | Somente leitura; não corrige sozinho |
| `/verificar` | 07-verificar | Evidência para o PR |
| `/adr <decisão>` | 02-arquitetura | Cria o ADR numerado |
| `/loop-seguro <tarefa> [--max N]` | 10-loop-autonomo | Padrão 10, teto 25 iterações |
| `/estudar <tema>` | 08-estudo | Você escreve as decisões de design |
| `/avaliar-externo <url> [uso]` | 11-avaliar-externo | Somente leitura; veredito antes de instalar qualquer coisa de fora |
| `/briefing <tema> [despejo]` | 12-briefing | Perguntas numeradas; grava em `docs/planos/` após seu ok |

### Skills de terceiros

Copiadas **fixadas por SHA**, com licença, depois de passar por `/avaliar-externo`. Não edite
estes arquivos: para atualizar, avalie o diff entre os SHAs e copie a pasta inteira de novo.

| Skill | Origem (SHA) | Licença | Avaliada em | Para quê |
| ----- | ------------ | ------- | ----------- | -------- |
| `discernment-nudge` | [anthropics/skills@1780c5e](https://github.com/anthropics/skills/tree/1780c5e5a552fd4d1c9d6a7b0cab26b0c2bef064/skills/discernment-nudge) | Apache-2.0 | 2026-11-14 | Depois de recomendações, planos e estimativas, fecha com 2–3 perguntas para checar fatos e premissas (no máximo uma vez por conversa). Só texto, sem scripts |

Avaliadas e **não** adotadas: `doc-coauthoring` (sem arquivo de licença; usa subagentes e se
sobrepõe a `/spec` e `/briefing` — a parte útil, perguntas numeradas com resposta curta, foi
incorporada ao 12-briefing).

### Proteções determinísticas (`.claude/`)

| Camada | O que faz | Limitação |
| ------ | --------- | --------- |
| `permissions.deny` em [settings.json](../../.claude/settings.json) | Bloqueia leitura/edição de `.env*`, `secrets/`, chaves e das credenciais da pasta pessoal (`~/.ssh`, `~/.aws`, `~/.config/gh`…); bloqueia `git push --force`, `git commit --no-verify` e `sudo`; desativa `--dangerously-skip-permissions` | As regras Read/Edit valem para as ferramentas e para `cat`/`head`/`tail`/`sed`/`tee` e redirecionamentos no Bash, mas **não** para `grep -r .` nem para scripts que abrem arquivos sozinhos |
| `permissions.ask` | Pede confirmação para rede (`curl`, `wget`), `git push`, comandos git destrutivos (`reset --hard`, `clean`, `rebase`, `stash drop/clear`, `branch -D`, `switch -f`), `rm -r(f)`, `docker`, `kubectl`, `terraform`, `make build`/`clean` e edições em `.github/`, `.claude/` e `Makefile` | Mais confirmações durante o trabalho |
| `permissions.allow` | Libera sem perguntar: alvos do `make` (exatos), git do dia a dia, leitura e manipulação de arquivos. **Nenhum interpretador** (`python3`, `node`, `npx`, `npm run`): eles executam código arbitrário | Só vale depois de você confiar na pasta (*workspace trust*) |
| Hook [protect-secrets.sh](../../.claude/hooks/protect-secrets.sh) (PreToolUse) | Bloqueia comandos de shell que citam `.env` (inclusive entre aspas e com glob), `secrets/`, arquivos de chave e credenciais da pasta pessoal. Testado por `scripts/test-hooks.sh` (roda no `make lint`) | Baseado em texto: código que monta o caminho em tempo de execução escapa |
| Hook [format.sh](../../.claude/hooks/format.sh) (PostToolUse) | Formata só o arquivo editado (`make format FILES=...`) | Inativo até a stack implementar `make format` |
| Sandbox | Isola o Bash (arquivos e rede); nega leitura das pastas de credenciais; **não inicia sem `bubblewrap`/`socat`** (`failIfUnavailable`) e **não permite sair do sandbox** (`allowUnsandboxedCommands: false`) | Lê o resto da pasta pessoal (necessário para git, pre-commit e toolchains) |

### Como flexibilizar sem enfraquecer o time

Regras de listas (`allow`, `ask`, `deny`) **se somam** entre arquivos, e a ordem de avaliação é
sempre deny → ask → allow ([documentação](https://code.claude.com/docs/en/permissions.md)). Por isso:

| Quero… | Onde | Como |
| ------ | ---- | ---- |
| Liberar um comando só para mim | `.claude/settings.local.json` (fora do git) | `"allow": ["Bash(npm test)"]` — funciona para o que **não** está em `ask`/`deny` do projeto |
| Liberar algo que está em `ask` | Não dá pelo arquivo local: `ask` do projeto vence `allow` local | Aprove na hora, ou proponha tirar do `ask` do projeto num PR |
| Liberar comandos da stack | `.claude/settings.json` da branch `lang/<stack>` | Comandos **exatos**: `Bash(npm test)`, `Bash(npm run lint)`, `Bash(pytest)` — nunca `Bash(npx *)` ou `Bash(python3 *)` |
| Uma sessão mais solta, só agora | Linha de comando | `claude --settings '{"permissions":{"allow":["Bash(npm run dev)"]}}'` (vale só nessa sessão) |
| Ferramenta que precisa ler algo de `~` bloqueado | `.claude/settings.local.json` | Avalie primeiro: as pastas negadas guardam credenciais. Prefira dar ao projeto um token próprio e de escopo mínimo |
| `make check` exigente (ex.: na CI ou antes do release) | Comando | `STRICT=1 make check` falha se alguma etapa não rodou |

## Economia de tokens no dia a dia

Ordenado do maior para o menor ganho:

1. **Uma conversa por assunto.** Use `/clear` ao trocar de tarefa: o histórico inteiro é
   reenviado a cada mensagem, então uma conversa longa encarece todas as respostas seguintes.
   Em conversas longas no mesmo assunto, `/compact` resume o histórico.
2. **Modelo e esforço sob medida.** `/model` e `/effort`: tarefa mecânica (renomear, ajustar
   texto, rodar comandos) vai bem com esforço baixo ou um modelo menor; deixe o modelo e o
   esforço altos para planejar, depurar e decidir.
3. **Contexto pronto em arquivo.** Planos em `docs/planos/`, decisões em ADR: diga "leia
   docs/planos/X.md" em vez de reexplicar a cada conversa.
4. **Pedidos fechados.** "Faça X no arquivo Y, critério Z" gasta menos que "melhore o projeto".
   Plano antes (`/planejar`) só quando a tarefa é grande.
5. **Sem releitura e sem saída enorme.** As regras de "Economia de contexto" do AGENTS.md já
   cobrem isso; `make check-rapido` em vez de `make check` durante iterações.
6. **Subagentes e reviews multiagente só quando valem a pena:** cada um recomeça do zero e
   multiplica o consumo.

## Boas práticas de prompt

1. **Contexto → tarefa → restrições → formato de saída.** Nessa ordem.
2. **Peça o plano antes do código** e revise o plano.
3. **Uma tarefa por vez**, com critério de pronto verificável ("`make check` passa").
4. **Peça para perguntar** quando faltar informação, em vez de supor.
5. **Referencie arquivos** em vez de colar conteúdo (o agente lê `AGENTS.md` sozinho).
6. **Exija justificativa** para escolhas (bibliotecas, padrões) — e confira as fontes.
7. **Achado sem cenário concreto não é achado.** Peça sempre "com a entrada X acontece Y".

## Recursos nativos do Claude Code

| Recurso | O que faz |
| ------- | --------- |
| Plan mode (Shift+Tab) | Planeja em modo somente leitura antes de alterar arquivos |
| `/code-review` | Review de bugs e qualidade das mudanças da branch |
| `/security-review` | Review de segurança das mudanças da branch |
| `/simplify` | Limpeza: reuso, simplificação, eficiência (não procura bugs) |
| `/sandbox` | Mostra o estado do sandbox e as dependências que faltam |
| `/init` | Cria ou revisa o CLAUDE.md |
| `/config` → Output style *Learning* / *Explanatory* | Modo de aprendizado (ver 08-estudo.md) |
| Skill `skill-creator` | Cria skills próprias do projeto em `.claude/skills/` |

## Qual review usar?

| Situação | Use |
| -------- | --- |
| Todo PR, antes do review humano | `/revisar tudo` (critérios do projeto: arquitetura, padrões, falhas silenciosas, segurança) |
| Segunda opinião de segurança em mudança sensível | `/security-review` (nativo) |
| PR grande ou com muita lógica de erro/tipos/testes | `/pr-review-toolkit:review-pr` (plugin) |
| Revisão de PR no GitHub, com comentários na linha | Plugin `code-review` ou `/code-review` (nativo) |
| Só limpar o código, sem caçar bugs | `/simplify` |

Nenhum deles substitui o review humano: são filtros antes dele.

## Plugins oficiais recomendados

Do repositório oficial [anthropics/claude-code](https://github.com/anthropics/claude-code/tree/main/plugins).
Instale com `/plugin` (marketplace oficial) e use conforme a necessidade:

| Plugin | Para quê |
| ------ | -------- |
| `feature-dev` | `/feature-dev`: fluxo guiado de feature (exploração com agentes, perguntas, arquitetura, implementação, review) |
| `pr-review-toolkit` | Agentes especializados de review, incluindo `silent-failure-hunter` (erros engolidos) e análise de testes |
| `security-guidance` | Hook que alerta padrões perigosos (injeção de comando, XSS, eval, desserialização) durante a edição |
| `commit-commands` | `/commit`, `/commit-push-pr`, `/clean_gone` |
| `hookify` | Transforma "nunca faça X" em hook que bloqueia de verdade |
| `ralph-loop` (antigo `ralph-wiggum`) | Loop autônomo — **somente** com `--max-iterations` (ver 10-loop-autonomo.md) |
| `claude-md-management` | Audita o CLAUDE.md/AGENTS.md e registra aprendizados da sessão (`/revise-claude-md`) |
| `claude-code-setup` | Analisa o código e recomenda hooks, skills, MCPs e subagentes sob medida — útil logo após escolher a stack |
| `claude-security` | Varredura profunda de vulnerabilidades com verificação de cada achado; para releases ou mudanças sensíveis (custa mais que `/security-review`) |

Marketplace oficial: [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official).
Plugin pode trazer hooks e scripts que **executam código**: mesmo os oficiais passam por
`/avaliar-externo` antes de instalar, e nenhum fica habilitado por padrão no `settings.json`.

> Regra geral: o que **não pode** falhar vira hook ou permissão em `.claude/settings.json`;
> instrução em prompt é orientação, não garantia.

## Fontes para estudar prompts e skills

- Oficiais (preferir): [anthropics/skills](https://github.com/anthropics/skills),
  [documentação do Claude Code](https://docs.claude.com/en/docs/claude-code/overview),
  [system prompts publicados pela Anthropic](https://platform.claude.com/docs/en/release-notes/system-prompts),
  [guia de prompt engineering](https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/overview),
  [Building effective agents](https://www.anthropic.com/research/building-effective-agents).
- Livro aberto (MIT): [The Interactive Book of Prompting](https://prompts.chat) do
  [f/prompts.chat](https://github.com/f/prompts.chat) — capítulos de context engineering, agentes
  e skills, harnesses, MCP e programação. O site também oferece biblioteca de prompts (CC0),
  servidor MCP e plugin para o Claude Code; os prompts da comunidade têm qualidade variável.
- Agentes open source (licença aberta, leia direto na fonte):
  [Cline](https://github.com/cline/cline), [OpenAI Codex CLI](https://github.com/openai/codex),
  [Gemini CLI](https://github.com/google-gemini/gemini-cli).
- Comunidade (não oficial, autenticidade não garantida, direitos dos textos pertencem às
  empresas): [asgeirtj/system_prompts_leaks](https://github.com/asgeirtj/system_prompts_leaks),
  [x1xhlol/system-prompts-and-models-of-ai-tools](https://github.com/x1xhlol/system-prompts-and-models-of-ai-tools)
  (destaque: o fluxo de spec do Kiro, base do 09-spec.md).
  Use para estudar padrões; não copie textos para o projeto.
