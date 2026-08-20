# AESDIVINUS - Guia de Modelagem Aseprite

Este pacote revisa os modelos atuais do jogo para producao em Aseprite.

Os modelos que existem no jogo hoje sao procedurais, desenhados por blocos no Godot. Eles servem como referencia de silhueta, cor e funcao. O proximo passo correto e produzir arquivos `.aseprite` reais seguindo este contrato.

## Padrao de arquivo

- Canvas por frame: `64x64`
- Pivo do personagem: `x=32, y=56`
- Direcao base: olhando para a direita
- Exportacao: spritesheet PNG + JSON Hash
- Escala no jogo: pixel perfect, sem filtro
- Fundo: transparente
- Origem dos nomes: personagens listados no documento inicial

## Camadas obrigatorias

1. `shadow`
2. `body`
3. `head`
4. `hair`
5. `clothes`
6. `armor_or_cloak`
7. `weapon`
8. `divine_mark_fx`
9. `hit_flash`

## Tags obrigatorias

- `idle`: 6 frames
- `walk`: 8 frames
- `run`: 8 frames
- `jump`: 4 frames
- `fall`: 4 frames
- `land`: 3 frames
- `attack_1`: 5 frames
- `attack_2`: 5 frames
- `attack_3`: 6 frames
- `heavy_attack`: 7 frames
- `air_attack`: 5 frames
- `dodge`: 5 frames
- `block`: 4 frames
- `hurt`: 4 frames
- `death`: 8 frames
- `interact`: 4 frames
- `special`: 8 frames

## Personagens revisados

- William: pronto como referencia, falta `william.aseprite`.
- Ethan: pronto como referencia, falta `ethan.aseprite`.
- Donovan: pronto como referencia, falta `donovan.aseprite`.
- Albert: pronto como referencia, falta `albert.aseprite`.
- Hilda: pronto como referencia, falta `hilda.aseprite`.
- Elric: pronto como referencia, falta `elric.aseprite`.

## Arquivos deste pacote

- `aesdivinus_palette.gpl`: paleta base para importar no Aseprite.
- `character_specs.json`: especificacao de cada personagem.
- `character_model_review.md`: revisao visual e lista do que melhorar.
- `export_contract.md`: como exportar do Aseprite para o Godot.
