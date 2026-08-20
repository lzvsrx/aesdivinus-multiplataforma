param(
    [string]$TeamId = $env:AESDIVINUS_APPLE_TEAM_ID,
    [string]$BundleId = "com.aesdivinus.game"
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputDir = Join-Path $projectRoot "builds\ios-ipad-air"
$outputFile = Join-Path $outputDir "AESDIVINUS_iPadAir_iOS12_5_8.zip"
$xcodeProject = Join-Path $outputDir "AESDIVINUS_iPadAir_iOS12_5_8.xcodeproj"
$presetFile = Join-Path $projectRoot "export_presets.cfg"
$backupFile = Join-Path $env:TEMP ("aesdivinus_export_presets_" + [guid]::NewGuid().ToString("N") + ".cfg")
$templateDir = Join-Path $env:APPDATA "Godot\export_templates\4.7.1.stable"
$iosTemplate = Join-Path $templateDir "ios.zip"

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
if (Test-Path $outputFile) {
    Remove-Item -LiteralPath $outputFile -Force
}
if (!(Test-Path $iosTemplate)) {
    throw "Template iOS nao encontrado: $iosTemplate. Instale os Export Templates do Godot 4.7.1."
}
if ([string]::IsNullOrWhiteSpace($TeamId) -or $TeamId -notmatch "^[A-Za-z0-9]{10}$") {
    throw "Informe um Apple Team ID real de 10 caracteres. Exemplo: .\export_ios_ipad_air.ps1 -TeamId ABCDE12XYZ"
}

Copy-Item -LiteralPath $presetFile -Destination $backupFile -Force
try {
    $content = Get-Content -LiteralPath $presetFile -Raw
    $content = $content -replace 'application/app_store_team_id="[^"]*"', ('application/app_store_team_id="' + $TeamId + '"')
    $content = $content -replace 'application/bundle_identifier="[^"]*"', ('application/bundle_identifier="' + $BundleId + '"')
    $content = $content -replace 'application/identifier="[^"]*"', ('application/identifier="' + $BundleId + '"')
    Set-Content -LiteralPath $presetFile -Value $content -NoNewline

    $args = "--headless --path `"$projectRoot`" --export-release `"iOS`" `"$outputFile`""
    $godot = Start-Process -FilePath "godot.exe" -ArgumentList $args -Wait -PassThru -NoNewWindow
    if (!(Test-Path $outputFile) -and !(Test-Path $xcodeProject)) {
        throw "Nao foi possivel gerar o projeto iOS. Gere no macOS com Xcode instalado e um Team ID valido."
    }

    if (Test-Path $outputFile) {
        Write-Host "Projeto Xcode iPad Air/iOS 12.5.8 gerado em: $outputFile"
    } else {
        Write-Host "Projeto Xcode iPad Air/iOS 12.5.8 gerado em: $outputDir"
    }
    Write-Host "Abra no Xcode, selecione seu iPad Air conectado, confira Signing & Capabilities e rode no aparelho."
    if ($godot.ExitCode -ne 0) {
        Write-Warning "Godot retornou codigo $($godot.ExitCode), normalmente porque o .ipa so pode ser criado no macOS. A pasta Xcode foi gerada."
    }
} finally {
    Copy-Item -LiteralPath $backupFile -Destination $presetFile -Force
    Remove-Item -LiteralPath $backupFile -Force
}
