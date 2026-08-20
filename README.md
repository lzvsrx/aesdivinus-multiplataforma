# AESDIVINUS

Prototipo jogavel em Godot 4 criado a partir do documento `jogo aesdivinus (1).pdf`.

## Como jogar

- `A` / `D`: mover
- `Shift`: correr
- `Espaco`: pular
- `J`: ataque leve e combo
- Segurar `J`: ataque pesado carregado
- `K`: esquiva
- `L`: bloquear
- `E`: interagir, confirmar, coletar, avancar dialogo
- `Q`: Marca Divina, voltar em menus, carregar save na tela inicial
- Na criacao de personagem: digite o nome, use `W/S` para trocar campo e `A/D` para trocar personagem, classe ou origem
- `I`: inventario
- `O`: equipamentos
- `C`: personagem / atributos
- `U`: missoes
- `M`: mapa
- `F`: forja
- `V`: mercado
- `P`: configuracoes
- `R`: codex
- `T`: direcao de historia e gameplay
- `B`: banco de dados local
- `F5`: salvar rapido
- `Esc`: pausa

## Telas e sistemas

- Login local
- Cadastro local
- Criacao de personagem
  - Nome customizado digitavel
  - Personagens base: William, Ethan, Donovan, Albert, Hilda, Elric
  - Classes: Cavaleiro, Sentinela, Mercenario, Lanceiro, Arqueiro, Ferreiro, Estrategista, Marcado Divino
  - Origens: Gradon, Fronteira Wood, Castelo de Gradon, Sala do Conselho, Aposentos Militares, Forja de Robert Smith, Casa Exilada, Ordem Divina
  - Modelos pixelados distintos para William, Ethan, Donovan, Albert, Hilda e Elric
  - Codex mostra o status de modelagem e o que ainda precisa melhorar
- Revisao para Aseprite em `art/aseprite/`
  - Paleta `.gpl`
  - Especificacao JSON de canvas, camadas e tags
  - Revisao do que esta pronto e do que ainda falta
- Pesquisa e melhorias de historia/jogabilidade em `docs/design/story_gameplay_research.md`
- Lore do texto anexado integrada em `docs/design/world_lore_from_pasted_text.md`
- Icone/logotipo redesenhado em `icon.svg`
- Guia de identidade visual em `art/branding/aesdivinus_icon_design.md`
- Inicio cinematografico com logo, Marca Divina, floresta e transicoes entre telas
- Telas com acentos visuais unicos mantendo o mesmo tema medieval/divino
  - Login: Portao de Gradon
  - Cadastro: Juramento
  - Criacao: Forja de Herdeiros
  - Menu: Sala do Conselho
  - Sistemas: Arquivos de Gradon
  - Transicoes com cortinas, aneis da Marca Divina e titulo da tela de destino
- Banco local em `user://aesdivinus_db.json` para usuarios, personagens, saves e acoes
- Economia interna do jogo, sem pagamento real
  - Moedas de Gradon ganhas por combate, venda e progresso
  - Mercado para comprar e vender itens com moeda do jogo
  - Forja com receitas de armas e ferramentas
  - Armas Aes: Espada Aes, Lanca Aes e Alabarda Aes com bonus contra corrompidos
  - Armas e ferramentas com niveis de melhoria
  - Pontos de habilidade e instinto para evoluir o personagem
- Menu principal
- HUD de gameplay
- Pausa
- Inventario
- Equipamentos
- Personagem / atributos
- Missoes
- Mapa
- Forja
- Mercado
- Configuracoes
  - Presets de hardware: Compatibilidade, Baixo, Medio, Alto e Ultra
  - Opcoes de desempenho: escala grafica, limite de FPS, particulas, cenario animado e impacto de camera
  - Opcoes visuais/acessibilidade: alto contraste e tamanho do texto
  - Tudo salvo no banco local por usuario/save
- Codex
  - Lore de Homis Corruption, Aes Divinus, armas Aes, marcas angelicais, duques de Gradron e criaturas dos atos futuros
- Direcao de historia e gameplay
- Banco de dados local
- Dialogos
- Game over
- Tela de conclusao do prologo

## Abrir

Abra esta pasta no Godot 4 e execute a cena principal, ou rode:

```powershell
godot.exe --path E:\aesdivinus
```

No Windows, tambem pode usar:

```powershell
.\run_windows.bat
```

## Gerar executavel Windows

```powershell
.\export_windows.ps1
```

O executavel sera criado em:

```text
builds\windows\AESDIVINUS.exe
```

## Gerar e testar no Windows

```powershell
.\build_and_test_windows.bat
```

Esse comando valida o projeto no Godot, gera o `.exe` e confirma que o binario exportado inicializa no Windows.

## Gerar Linux, Android e iOS

Linux:

```powershell
.\export_linux.ps1
```

Android:

```powershell
.\export_android.ps1
```

Instalar no Android conectado por USB ou emulador:

```powershell
.\install_android.ps1
```

iOS:

```powershell
.\export_ios.ps1
```

Todas as plataformas:

```powershell
.\export_all_platforms.ps1
```

Saidas geradas nesta maquina:

```text
builds\windows\AESDIVINUS.exe
builds\linux\AESDIVINUS.x86_64
builds\android\AESDIVINUS.apk
builds\ios\AESDIVINUS.pck
```

Observacoes:

- Windows e Linux usam os Export Templates do Godot.
- Android precisa de Export Templates, Android SDK/JDK e build-tools. O script cria/usa uma keystore local em `android\keystores\aesdivinus-release.keystore`, assina o APK e valida com `apksigner`.
- No Windows, o script de iOS gera o `.pck` do jogo para validar o conteudo exportavel. Para gerar, assinar e rodar o app iOS completo em iPhone/iPad, use macOS com Xcode, Apple Developer Team ID, certificados e provisioning profile.
- O jogo tem controles virtuais de toque em Android/iOS/Web para menus e gameplay.
