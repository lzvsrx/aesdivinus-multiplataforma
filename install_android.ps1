$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$apk = Join-Path $projectRoot "builds\android\AESDIVINUS.apk"
$adb = "C:\android\platform-tools\adb.exe"

if (!(Test-Path $apk)) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $projectRoot "export_android.ps1")
}
if (!(Test-Path $adb)) {
    throw "adb nao encontrado em $adb. Instale Android platform-tools."
}

$devices = & $adb devices
$connected = $devices | Where-Object { $_ -match "\tdevice$" }
if (!$connected) {
    throw "Nenhum aparelho/emulador Android conectado. Ative a depuracao USB ou abra um emulador e tente novamente."
}

& $adb install -r $apk
if ($LASTEXITCODE -ne 0) {
    throw "Falha ao instalar AESDIVINUS.apk no Android."
}

Write-Host "AESDIVINUS instalado no Android conectado."
