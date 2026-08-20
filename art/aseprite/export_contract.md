# Contrato de Exportacao Aseprite -> Godot

## Nomes esperados

```text
art/characters/william/william.aseprite
art/characters/william/william.png
art/characters/william/william.json
```

Repita para:

- `ethan`
- `donovan`
- `albert`
- `hilda`
- `elric`

## Comando sugerido

Quando o Aseprite estiver instalado:

```powershell
aseprite -b art/characters/william/william.aseprite --sheet art/characters/william/william.png --data art/characters/william/william.json --format json-hash --list-tags --list-layers
```

## Regras para importar no Godot

- Desativar filtro de textura.
- Usar `AnimatedSprite2D` ou `SpriteFrames`.
- Usar `flip_h` para esquerda/direita.
- O JSON deve preservar tags e duracoes.
- Hitbox e hurtbox continuam no Godot, nao no Aseprite.

## Status atual

O jogo ja tem modelos procedurais revisados para guiar os sprites. Ainda nao existem arquivos `.aseprite` reais no projeto porque o Aseprite nao esta instalado no PATH desta maquina.
