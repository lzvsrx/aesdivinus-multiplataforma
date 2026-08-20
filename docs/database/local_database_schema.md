# AESDIVINUS - Banco de Dados Local

O jogo usa um banco local em JSON para funcionar sem dependencias externas.

Arquivo em runtime:

```text
user://aesdivinus_db.json
```

No Windows, `user://` e gerenciado pelo Godot dentro da pasta de dados do usuario.

## Estrutura

```json
{
  "version": "1.3.0",
  "users": {
    "email_at_exemplo_com": {
      "id": "email_at_exemplo_com",
      "name": "Jogador",
      "email": "email@exemplo.com",
      "password_hash": "hash-local",
      "created_at": "data",
      "characters": {},
      "settings": {},
      "save": {},
      "actions": []
    }
  },
  "events": []
}
```

## Salva atualmente

- Cadastro de usuario.
- Login.
- Personagem criado.
- Classe, origem e personagem base.
- Inventario.
- Moedas de Gradon.
- Equipamento atual.
- Niveis de armas e ferramentas.
- Pontos de habilidade e instinto.
- Arvore de habilidades e instintos.
- Compra, venda, criacao e melhoria de itens.
- Atributos.
- Mapa atual.
- Checkpoint.
- Posicao.
- Forja.
- Configuracoes.
- Preset de hardware, limite de FPS, escala grafica, contraste, particulas, impacto de camera e cenario animado.
- Uso de Marca Divina.
- Coleta de itens.
- Morte e respawn.
- Conclusao do prologo.

## Observacao

A senha usa hash local simples apenas para prototipo offline. Para multiplayer, loja, nuvem ou conta real, trocar por backend seguro.
