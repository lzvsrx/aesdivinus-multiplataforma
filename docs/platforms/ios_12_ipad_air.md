# AESDIVINUS no iPad Air com iOS 12.5.8

Este alvo foi preparado para o iPad Air de primeira geracao no limite maximo do sistema dele, iOS 12.5.8.

## Configuracao aplicada

- Renderizador do projeto em `gl_compatibility`.
- Preset iOS com `application/min_ios_version="12.5.8"`.
- Preset iOS limitado para iPad com `application/targeted_device_family=1`.
- Bundle ID configurado como `com.aesdivinus.game`.
- Recursos de desempenho A12/Gaming Tier desativados, pois o iPad Air original usa chip A7.
- Controles de toque ja existem para menus e gameplay quando o jogo roda em iOS.

## Limite importante

O Godot 4.7 exporta iOS pelo Xcode e exige macOS, Xcode, App Store Team ID e Bundle Identifier. No Windows, este projeto consegue validar o conteudo exportavel em `.pck`, mas nao consegue gerar e instalar um app iOS real.

Tambem existe um limite tecnico de runtime: Godot 4.7 moderno pode nao conseguir rodar nativamente em iOS 12.5.8, mesmo com `min_ios_version` configurado. Se o app abrir tela preta ou fechar no iPad Air, o caminho correto para compatibilidade real com esse aparelho antigo e portar uma versao legacy do jogo para Godot 3.x ou compilar templates iOS customizados compatíveis com esse hardware.

## Gerar no macOS

No Mac com Godot 4.7.1, Xcode instalado e Apple Team ID:

```bash
AESDIVINUS_APPLE_TEAM_ID=ABCDE12XYZ ./export_ios_ipad_air.command
```

Depois abra o projeto exportado no Xcode, conecte o iPad Air, selecione o dispositivo e rode o build. Para teste local, uma conta Apple gratuita pode assinar apps de desenvolvimento; para distribuicao, use conta Apple Developer.

## Instalar no iPad Air

No Mac, instale o `ios-deploy`, conecte o iPad por USB, confie no computador no iPad e rode:

```bash
brew install ios-deploy
ios-deploy -c
AESDIVINUS_APPLE_TEAM_ID=ABCDE12XYZ AESDIVINUS_IOS_DEVICE_ID=UDID_DO_IPAD ./install_ios_ipad_air.command
```

O script exporta o projeto iOS, compila com Xcode, assina com o Team ID informado e instala o `.app` no iPad Air.
