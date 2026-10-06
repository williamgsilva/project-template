# Glossário (linguagem ubíqua)

Termos do **negócio** usados no código, nos testes, na documentação e nas conversas.
Um termo, um significado. Se o time usa duas palavras para a mesma coisa, escolha uma aqui.

A IA também consulta este arquivo: termos bem definidos geram nomes de código corretos.

| Termo | Definição | Nome no código | Módulo | Não confundir com |
| ----- | --------- | -------------- | ------ | ----------------- |
| *Exemplo:* Pedido | Solicitação de compra confirmada pelo cliente, com itens e valor total | `Order` | `orders` | Carrinho (ainda não confirmado) |

## Regras

- Adicione o termo **antes** de criar a classe/tabela/endpoint com esse nome.
- Nome no código em inglês (ver [codigo.md](standards/codigo.md)); definição em português.
- O mesmo termo pode ter significados diferentes em módulos (bounded contexts) diferentes:
  registre um por linha, indicando o módulo.
