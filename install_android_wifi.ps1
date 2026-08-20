$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$apk = Join-Path $projectRoot "builds\android\AESDIVINUS.apk"
$adb = "C:\android\platform-tools\adb.exe"

if (!(Test-Path $adb)) {
    throw "adb nao encontrado em $adb. Instale Android platform-tools."
}
if (!(Test-Path $apk)) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $projectRoot "export_android.ps1")
}

Write-Host "AESDIVINUS Android Wi-Fi installer"
Write-Host "No Android: Configuracoes > Sistema > Opcoes do desenvolvedor > Depuracao sem fio."
Write-Host "Se o aparelho ainda nao estiver pareado, use 'Parear dispositivo com codigo' e informe abaixo."

$pairEndpoint = Read-Host "IP:porta de PAREAMENTO (enter para pular)"
if ($pairEndpoint.Trim().Length -gt 0) {
    $pairCode = Read-Host "Codigo de pareamento"
    & $adb pair $pairEndpoint.Trim() $pairCode.Trim()
    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao parear Android em $pairEndpoint."
    }
}

$connectEndpoint = Read-Host "IP:porta de CONEXAO/Depuracao sem fio"
if ($connectEndpoint.Trim().Length -eq 0) {
    throw "Informe o IP:porta de conexao mostrado na tela de Depuracao sem fio."
}

& $adb connect $connectEndpoint.Trim()
if ($LASTEXITCODE -ne 0) {
    throw "Falha ao conectar via adb em $connectEndpoint."
}

& $adb devices -l
& $adb install -r $apk
if ($LASTEXITCODE -ne 0) {
    throw "Falha ao instalar AESDIVINUS.apk no Android via Wi-Fi."
}

Write-Host "AESDIVINUS instalado no Android via depuracao Wi-Fi."
