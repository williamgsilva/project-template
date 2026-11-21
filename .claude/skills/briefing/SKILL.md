---
name: briefing
description: Transforma planos, ideias ou objetivos que o usuário despeja (negócio, produto, estudo, carreira) em um documento de trabalho em docs/planos/, com perguntas numeradas, fatos separados de premissas, decisões e próximos passos. Use quando o usuário disser que vai passar planos, ideias ou objetivos, ou pedir para registrá-los.
argument-hint: "<tema> [despejo livre do plano]"
---

Tema: $ARGUMENTS

Siga exatamente o prompt de `docs/prompts/12-briefing.md` (leia o arquivo agora) e o modelo
de `docs/planos/README.md`.

- Perguntas numeradas, no máximo 10 por rodada; aceite respostas curtas.
- Antes de gravar, mostre só a estrutura e espere meu ok.
- Já existe plano sobre o tema em `docs/planos/`? Atualize esse arquivo em vez de criar outro.
