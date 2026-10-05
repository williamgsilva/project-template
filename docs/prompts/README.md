# Prompts reutilizáveis

Prompts testados para cada fase do projeto. Copie, preencha os `<campos>` e use com
qualquer assistente (Claude Code, Copilot Chat, Cursor…). Melhore-os conforme aprender.

| Arquivo | Fase | Uso |
| ------- | ---- | --- |
| [01-descoberta.md](01-descoberta.md) | Descoberta | IA entrevista você para levantar requisitos |
| [02-arquitetura.md](02-arquitetura.md) | Arquitetura | Comparar opções e gerar ADR |
| [03-feature.md](03-feature.md) | Desenvolvimento | Planejar e implementar uma feature com testes |
| [04-review.md](04-review.md) | Revisão | Code review focado em bugs, segurança e padrões |
| [05-legado.md](05-legado.md) | Correção | Diagnosticar e adequar um projeto existente a este template |

## Boas práticas de prompt

1. **Contexto → tarefa → restrições → formato de saída.** Nessa ordem.
2. **Peça o plano antes do código** e revise o plano.
3. **Uma tarefa por vez**, com critério de pronto verificável ("`make check` passa").
4. **Peça para perguntar** quando faltar informação, em vez de supor.
5. **Referencie arquivos** em vez de colar conteúdo (o agente lê `AGENTS.md` sozinho).
6. **Exija justificativa** para escolhas (bibliotecas, padrões) — e confira as fontes.
