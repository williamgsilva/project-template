# 12 — Briefing: transformar seus planos em um documento de trabalho

Use quando você quiser **passar um plano, ideia ou objetivo** para a IA (negócio, produto,
estudo, carreira). Diferente de [01-descoberta](01-descoberta.md), que levanta requisitos de
software, o briefing registra **o que você quer e por quê**, para servir de contexto
compartilhado nas próximas conversas.

```text
Tema: <nome curto do plano>
Despejo: <escreva do jeito que vier: objetivos, ideias, números, medos, prazos, links>

1. Leia o despejo inteiro antes de perguntar. Não reorganize ainda.
2. Faça de 5 a 10 perguntas NUMERADAS, das que mais mudam o plano para as que menos.
   Eu respondo em formato curto ("1: sim, 2: até março, 3: não sei").
   Cubra só o que faltar: resultado esperado e como medir, prazo, orçamento/recursos,
   restrições, quem decide, o que já foi tentado, o que está fora de escopo.
3. Separe sempre FATO (eu disse) de PREMISSA (você inferiu). Nunca promova premissa a fato.
4. Números e estimativas que você sugerir: diga a base (fonte ou raciocínio) e marque como
   premissa a validar.
5. Quando as respostas mostrarem que dá para discutir trade-offs sem explicar o básico,
   proponha o documento. Antes de gravar, mostre só a estrutura e espere meu ok.

Grave em docs/planos/<AAAA-MM-DD>-<slug>.md seguindo o modelo de docs/planos/README.md.
Plano existente com o mesmo tema: atualize em vez de criar outro, e registre a mudança no
histórico do próprio documento.
```

Boas práticas:

- **Despeje sem organizar.** O trabalho de estruturar é da IA; o seu é dar contexto.
- **Responda curto e numerado.** Economiza tempo dos dois lados.
- **O documento é a memória.** Em conversas futuras, peça "leia docs/planos/<arquivo>" em vez
  de repetir o contexto.
- Decisão técnica que sair do plano vira ADR (`/adr`); feature vira spec (`/spec`).
