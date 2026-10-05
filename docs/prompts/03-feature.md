# 03 — Implementar uma feature

## Passo 1 — Plano

```text
Feature: <issue #N ou descrição>
Critérios de aceite:
- <Dado ... Quando ... Então ...>

Siga AGENTS.md e docs/standards/. Antes de codar, apresente um plano com:
- módulo(s) afetado(s) e arquivos a criar/alterar por camada (domain/application/infrastructure/interfaces);
- portas novas e seus adaptadores;
- casos de teste (unitários, integração, e2e) que provam os critérios de aceite;
- riscos (segurança, performance, migração de dados, compatibilidade de API).
Se algum requisito estiver ambíguo, pergunte antes.
```

## Passo 2 — Implementação

```text
Plano aprovado. Implemente em pequenos passos:
1. Testes do domínio (falhando) → domínio → testes passando.
2. Caso de uso + testes com fakes das portas.
3. Adaptadores + testes de integração.
4. Interface de entrada + teste e2e do fluxo.
Ao final rode `make check` e corrija tudo. Atualize CHANGELOG (Unreleased) e docs/OpenAPI se aplicável.
Resuma o que mudou e sugira a mensagem de commit (Conventional Commits).
```
