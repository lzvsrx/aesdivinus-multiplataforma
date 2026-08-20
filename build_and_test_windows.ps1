$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$exe = Join-Path $projectRoot "builds\windows\AESDIVINUS.exe"

Get-Process AESDIVINUS -ErrorAction SilentlyContinue | Stop-Process -Force
godot.exe --headless --path $projectRoot -- --smoke-test
$godotExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { $LASTEXITCODE }
if ($godotExitCode -ne 0) {
    throw "Smoke test do projeto falhou com codigo $godotExitCode."
}

$exportScript = Join-Path $projectRoot "export_windows.ps1"
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $exportScript
if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
    throw "Exportacao Windows falhou com codigo $LASTEXITCODE."
}

if (!(Test-Path $exe)) {
    throw "Build nao encontrado: $exe"
}

$process = Start-Process -FilePath (Resolve-Path $exe) -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 4
if ($process.HasExited) {
    throw "Teste de inicializacao do executavel falhou com codigo $($process.ExitCode)."
}
Stop-Process -Id $process.Id -Force
Start-Sleep -Milliseconds 250

Write-Host "Build Windows validado: $exe"
