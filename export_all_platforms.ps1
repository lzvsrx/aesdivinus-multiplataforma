$ErrorActionPreference = "Continue"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$scripts = @(
    "export_windows.ps1",
    "export_linux.ps1",
    "export_android.ps1",
    "export_ios.ps1"
)

godot.exe --headless --path $projectRoot -- --smoke-test
if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
    throw "Smoke test falhou. Exportacao cancelada."
}

$failures = @()
foreach ($script in $scripts) {
    $path = Join-Path $projectRoot $script
    Write-Host ""
    Write-Host "== Exportando com $script =="
    try {
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $path
        if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
            throw "Codigo de saida $LASTEXITCODE"
        }
    } catch {
        $failures += "${script}: $($_.Exception.Message)"
        Write-Warning $failures[-1]
    }
}

if ($failures.Count -gt 0) {
    Write-Host ""
    Write-Warning "Algumas plataformas nao foram exportadas nesta maquina:"
    foreach ($failure in $failures) {
        Write-Warning $failure
    }
    exit 1
}

Write-Host "Todas as plataformas disponiveis foram exportadas com sucesso."
