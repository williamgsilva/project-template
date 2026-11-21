---
name: depurar
description: Depura um bug ou teste falhando pela causa raiz (reproduzir, hipóteses, teste que falha, menor correção) seguindo docs/prompts/14-depurar.md. Use quando um teste falhar, um erro aparecer ou algo funcionar só às vezes.
argument-hint: "<o que acontece × o que deveria acontecer>"
---

Problema: $ARGUMENTS

Siga exatamente `docs/prompts/14-depurar.md` (leia o arquivo agora).

- Reproduza antes de propor correção; uma mudança por tentativa.
- Nunca apague, pule ou afrouxe teste para "passar".
- Três tentativas sem sucesso: pare, resuma o que foi descartado e pergunte.
