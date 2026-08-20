$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputDir = Join-Path $projectRoot "builds\ios"
$outputFile = Join-Path $outputDir "AESDIVINUS.zip"
$templateDir = Join-Path $env:APPDATA "Godot\export_templates\4.7.1.stable"
$iosTemplate = Join-Path $templateDir "ios.zip"

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
if (Test-Path $outputFile) {
    Remove-Item -LiteralPath $outputFile -Force
}
if (!(Test-Path $iosTemplate)) {
    throw "Template iOS nao encontrado: $iosTemplate. Instale os Export Templates do Godot 4.7.1. Para assinar/rodar em iPhone, use macOS com Xcode e conta Apple Developer."
}

$args = "--headless --path `"$projectRoot`" --export-release `"iOS`" `"$outputFile`""
$godot = Start-Process -FilePath "godot.exe" -ArgumentList $args -Wait -PassThru -NoNewWindow
$godotExitCode = $godot.ExitCode
if (!(Test-Path $outputFile)) {
    $packFile = Join-Path $outputDir "AESDIVINUS.pck"
    $packArgs = "--headless --path `"$projectRoot`" --export-pack `"iOS`" `"$packFile`""
    $packProcess = Start-Process -FilePath "godot.exe" -ArgumentList $packArgs -Wait -PassThru -NoNewWindow
    if (Test-Path $packFile) {
        Write-Warning "Projeto iOS completo nao foi gerado nesta maquina, mas o pack iOS foi gerado em: $packFile"
        Write-Warning "Para app iOS instalavel, use macOS com Xcode, Team ID, certificados e provisioning profile. Codigo Godot: $godotExitCode; codigo pack: $($packProcess.ExitCode)"
        exit 0
    }
    throw "Pacote iOS nao encontrado: $outputFile. Codigo Godot: $godotExitCode"
}

Write-Host "Projeto iOS gerado em: $outputFile"
