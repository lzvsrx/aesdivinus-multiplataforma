# AESDIVINUS - Pesquisa e Melhorias de Historia/Jogabilidade

Data: 2026-08-20

Este documento transforma a pesquisa em melhorias praticas para o prototipo atual.

## Fontes pesquisadas

- Game Accessibility Guidelines: controles digitais, legibilidade, informacao visual para sons e texto ajustavel.
- IGDA Game Accessibility SIG: tutoriais dentro do jogo, feedback automatico e orientacao de objetivos.
- Godot Docs - State design pattern: separar estados quando o comportamento crescer.
- GameDeveloper - branching narrative: escolhas significativas sem aumentar demais o escopo.
- GameDeveloper - pilares de combate: cada habilidade deve ter funcao propria e risco/recompensa.
- Godot Docs - Performance: acompanhar FPS, objetos desenhados, draw calls e uso de memoria para ajustar a qualidade.
- Godot Docs - otimizacao geral: em hardware fraco, reduzir efeitos, objetos visuais simultaneos e custo por quadro antes de complicar o sistema.

## Diagnostico do jogo atual

O prototipo ja possui:

- Prologo em tres areas da Floresta Wood.
- Personagens principais selecionaveis.
- Lealdade, coragem, stamina e Marca Divina.
- Combate com ataque leve, pesado, esquiva, bloqueio e chefe.
- Telas de sistemas, Codex, missoes, forja e mapa.

O que mais melhora a experiencia agora:

- Dar consequencia visivel para lealdade/coragem.
- Ensinar controles dentro da cena, nao so no README.
- Fazer inimigos telegrapharem ataques antes do dano.
- Ligar historia e gameplay: Marca Divina deve ter custo narrativo.
- Criar escolhas pequenas no prologo que alteram dialogos e recompensas.

## Melhorias de historia

### 1. Escolhas curtas no prologo

Na Floresta Wood 1.1:

- Ajudar Ethan a investigar a trilha.
- Ignorar e seguir rapido.

Consequencia:

- Ajudar: +Lealdade, tutorial de interacao.
- Ignorar: menos dialogo, combate mais cedo.

Na Floresta Wood 1.2:

- Salvar soldado ferido.
- Perseguir barbaro.
- Proteger companheiro.

Consequencia:

- Soldado: item de cura ou lore.
- Barbaro: combate extra e material.
- Companheiro: +Lealdade e dialogo futuro.

Na Floresta Wood 1.3:

- Usar Marca Divina antes do Ogre.
- Guardar a Marca.

Consequencia:

- Usar: combate mais facil, coragem reduzida depois.
- Guardar: combate mais dificil, dialogo de Elric muda.

### 2. Arcos por personagem

- William: honra contra sobrevivencia.
- Ethan: medo controlado por agilidade.
- Donovan: dever militar e culpa.
- Albert: politica de Gradon e manipulacao.
- Hilda: independencia e sobrevivencia.
- Elric: custo espiritual da Marca Divina.

### 3. Gradon como hub

Depois do prologo, Gradon deve abrir:

- Conselho: decisoes politicas.
- Forja: equipamentos e Robert Smith.
- Aposentos Militares: treino e missoes.
- Castelo: intriga principal.

## Melhorias de jogabilidade

### 1. Combate com risco e recompensa

- Ataque leve: seguro, baixo dano, combo.
- Ataque pesado: lento, quebra defesa, gasta stamina.
- Bloqueio: reduz dano, gasta stamina.
- Esquiva: reposiciona, janela curta de invulnerabilidade.
- Marca Divina: alto impacto, cooldown e custo de coragem.

### 2. Inimigos com funcao clara

- Barbaro: inimigo basico para aprender ataque.
- Canis Ferox: pressiona distancia e ensina esquiva.
- Lanceiro: controla alcance.
- Homines Corrupti: aplica medo/coragem.
- Bestia Ignis: projeteis e area.
- Ogre Larva Belli: chefe de telegraph, pulo e bloqueio.

### 3. Feedback e acessibilidade

- Flash ou icone antes de ataques inimigos.
- Texto de objetivo sempre visivel.
- Indicador visual para sons importantes.
- Tamanho de texto ajustavel.
- Alto contraste para inimigos, aliados e itens.
- Remapeamento futuro de teclas.

## Implementado agora

- Nova aba dentro do jogo: `DIRECAO`, atalho `T`.
- Missoes agora mostram ganchos de historia e jogabilidade.
- Configuracoes de hardware na tela `CONFIGURACOES`, atalho `P`.
- Presets Compatibilidade, Baixo, Medio, Alto e Ultra alteram densidade de cenario, particulas e transicoes.
- Limite de FPS, escala grafica, texto maior, alto contraste, cenario animado e impacto de camera sao salvos no banco local.
- README atualizado com a nova tela.
- Build Windows validado.

## Proxima implementacao recomendada

1. Criar escolhas reais em Wood 1.1 e Wood 1.2.
2. Adicionar telegraph visual antes do ataque inimigo.
3. Adicionar tutorial contextual por area.
4. Separar estados do jogador/inimigo em scripts quando o prototipo crescer.
5. Criar sprites Aseprite e retratos de dialogo.
