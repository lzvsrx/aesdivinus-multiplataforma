$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputDir = Join-Path $projectRoot "builds\windows"
$outputExe = Join-Path $outputDir "AESDIVINUS.exe"

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

Get-Process AESDIVINUS -ErrorAction SilentlyContinue | Stop-Process -Force
if (Test-Path $outputExe) {
    Remove-Item -LiteralPath $outputExe -Force
}

$args = "--headless --path `"$projectRoot`" --export-release `"Windows Desktop`" `"$outputExe`""
$godot = Start-Process -FilePath "godot.exe" -ArgumentList $args -Wait -PassThru -NoNewWindow
$godotExitCode = $godot.ExitCode
if ($godotExitCode -ne 0) {
    throw "Godot falhou ao exportar Windows. Codigo: $godotExitCode"
}

for ($i = 0; $i -lt 20 -and !(Test-Path $outputExe); $i++) {
    Start-Sleep -Milliseconds 250
}

if (!(Test-Path $outputExe)) {
    throw "Nao foi possivel gerar o executavel. Verifique se os templates de exportacao Windows do Godot estao instalados."
}

Write-Host "Build gerado em: $outputExe"
exit 0
