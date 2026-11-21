# Auditoria do template — 2026-11-14

Escopo: todo o repositório `template` (árvore de trabalho atual, **incluindo mudanças ainda não
commitadas** em `.claude/settings.json`, `.claude/hooks/format.sh` e `AGENTS.md`), procurando
custo monetário, custo de recursos (CPU, disco, memória, banda), falhas de segurança, instruções
que geram falso positivo ou autorizam comando arriscado, e desperdício de tokens.

Como ler:

- **Severidade:** Alta (corrigir antes de usar o template em projeto real) · Média · Baixa · Info.
- **Evidência:** cada achado diz *como* foi verificado: `testado` (executei), `doc oficial`
  (link), `leitura` (li o arquivo). O que não consegui confirmar está marcado como
  **NÃO VERIFICADO**, com o motivo — nada aqui é chute.
- Nenhuma correção foi aplicada. A seção [Plano de correção](#plano-de-correção) propõe a ordem.

## Status das correções

Aplicadas em 2026-11-14 (ainda não commitadas). Verificação: `make lint` (pre-commit inteiro +
28/28 casos do hook), `make check` / `STRICT=1 make check`, actionlint 1.7.12 e validação do
`settings.json` contra o schema oficial (0 erros).

| Achado | Status | O que mudou |
| ------ | ------ | ----------- |
| S1, S6 | ✅ | `allow` sem interpretadores (`python3`, `node`, `npx`, `npm run`); `make` só com alvos exatos; `Edit(./Makefile)` e `make build` em `ask` |
| S2 | ✅ | `sandbox.filesystem.denyRead` nas pastas de credenciais + `Read(~/...)` em `deny` (lista de bloqueio, não de permissão — ver [flexibilidade](../prompts/README.md#como-flexibilizar-sem-enfraquecer-o-time)) |
| S3 | ✅ | `failIfUnavailable: true` e `allowUnsandboxedCommands: false` |
| S4, S5 | ✅ | `deny` para `git commit --no-verify`/`-n`; variantes destrutivas de `stash`/`branch`/`switch` em `ask` |
| S7, S8 | ✅ | Hook lê o comando com `jq`, cobre aspas, globs e credenciais de `~`; não bloqueia mais `jq '.key'`. Regressão em `tests/hooks/protect-secrets.casos` (roda no `make lint`) |
| S9 | ✅ | `deny` completado (`.env.test`, `.env.ci`, `.env.prod`, `.env.dev`, `*.p12`, `*.pfx`, `id_rsa*`, `id_ed25519*`) |
| S10, S11 | ✅ | Hooks do pre-commit fixados por SHA (`# frozen:`); Dependabot com ecossistema `pre-commit` e `cooldown` de 7 dias |
| S13 | ✅ | Tabela de proteções reescrita (README e `docs/prompts/README.md`) |
| C1 | ✅ | SARIF/aba Security e Scorecard só com a variável `CODE_SCANNING=true`; sem ela, o Trivy mostra tabela no log e continua barrando |
| C5 | ✅ | "Perfil solo" (0 aprovações + `/revisar`) em `git.md` e no README |
| P1 | ✅ | `make check` termina com resumo das etapas **NÃO EXECUTADAS**; `STRICT=1` falha; AGENTS.md exige relatar |
| R1 | ✅ | Novo `make check-rapido` para iterações (loop, spec); `make check` completo no fim |
| R2 | ✅ | `format.sh` formata só o arquivo editado (`make format FILES=...`) |
| R3 | ❎ revisado | Não é duplicação real: no `--all-files` o hook gitleaks do pre-commit só olha o que está *staged*; o `make security` varre o histórico |
| I2, I3 | ✅ | 03-feature: corrigir só o que a mudança quebrou; 07-verificar: CI disparada por você |
| C2 | ⏸️ | Mantido: juntar/pular Test/Build muda os nomes dos checks obrigatórios. Rever quando a stack for escolhida |
| I1 | ⏸️ | Decisão sua: manter, mover para `~/.claude/skills` ou remover a `discernment-nudge` |
| P2 | ✅ parcial | A CI agora anota "NÃO EXECUTADO" no PR; o job continua verde até a stack existir |

## Resumo executivo

| # | Achado | Sev. | Tipo |
| - | ------ | ---- | ---- |
| S1 | `allow` de `python3 *`, `node *`, `npx *`, `npm run *` = execução arbitrária sem confirmação | Alta | Segurança |
| S2 | Sandbox lê o disco inteiro (`~/.ssh`, `~/.aws`, token do `gh`) e o hook não cobre | Alta | Segurança |
| C1 | Repositório **privado**: upload de SARIF exige licença paga → job *Vulnerabilities* falha e bloqueia merge | Alta | Custo / CI |
| P1 | `make check` passa sem testar e sem escanear (ferramentas ausentes e alvos TODO) → agente declara "pronto" | Alta | Falso positivo |
| S3 | Sandbox "falha aberto" e permite fuga com `dangerouslyDisableSandbox` | Média | Segurança |
| S4 | `git commit*` liberado permite `--no-verify` (pula gitleaks e Conventional Commits) | Média | Segurança |
| S5 | `git stash*`, `git branch*`, `git switch*` liberados permitem apagar trabalho sem perguntar | Média | Segurança |
| S6 | `make *` liberado + Makefile editável = execução arbitrária indireta | Média | Segurança |
| S7 | Hook de segredos deixa passar `cat ".env"`, `cat .env*`, `cat .en?` | Média | Segurança |
| S9 | Lista `deny` de leitura incompleta e inconsistente com o hook | Média | Segurança |
| S10 | Hooks do pre-commit fixados por **tag** (mutável), não por SHA | Média | Cadeia de suprimentos |
| S13 | Documentação afirma que regras Read/Edit "não valem para o Bash" (desatualizado) | Média | Instrução errada |
| C2 | Minutos de Actions gastos em jobs que não fazem nada (Test/Build TODO) e em mudanças só de docs | Média | Custo |
| C5 | "1 aprovação + Code Owners" trava quem trabalha sozinho | Média | Uso |
| R1 | `make check` completo exigido a cada tarefa e a cada iteração de loop (até 25×) | Média | Recursos |
| R2 | `make format` do repositório inteiro após **cada** edição da IA | Média | Recursos |
| I1 | Skill `discernment-nudge`: maior custo fixo de contexto e conflito com "respostas curtas" | Média | Tokens |
| I2 | Prompt 03 manda "corrija tudo" → incentiva mexer fora do escopo / enfraquecer teste | Média | Instrução |
| S8 | Falsos positivos do hook (`jq '.key'`, `rg secrets/`) | Baixa | Uso |
| S11 | Dependabot sem `cooldown` | Baixa | Cadeia de suprimentos |
| R3 | gitleaks roda duas vezes no mesmo `make check` | Baixa | Recursos |
| I3 | 07-verificar sugere disparar CI (exige push, que a skill proíbe) | Baixa | Instrução |
| P2 | CI fica verde com Test/Build vazios | Baixa | Falso positivo |

Pontos fortes confirmados (não mexer): actions fixadas por SHA, inclusive o `trivy-action`
(ver [S12](#s12--info--o-trivy-action-fixado-é-legítimo)); permissões mínimas nos workflows;
`persist-credentials: false`; actionlint baixado com checksum; SBOM assinado (Sigstore);
`disableBypassPermissionsMode`; custo fixo de contexto baixo ([I6](#i6--info--custo-fixo-de-contexto-é-baixo)).

> **Atenção — origem dos riscos S1, S3, S5 e S6:** a versão **commitada** do
> `.claude/settings.json` era restritiva (`allow` só com `make help|lint|test|check|security` e
> `autoAllowBashIfSandboxed: false`). A ampliação está na mudança **não commitada**
> (`git diff .claude/settings.json`). Decida conscientemente antes de commitar.

---

## 1. Segurança

### S1 — Alta — Interpretadores e `npx` liberados

- **Onde:** `.claude/settings.json` → `allow`: `Bash(python3 *)`, `Bash(node *)`, `Bash(npx *)`,
  `Bash(npm run *)`.
- **Problema:** qualquer um deles executa código arbitrário sem confirmação.
  `python3 -c "..."` faz rede, apaga arquivos e lê segredos, contornando os `ask` de `curl`,
  `wget`, `rm -rf` e `docker`. A documentação oficial confirma que as regras Read/Edit **não**
  alcançam "arbitrary subprocesses that read or write files indirectly, like a Python or Node
  script" ([permissions](https://code.claude.com/docs/en/permissions.md)).
  `npx <pacote>` baixa e executa um pacote do registro na hora: é exatamente o vetor de
  cadeia de suprimentos que os gists avaliados recomendam (`npx impeccable install`,
  `npx ecc-universal setup`). A doc também avisa que `npx` não é tratado como *wrapper*: um
  `allow` nele aprova qualquer coisa que venha depois.
- **Cenário:** um README ou issue com injeção de prompt pede "rode `npx pacote-x`"; o agente
  executa sem você ver.
- **Evidência:** leitura + doc oficial.
- **Correção:** remover os quatro. Liberar só comandos exatos (`Bash(npm test)`,
  `Bash(npm run lint)`) quando a stack existir (branch `lang/*`).

### S2 — Alta — O sandbox lê o disco inteiro

- **Onde:** `.claude/settings.json` → `sandbox` sem `filesystem.denyRead`.
- **Problema:** por padrão o sandbox tem "read access to the entire computer… This default
  still allows reading credential files", incluindo `~/.ssh` e `~/.aws/credentials`
  ([sandboxing](https://code.claude.com/docs/en/sandboxing.md)). O hook `protect-secrets.sh`
  só conhece `.env`, `secrets/` e extensões de chave.
- **Evidência — testado:** o hook deixa passar `cat ~/.ssh/id_ed25519`,
  `cat ~/.aws/credentials` e `cat ~/.config/gh/hosts.yml`.
- **Mitigação existente:** a rede do sandbox passa por um proxy cuja lista de domínios começa
  vazia (doc), o que dificulta enviar os dados para fora. Só que S1 (`python3`) e a fuga de
  S3 enfraquecem essa barreira.
- **Correção:**

```json
{
  "sandbox": {
    "filesystem": { "denyRead": ["~/"], "allowRead": ["."] }
  }
}
```

  Depois disso, teste se o toolchain da stack continua funcionando: talvez seja preciso
  liberar com `allowRead` os caches de pacotes da stack em `~`.

### S3 — Média — O sandbox falha aberto e tem rota de fuga

- **Problema 1:** "when the platform doesn't support the sandbox or the dependency check at
  startup fails, Claude Code runs commands without sandboxing" (doc). Com S1 ativo, isso vira
  execução livre fora de qualquer isolamento.
- **Problema 2:** quando um comando falha no sandbox, o Claude pode repetir com
  `dangerouslyDisableSandbox` (doc). Nesta própria sessão isso aconteceu várias vezes para
  escrever em `.claude/skills` e no template, com confirmação sua. O caminho existe e depende
  de você negar.
- **Evidência:** doc oficial + histórico desta sessão. Nesta máquina `bwrap` e `socat` estão
  instalados (`command -v`), então hoje o sandbox sobe.
- **Correção:**

```json
{ "sandbox": { "enabled": true, "failIfUnavailable": true, "allowUnsandboxedCommands": false } }
```

### S4 — Média — Commit pulando os hooks

- **Onde:** `allow` → `Bash(git commit*)`.
- **Problema:** libera `git commit --no-verify`/`-n`, que pula gitleaks, detect-private-key e
  Conventional Commits. A barreira de segredo no commit some sem você saber.
- **Evidência:** leitura (deny e ask valem em qualquer subcomando; allow por prefixo cobre as flags).
- **Correção:** `deny`: `Bash(git commit *--no-verify*)`, `Bash(git commit *-n *)`.

### S5 — Média — Comandos git destrutivos liberados

- **Onde:** `allow` → `Bash(git stash*)`, `Bash(git branch*)`, `Bash(git switch*)`.
- **Problema:** liberam `git stash drop`/`clear`, `git branch -D` e
  `git switch --discard-changes`/`-f`, que perdem trabalho sem pedir. Isso contradiz a regra
  do próprio AGENTS.md: "Nunca reverta ou sobrescreva mudanças que você não fez".
- **Correção:** liberar só `Bash(git stash push*)`, `Bash(git stash list)`, `Bash(git branch)`
  e `Bash(git branch --list*)`; colocar as variantes destrutivas em `ask`.

### S6 — Média — `make *` liberado

- **Problema:** em modo *acceptEdits* a IA edita o `Makefile` (ou o `package.json`, no caso de
  `npm run *`) e executa o alvo sem perguntar. Além disso, `make build` roda `docker build`,
  contornando o `ask` de `docker *`.
- **Correção:** liberar alvos explícitos (`make help`, `make lint`, `make test`,
  `make security`, `make check`, `make format`) e colocar `Edit(./Makefile)` em `ask`.

### S7 — Média — Falsos negativos do hook `protect-secrets.sh`

- **Evidência — testado** (alimentei o hook com o JSON real do Claude Code):

| Comando | Resultado |
| ------- | --------- |
| `cat '.env'` · `cat .env` · `source .env` · `cat .env.test` | bloqueia ✅ |
| `cat ".env"` | **passa** ❌ — no JSON a aspa vira `\"` e a regex não reconhece o `\` como delimitador |
| `cat .env*` · `cat .en?` | **passa** ❌ — glob |
| `python3 -c "open('.'+'env')"` | **passa** ❌ — ver S1 |

- **Mitigação existente:** as regras `Read(./.env)` também valem para `cat`/`head`/`tail` no
  Bash (doc) e o sandbox nega `./.env`. O hook é a 3ª camada, mas a documentação do template o
  apresenta como a principal.
- **Correção:** extrair o comando com `jq -r '.tool_input.command'` (sem escape JSON),
  bloquear também `\.env[*?]` e manter a documentação honesta sobre o limite do hook.

### S8 — Baixa — Falsos positivos do hook

- **Testado:** `jq '.key' config.json`, `jq -r '.data.api.key'` e `rg -n secrets/ docs` são
  **bloqueados**, porque a regex de extensão `.key` não exige caminho antes.
- **Correção:** exigir um nome de arquivo antes da extensão (`[[:alnum:]_-]\.key`).

### S9 — Média — Lista `deny` incompleta

- **Problema:** a lista nega `.env`, `.env.local`, `.env.*.local`, `.env.development`,
  `.env.staging` e `.env.production`, mas não `.env.test`, `.env.ci`, `.env.prod`, `*.p12`,
  `*.pfx` (que o hook cobre) nem `id_rsa*`/`id_ed25519*`.
- **Correção:** completar a lista. Não dá para usar `Read(./.env.*)`, porque `deny` vence
  `allow` e isso bloquearia também o `.env.example`.

### S10 — Média — pre-commit fixado por tag

- **Onde:** `.pre-commit-config.yaml` (`rev: v6.0.0`, `v8.30.1`…).
- **Por que importa:** em março de 2026, 75–76 tags do `aquasecurity/trivy-action` foram
  reescritas para apontar a código malicioso (CVE-2026-33634), e só quem fixava SHA ficou
  protegido ([Aqua](https://www.aquasec.com/blog/trivy-supply-chain-attack-what-you-need-to-know/),
  [Snyk](https://snyk.io/articles/trivy-github-actions-supply-chain-compromise/)). O template
  fixa as actions por SHA, mas não os hooks do pre-commit, que rodam na sua máquina.
- **Correção:** `pre-commit autoupdate --freeze` (troca a tag pelo SHA e mantém a tag em
  comentário). O Dependabot suporta o ecossistema pre-commit
  ([opções do Dependabot](https://docs.github.com/en/code-security/dependabot/working-with-dependabot/dependabot-options-reference)).
  **NÃO VERIFICADO:** o valor exato de `package-ecosystem` no YAML (a página foi truncada na
  leitura). Confirme antes de adicionar.

### S11 — Baixa — Dependabot sem `cooldown`

- `cooldown` adia atualizações de versão recém-publicadas (não as de segurança) por N dias
  (doc), o que reduz a chance de adotar uma versão maliciosa logo após o lançamento.
- **Correção:** `cooldown: { default-days: 7 }` em cada ecossistema.

### S12 — Info — O `trivy-action` fixado é legítimo

- **Testado:** o SHA `ed142fd…` é exatamente a tag `v0.36.0`, de 2026-04-22, está na
  `master` e é posterior ao incidente. Instala o Trivy `v0.70.0` (`action.yaml`), não a versão
  comprometida `0.69.4`. O cache do banco de vulnerabilidades vem ligado por padrão (README da action).

### S13 — Média — Documentação de proteção desatualizada

- **Onde:** `README.md` (seção "Proteções da IA") e `docs/prompts/README.md`
  ("Regras Read/Edit **não** valem para o Bash").
- **Fato (doc oficial):** elas **valem** para `cat`, `head`, `tail`, `sed`, `tee` e para os
  alvos de redirecionamento, e **não** valem para `grep -r .` nem para scripts Python/Node.
  Documentação errada leva a decisões erradas, como confiar demais no hook ou de menos nas regras.
- **Correção:** reescrever a tabela de proteções com esses limites reais.

---

## 2. Custo monetário (GitHub)

### C1 — Alta — SARIF em repositório privado

- **Onde:** `security.yml` (job *Vulnerabilities* → `upload-sarif`) e `scorecard.yml`.
- **Fato (doc oficial):** "If you want to use code scanning on private repositories, you need
  a GitHub Code Security license"
  ([about code scanning](https://docs.github.com/en/code-security/code-scanning/introduction-to-code-scanning/about-code-scanning)).
- **Consequência:** em repositório privado sem licença, o passo de upload falha, o job fica
  vermelho e, como *Vulnerabilities* é check obrigatório (`git.md`), o merge trava. A
  alternativa é pagar a licença.
  **NÃO VERIFICADO:** a mensagem exata da falha (não tenho um repositório privado para testar);
  confirme na primeira execução.
- **Correção:** `if: github.event.repository.visibility == 'public'` no upload. Em
  repositório privado, use a saída em tabela do Trivy no log (o `exit-code: 1` continua barrando).
  Scorecard: rodar só em repositório público.

### C2 — Média — Minutos de Actions

- **Fato (doc oficial):** repositório público com runner padrão é **grátis**. Em privado, o
  plano Free inclui **US$ 12/mês** e o Pro **US$ 18/mês** de computação
  ([billing](https://docs.github.com/en/billing/concepts/product-billing/github-actions)). Pela
  tarifa Linux de US$ 0,006/min citada na página, isso dá ~2.000 e ~3.000 minutos (estimativa minha).
- **Desperdício atual:** cada push em PR roda 6 jobs (CI 3 + Security 3); cada push na `main`
  roda +2 (Release, Scorecard). Os jobs *Test* e *Build* sobem um runner só para imprimir
  `TODO(lang)`. Mudanças só em `docs/` disparam tudo. Os crons semanais rodam para sempre.
- **NÃO VERIFICADO:** se o GitHub arredonda cada job para o minuto cheio (a página atual não diz).
- **Correção:** até existir stack, juntar Test/Build num job só ou pulá-los. Para docs, usar
  `paths-ignore` **com cuidado**: check obrigatório filtrado por caminho fica "pendente" e
  bloqueia o merge. A solução segura é um job sempre executado que decide internamente o que rodar.

### C3 — Info — gitleaks em organização

- Repositório de organização exige o secret `GITLEAKS_LICENSE` (gratuito); já documentado no
  README (passo 6).

### C5 — Média — Revisão obrigatória para quem trabalha sozinho

- **Onde:** `docs/standards/git.md` ("Require pull request + 1 aprovação (+ Code Owners)") e
  `CODEOWNERS` com um único dono.
- **Problema:** o autor do PR não pode aprovar o próprio PR (comportamento padrão do GitHub;
  a página consultada não traz a frase literal, então trate como **alta confiança, não
  verificado em doc**). Sozinho, você não consegue fazer merge, a não ser que use a exceção de
  administrador, que a doc confirma existir por padrão
  ([protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)).
- **NÃO VERIFICADO:** se a proteção de branch funciona em repositório **privado** no plano
  **Free** (a página não traz a regra de planos).
- **Correção:** documentar um perfil "solo": PR obrigatório + checks obrigatórios, **0**
  aprovações e `/revisar` no lugar do revisor humano.

---

## 3. Recursos (CPU, disco, memória, banda)

### R1 — Média — `make check` pesado em tudo

- **Problema:** `make check` = `lint` (pre-commit em **todos** os arquivos) + `test` +
  `security` (gitleaks no **histórico inteiro** + Trivy com 4 scanners). O AGENTS.md exige
  isso antes de qualquer tarefa ser "pronta", o `/spec` a cada tarefa e o `/loop-seguro` a cada
  iteração (até 25). O custo cresce com o tamanho do repositório e do histórico.
- **NÃO VERIFICADO:** o tamanho do download do banco do Trivy (não medido). O Trivy só
  baixa de novo quando o cache local expira.
- **Correção:** criar `make check-rapido` (pre-commit só nos arquivos alterados + testes) para
  cada iteração e manter o `make check` completo antes do PR.

### R2 — Média — Formatter após cada edição

- **Onde:** `.claude/hooks/format.sh` (PostToolUse `Write|Edit`, timeout 120 s).
- **Problema:** roda `make format` no projeto **inteiro** a cada edição de arquivo de código.
  Em repositório grande, isso dá segundos de CPU e de espera por edição. O caminho do arquivo
  é extraído do JSON com `sed`, o que é frágil (aspas e barras escapadas).
- **Hoje:** inativo, porque `make format` ainda é TODO.
- **Correção:** formatar só o arquivo editado (`jq -r '.tool_input.file_path'` e passar o
  caminho ao formatter).

### R3 — Baixa — gitleaks duplicado

- O hook `gitleaks` do pre-commit (dentro do `make lint`) e o `make security` rodam no mesmo
  `make check`. Basta um dos dois no `check`.

### R4 — Info — Cache na CI

- O pre-commit/action e o trivy-action usam cache por padrão (README das actions). Ponto de
  atenção: o `pre-commit/action` está em **"maintenance-only mode"** e o próprio README
  recomenda o pre-commit.ci (testado: li o README). Ainda funciona, mas não recebe novidades.

---

## 4. Falsos positivos de "pronto"

### P1 — Alta — `make check` verde sem ter verificado nada

- **Testado:** nesta máquina `trivy` e `gitleaks` **não estão instalados** (`command -v`
  vazio). `make security` só imprime "AVISO" e sai com código 0. `make test` é `TODO(lang)`
  e também sai com 0.
- **Consequência:** o AGENTS.md diz "Antes de considerar uma tarefa pronta: `make check` deve
  passar". O agente cumpre a regra e declara "pronto" sem um único teste ou varredura. É
  exatamente o falso positivo que o AGENTS.md tenta evitar ("Nunca diga que algo foi testado…").
- **Correção:** `make check` deve **falhar** (ou imprimir um resumo "NÃO EXECUTADO: testes,
  trivy, gitleaks") quando uma etapa não rodou. No AGENTS.md: "relate quais etapas do
  `make check` foram puladas".

### P2 — Baixa — CI verde com alvos vazios

- Já documentado no README como limitação (anotação `TODO(lang)`), mas os checks obrigatórios
  *Test* e *Build* ficam verdes. Mesma correção do P1, aplicada na CI.

---

## 5. Instruções, skills e tokens

### I1 — Média — `discernment-nudge` (adicionada nesta sessão)

- **Medido:** a descrição tem 1.035 bytes, mais que todas as outras descrições de skills
  automáticas somadas (~1.600 bytes). Ela entra no contexto de **toda** sessão. Quando
  dispara, carrega o corpo de 10,6 KB (~2,5–3 mil tokens).
- **Conflito:** o AGENTS.md pede "Respostas curtas", e a skill acrescenta perguntas ao fim de
  respostas substantivas (no máximo uma vez por conversa).
- **Decisão sua:** manter (vale para o seu uso com planos de negócio), mover para o seu
  `~/.claude/skills` (fora do template) ou remover. Não editei o arquivo de terceiros.

### I2 — Média — "Corrija tudo" no 03-feature

- **Onde:** `docs/prompts/03-feature.md`: "Ao final rode `make check` e corrija tudo".
- **Risco:** o agente mexe em código fora do escopo ou "conserta" teste quebrado relaxando a
  asserção. O 10-loop proíbe isso; o 03 não.
- **Correção:** "Corrija o que a sua mudança quebrou. Falha preexistente: reporte, não corrija.
  Nunca apague nem enfraqueça testes".

### I3 — Baixa — 07-verificar e CI

- Sugere "Pipeline de CI: dispare o workflow", o que exige push (que está em `ask` e é
  proibido pela skill `/verificar`) e gasta minutos. Esclarecer: "peça para eu disparar".

### I4 — Baixa — Skills automáticas novas

- `/avaliar-externo` e `/briefing` podem ser acionadas pelo modelo a partir da descrição.
  Custo pequeno (~330 bytes cada). Se dispararem demais, adicione
  `disable-model-invocation: true`.

### I5 — Info — Boas instruções já presentes

- "Economia de contexto" no AGENTS.md, a proibição de subagentes sem pedido, "achado sem
  cenário concreto não é achado" (04-review), o limite de iterações do loop e o
  `BASH_MAX_OUTPUT_LENGTH: 12000`. Mantê-los.

### I6 — Info — Custo fixo de contexto é baixo

- **Medido:** o AGENTS.md mais o CLAUDE.md somam 4,7 KB (~1,2–1,5 mil tokens por sessão); as
  descrições das skills automáticas somam ~2,6 KB. As skills com `disable-model-invocation`
  (`/revisar`, `/spec`, `/verificar`, `/loop-seguro`, `/estudar`) não ocupam contexto até
  serem chamadas. O `docs/` só é lido sob demanda.

### O1 — Baixa — `init-project.sh`

- Substitui placeholders em **todo** arquivo de texto (exceto `.git`); se rodar depois de
  instalar dependências (`node_modules`, `.venv`), varre e reescreve tudo isso. Rode logo após
  clonar, como o README já indica. O `rm -rf .git` é feito só com confirmação (ok).

---

## 6. Inventário: o que cada peça faz, quando ativa e como ligar

| Peça | O que faz | Como e quando ativa | Precisa de ação manual? |
| ---- | --------- | ------------------- | ----------------------- |
| `AGENTS.md` + `CLAUDE.md` | Regras do agente | Automático, carregado em toda sessão do Claude Code | Não |
| `.claude/settings.json` → `deny`/`ask` | Bloqueia ou pede confirmação | Automático, desde o início | Não |
| `.claude/settings.json` → `allow` | Libera comandos sem perguntar | Só depois de você **confiar na pasta** (doc: *workspace trust*) | Aceitar o diálogo de confiança |
| Sandbox | Isola o Bash (arquivos e rede) | Automático **se** `bubblewrap` e `socat` existirem (Linux) | `sudo apt install bubblewrap socat`; conferir com `/sandbox` |
| Hook `protect-secrets.sh` | Bloqueia shell que cita `.env`/`secrets/`/chaves | Automático, antes de **todo** comando Bash | Não |
| Hook `format.sh` | Roda `make format` | Automático, após cada Write/Edit, **só** quando `make format` estiver implementado | Implementar `make format` na stack |
| Skills automáticas: `/planejar`, `/adr`, `/avaliar-externo`, `/briefing`, `discernment-nudge` | Fluxos guiados | Você digita `/nome` **ou** o modelo aciona pela descrição | Não |
| Skills manuais: `/spec`, `/revisar`, `/verificar`, `/loop-seguro`, `/estudar` | Fluxos guiados | **Só** quando você digita `/nome` | Não |
| Plugins recomendados (`docs/prompts/README.md`) | Agentes e comandos extras | Depois de instalados | `/plugin` → avaliar com `/avaliar-externo` → instalar |
| `pre-commit` (gitleaks, Conventional Commits, lint de md/yaml/shell) | Barra commit ruim | Automático em `git commit`, **depois** do `make setup` | `pipx install pre-commit` + `make setup` |
| `Makefile` | Interface única de comandos | Manual (`make <alvo>`) e pela CI | Implementar os alvos `TODO(lang)` |
| `make security` | gitleaks + Trivy | Manual / `make check` | Instalar `gitleaks` e `trivy` (sem eles: só aviso, ver P1) |
| CI (`ci.yml`) | Lint, Test, Build | Automático em PR e push na `main` | Subir no GitHub |
| Security (`security.yml`) | Segredos, vulnerabilidades, actionlint | PR, push na `main`, toda segunda 06:00 UTC | Repositório de organização: `GITLEAKS_LICENSE`; privado: ver C1 |
| Release (`release.yml`) | PR de versão + CHANGELOG + SBOM assinado | Push na `main` | Settings → Actions → *Allow GitHub Actions to create and approve pull requests*; aprovar os checks no PR de release |
| Scorecard (`scorecard.yml`) | Nota de segurança da cadeia de suprimentos | Push na `main`, segunda 07:00 UTC, mudança de proteção | Privado: `publish_results: false` (e ver C1) |
| Dependabot | PRs de atualização das actions | Semanal, depois de subir no GitHub | Ligar *Dependabot alerts*; adicionar o ecossistema da stack |
| `CODEOWNERS` | Exige revisão do dono | Só com a proteção de branch configurada | Settings → Branches (ver C5) |
| Templates de issue e PR | Padronizam pedidos e evidências | Ao abrir issue ou PR | Não |
| `scripts/init-project.sh` | Preenche placeholders e reinicia o git | Manual, uma vez | `./scripts/init-project.sh` |
| `docs/` | Padrões, prompts, ADRs, operação | Só quando lido (pela IA ou por você) | Não |

---

## 7. Boas práticas de mercado (fontes públicas) × o que o template cobre

Só listo práticas com fonte pública verificável. "Big tech" aqui significa o que essas
empresas e fundações **publicam**; não afirmo processos internos que não são públicos.

| Área | Prática | Fonte | Template |
| ---- | ------- | ----- | -------- |
| Fluxo | PRs pequenos, revisão focada em design e correção | [Google Engineering Practices](https://google.github.io/eng-practices/) | ✅ CONTRIBUTING (< 400 linhas) |
| Fluxo | Trunk-based development + feature flags | [DORA — capabilities](https://dora.dev/capabilities/trunk-based-development/) | ✅ git.md |
| Métricas | Quatro métricas DORA (frequência de deploy, lead time, taxa de falha, tempo de recuperação) | [dora.dev](https://dora.dev) | ⚠️ citado no guia, sem como medir |
| Confiabilidade | SLO + orçamento de erro + postmortem sem culpados | [Google SRE Book](https://sre.google/sre-book/table-of-contents/) | ⚠️ SLO e postmortem sim; orçamento de erro não aparece |
| Arquitetura | Monólito modular + hexagonal; ADR; C4 | ADR 0002, [c4model.com](https://c4model.com) | ✅ |
| Operação | Twelve-Factor, OpenTelemetry | [12factor.net](https://12factor.net), [opentelemetry.io](https://opentelemetry.io) | ✅ |
| Desenvolvimento seguro | NIST SSDF (SP 800-218) como moldura | [NIST SP 800-218](https://csrc.nist.gov/pubs/sp/800/218/final) | ❌ não citado (as práticas existem, falta o mapa) |
| Segurança de aplicação | OWASP ASVS, modelagem de ameaças STRIDE | [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/) | ✅ |
| IA | OWASP Top 10 para aplicações LLM | [genai.owasp.org](https://genai.owasp.org/llm-top-10/) | ⚠️ threat-model cita riscos de LLM, sem esse mapa |
| Cadeia de suprimentos | Fixar por SHA, SBOM, assinatura, níveis SLSA, Scorecard | [slsa.dev](https://slsa.dev), [Sigstore](https://www.sigstore.dev), [OpenSSF Scorecard](https://scorecard.dev) | ✅ actions · ❌ pre-commit (S10) · ⚠️ proveniência SLSA é TODO |
| Agentes de IA | Menor privilégio, sandbox, hooks determinísticos, humano no loop | [Claude Code — permissões](https://code.claude.com/docs/en/permissions.md), [sandboxing](https://code.claude.com/docs/en/sandboxing.md), [Building effective agents](https://www.anthropic.com/research/building-effective-agents) | ⚠️ desenho certo, `allow` amplo demais (S1–S6) |
| Testes | Pirâmide, teste de comportamento, mutação | testes.md | ✅ · ❌ teste de contrato (não citado) |

**Não feito:** comparação com "padrões internos" de empresas específicas (Google, Meta,
Amazon etc.). **Motivo:** não são públicos, e citar isso seria chute.

---

## Plano de correção

Ordem sugerida (cada item é um PR pequeno; nada foi aplicado):

1. **Permissões (S1, S3–S6, S9):** voltar ao `allow` estreito da versão commitada e
   acrescentar só o necessário; adicionar `failIfUnavailable`, `allowUnsandboxedCommands: false`
   e `filesystem.denyRead` (S2).
2. **Falso "pronto" (P1/P2):** `make check` falha ou lista explicitamente o que não rodou.
3. **CI em repositório privado (C1, C2, C5):** upload de SARIF só em repositório público;
   perfil "solo" na proteção de branch.
4. **Hook (S7, S8) e documentação (S13).**
5. **Cadeia de suprimentos (S10, S11):** `pre-commit autoupdate --freeze` + `cooldown`.
6. **Recursos e instruções (R1–R3, I1–I3).**

## Fontes consultadas nesta auditoria

- Claude Code: [settings](https://code.claude.com/docs/en/settings),
  [permissions](https://code.claude.com/docs/en/permissions.md),
  [sandboxing](https://code.claude.com/docs/en/sandboxing.md)
- GitHub: [code scanning](https://docs.github.com/en/code-security/code-scanning/introduction-to-code-scanning/about-code-scanning),
  [billing de Actions](https://docs.github.com/en/billing/concepts/product-billing/github-actions),
  [Dependabot options](https://docs.github.com/en/code-security/dependabot/working-with-dependabot/dependabot-options-reference),
  [protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- Incidente Trivy: [Aqua](https://www.aquasec.com/blog/trivy-supply-chain-attack-what-you-need-to-know/),
  [Snyk](https://snyk.io/articles/trivy-github-actions-supply-chain-compromise/),
  [Legit Security](https://www.legitsecurity.com/blog/the-trivy-supply-chain-compromise-what-happened-and-playbooks-to-respond)
- READMEs: [pre-commit/action](https://github.com/pre-commit/action),
  [trivy-action@v0.36.0](https://github.com/aquasecurity/trivy-action/tree/ed142fd0673e97e23eac54620cfb913e5ce36c25)
