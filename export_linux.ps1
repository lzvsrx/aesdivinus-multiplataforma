$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputDir = Join-Path $projectRoot "builds\linux"
$outputFile = Join-Path $outputDir "AESDIVINUS.x86_64"
$templateDir = Join-Path $env:APPDATA "Godot\export_templates\4.7.1.stable"
$linuxTemplate = Join-Path $templateDir "linux_release.x86_64"

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
if (Test-Path $outputFile) {
    Remove-Item -LiteralPath $outputFile -Force
}
if (!(Test-Path $linuxTemplate)) {
    throw "Template Linux nao encontrado: $linuxTemplate. Instale os Export Templates do Godot 4.7.1 em Editor > Manage Export Templates."
}

$args = "--headless --path `"$projectRoot`" --export-release `"Linux`" `"$outputFile`""
$godot = Start-Process -FilePath "godot.exe" -ArgumentList $args -Wait -PassThru -NoNewWindow
$godotExitCode = $godot.ExitCode
if (!(Test-Path $outputFile)) {
    throw "Build Linux nao encontrado: $outputFile. Codigo Godot: $godotExitCode"
}

Write-Host "Build Linux gerado em: $outputFile"
exit 0
