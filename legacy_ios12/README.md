# AESDIVINUS Legacy iOS 12

Versao leve em Godot 3.6.1 para tentar compatibilidade real com iPad Air de primeira geracao no iOS 12.5.8.

Ela existe porque o build nativo Godot 4.7 usa templates iOS modernos que exigem runtime mais novo que o iOS 12.5.8. Esta versao preserva o tema, criacao de personagem, origem/classe, combate contra Homis Corruption, Marca Divina, moeda e save local em `user://`.

## IPA

O IPA compatível com o iPad Air/iOS 12.5.8 fica em:

```text
..\builds\ios12-legacy\AESDIVINUS_iOS12_Legacy_unsigned.ipa
```

Metadados validados:

- `MinimumOSVersion`: `12.0`
- `UIDeviceFamily`: `2` para iPad
- `UIRequiredDeviceCapabilities`: `arm64`

Para abrir no Sideloadly no Windows:

```powershell
..\install_ios12_legacy_sideloadly.ps1
```
