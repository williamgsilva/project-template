# Comece aqui — do zero ao primeiro deploy

Este é o roteiro para iniciar (ou corrigir) um projeto usando este template.
Siga as fases **em ordem**. Cada fase tem uma saída concreta; não avance sem ela.

```text
Fase 0  Ambiente        → máquina pronta, ferramentas instaladas
Fase 1  Descoberta      → problema, usuários e requisitos escritos
Fase 2  Arquitetura     → stack escolhida + ADRs + visão C4
Fase 3  Alicerce        → repo, CI, segurança, observabilidade funcionando ANTES de feature
Fase 4  Walking skeleton→ 1 fluxo ponta a ponta, mínimo, em produção (ou staging)
Fase 5  Iteração        → features pequenas, PRs pequenos, sempre verde
```

---

## Fase 0 — Ambiente

Ferramentas base (todas open source e gratuitas):

| Ferramenta                                          | Para quê                                   |
| --------------------------------------------------- | ------------------------------------------ |
| `git`                                               | Versionamento                              |
| `make`                                              | Interface única de comandos                |
| [`pre-commit`](https://pre-commit.com)              | Hooks de qualidade/segurança antes do commit |
| [`gitleaks`](https://github.com/gitleaks/gitleaks)  | Detecta segredos vazados                   |
| [`trivy`](https://trivy.dev)                        | Vulnerabilidades em deps, imagens, IaC     |
| Docker / Podman                                     | Ambientes reproduzíveis                    |
| [`mise`](https://mise.jdx.dev) (opcional)           | Gerencia versões de linguagens por projeto |

Instalação rápida do `pre-commit` (exige Python): `pipx install pre-commit`.

---

## Fase 1 — Descoberta (antes de qualquer código)

**Objetivo:** saber *o que* construir e *por quê*. Erros aqui custam 100x mais depois.

1. Preencha [docs/architecture/overview.md](architecture/overview.md) seções 1–3
   (contexto, objetivos, requisitos não funcionais).
2. Use o prompt [prompts/01-descoberta.md](prompts/01-descoberta.md) com a IA
   para ser *entrevistado* — a IA faz as perguntas, você responde.
3. Defina os **requisitos não funcionais com números**: "rápido" não serve;
   "p95 < 300 ms com 100 req/s" serve.

**Saída:** overview.md com contexto, escopo do MVP e NFRs mensuráveis.

---

## Fase 2 — Arquitetura e escolha de stack

**Objetivo:** decisões conscientes e registradas.

1. Use [prompts/02-arquitetura.md](prompts/02-arquitetura.md) para comparar opções.
2. Registre **cada decisão relevante como ADR** em
   [architecture/adr/](architecture/adr/) (copie `0000-template.md`).
   Ex.: linguagem, banco, estilo de arquitetura, autenticação, hospedagem.
3. Complete o diagrama C4 (níveis 1 e 2) no overview.

Critérios para escolher tecnologia (em ordem):

1. **O time domina?** Produtividade > modismo.
2. **Maturidade e comunidade** — releases frequentes, CVEs corrigidas rápido, docs boas.
3. **Licença** — prefira MIT/Apache-2.0/BSD; cuidado com AGPL/BSL/SSPL em produto comercial.
4. **Custo total** — hospedagem, licenças, operação. Open source gerenciado costuma ser o meio-termo ideal.
5. **Adequação ao problema** — p.ex. Go/Rust para alta concorrência, Python para dados/IA,
   TypeScript para web full-stack, Java/Kotlin/C# para corporativo de longa vida.

Padrão recomendado de arquitetura para começar: **monólito modular** com
**arquitetura hexagonal (ports & adapters)** — veja
[ADR 0002](architecture/adr/0002-monolito-modular-hexagonal.md). Microsserviços só
quando houver dor real (escala independente, times independentes).

**Saída:** ADRs aceitos + branch `lang/<stack>` (se ainda não existir).

---

## Fase 3 — Alicerce (fundação)

**Objetivo:** o "chão de fábrica" pronto **antes** da primeira feature.
Este template já entrega a parte genérica; na branch da linguagem complete:

- [ ] `make setup/lint/format/test/build/run` implementados para a stack
- [ ] Formatter + linter + type checker configurados (falham a CI)
- [ ] Framework de testes + cobertura mínima configurada (ex.: 80% no domínio)
- [ ] Dependências **com lockfile** e versões fixas
- [ ] Dockerfile multi-stage, usuário não-root, imagem mínima (distroless/alpine/chainguard)
- [ ] Configuração via variáveis de ambiente (12-factor), `.env.example` atualizado
- [ ] Logs estruturados (JSON) + health check (`/health/live`, `/health/ready`)
- [ ] OpenTelemetry (traces/métricas) — mesmo que exporte só para console no início
- [ ] Dependabot/Renovate configurado para o ecossistema da linguagem
- [ ] Branch protection no GitHub: PR obrigatório, CI verde, 1 aprovação, sem force-push

Padrões a seguir: [standards/](standards/).

**Saída:** repositório em que `make check` passa e a CI está verde.

---

## Fase 4 — Walking skeleton

**Objetivo:** provar a arquitetura de ponta a ponta com o fluxo mais simples possível
(ex.: "criar e listar um item"), passando por **todas as camadas** e com **deploy**.

- Use [prompts/03-feature.md](prompts/03-feature.md).
- Um teste e2e cobrindo o fluxo.
- Deploy automatizado para um ambiente (staging).

**Saída:** URL funcionando, pipeline completo, sem atalhos.

---

## Fase 5 — Iteração contínua

Ciclo por feature:

```text
issue → branch curta → teste (falhando) → código → refatora → PR pequeno → review → merge → deploy
```

- PRs pequenos (< 400 linhas alteradas) e focados.
- Revisão com [prompts/04-review.md](prompts/04-review.md) **antes** do review humano.
- Decisões novas → novo ADR. Mudanças → `CHANGELOG.md`.
- Revisite NFRs a cada release (performance, custos, segurança).

---

## Como trabalhar com IA neste projeto

1. **Contexto fixo:** o arquivo [AGENTS.md](../AGENTS.md) é lido automaticamente
   pela maioria dos agentes (Claude Code lê `CLAUDE.md`, que aponta para ele).
   Mantenha-o curto e atualizado — ele é o "contrato" com a IA.
2. **Planejar antes de codar:** peça plano → revise → só então implemente.
3. **Tarefas pequenas e verificáveis:** "implemente X com testes; rode `make check`".
4. **Nunca aceite sem entender:** peça explicações; você é o responsável pelo código.
5. **Prompts reutilizáveis** ficam em [prompts/](prompts/) — melhore-os com o tempo.

## Fontes para estudo contínuo

| Tema           | Referência                                                             |
| -------------- | ---------------------------------------------------------------------- |
| Arquitetura    | *Clean Architecture* (R. Martin), *Fundamentals of Software Architecture* (Richards & Ford), [c4model.com](https://c4model.com) |
| Código         | *Clean Code*, *Refactoring* (Fowler), *A Philosophy of Software Design* (Ousterhout) |
| DDD            | *Domain-Driven Design Distilled* (Vernon)                              |
| Segurança      | [OWASP Top 10](https://owasp.org/Top10/), [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/), [OWASP Cheat Sheets](https://cheatsheetseries.owasp.org/), [SLSA](https://slsa.dev) |
| Operação       | [The Twelve-Factor App](https://12factor.net), Google SRE Book (gratuito online) |
| Entrega        | *Accelerate* (DORA), [trunkbaseddevelopment.com](https://trunkbaseddevelopment.com) |
| APIs           | [Google API Design Guide](https://cloud.google.com/apis/design), RFC 9457 (Problem Details) |
| Observabilidade| [opentelemetry.io](https://opentelemetry.io/docs/)                     |
