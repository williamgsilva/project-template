# 14 — Depurar: causa raiz antes da correção

Use quando um teste falhar, um bug aparecer ou algo "funcionar às vezes". O erro mais caro em
depuração com IA é corrigir o sintoma: o teste passa, a causa continua e volta em outro lugar.

```text
Problema: <o que acontece × o que deveria acontecer; mensagem de erro, comando e saída>

Regras desta sessão:

1. Reproduza primeiro. Rode o comando que mostra o erro e guarde a saída. Sem reprodução,
   não proponha correção: diga o que falta para reproduzir.
2. Leia o erro inteiro (stack trace, linha, valores) antes de abrir arquivos. Depois, o que
   mudou: `git diff`, `git log -p` dos arquivos envolvidos.
3. Escreva até 3 hipóteses, cada uma com a evidência a favor e o teste que a derruba.
   Teste uma por vez, da mais barata para a mais cara. Uma mudança por tentativa.
4. Achou a causa? Primeiro um teste automatizado que falha por causa dela. Depois a menor
   correção que faz esse teste passar, sem refatorar junto.
5. Proibido: apagar ou pular teste, afrouxar assert, `# type: ignore`/`noqa` sem motivo,
   try/except que engole o erro, aumentar timeout sem explicar a lentidão.
6. Três tentativas sem sucesso: pare. Resuma o que foi descartado e por quê, e me pergunte.
   O problema pode estar na premissa (requisito, ambiente, dado), não no código.
7. Ao final: causa raiz em uma frase, por que não foi pega antes, o teste novo e
   `make check-rapido` passando. Se a causa pode existir em outro lugar, liste onde.
```

Boas práticas:

- **Bug que só aparece às vezes** costuma ser tempo (relógio, fuso, concorrência), ordem de
  testes ou estado compartilhado. Fixe o relógio e rode o teste isolado e em sequência.
- **"Funciona na minha máquina"**: compare versões (`uv.lock`), variáveis de ambiente
  (sem ler `.env`: compare com `.env.example`) e caminhos.
- Lição que vale para o projeto inteiro vira regra em `docs/standards/` ou teste, não só
  comentário no código.
