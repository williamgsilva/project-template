# 04 — Code review

```text
Revise as mudanças desta branch em relação à main (git diff main...HEAD).
Use AGENTS.md e docs/standards/ como critério.

Procure, nesta ordem de prioridade:
1. Bugs e casos de borda (nulos, concorrência, erros não tratados, off-by-one, timezone).
2. Segurança (OWASP Top 10: injeção, autorização/IDOR, segredos, dados sensíveis em log, validação de entrada).
3. Violações de arquitetura (regra de dependência entre camadas e módulos).
4. Testes ausentes ou fracos para o comportamento alterado.
5. Performance (N+1, falta de paginação/timeout/índice).
6. Legibilidade e padrões (nomes, tamanho de funções, duplicação).

Para cada achado: arquivo:linha, severidade (alta/média/baixa), cenário concreto de falha e sugestão de correção.
Não liste preferências de estilo que o formatter/linter já cobre. Se não houver problemas em uma categoria, diga.
```
