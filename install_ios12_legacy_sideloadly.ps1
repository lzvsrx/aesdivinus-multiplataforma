$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ipa = Join-Path $projectRoot "builds\ios12-legacy\AESDIVINUS_iOS12_Legacy_unsigned.ipa"
$sideloadly = Join-Path $env:LOCALAPPDATA "Sideloadly\sideloadly.exe"
$ideviceInfo = "C:\Program Files\Epic Games\UE_5.8\Engine\Extras\ThirdPartyNotUE\libimobiledevice\x64\ideviceinfo.exe"

if (!(Test-Path $ipa)) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $projectRoot "download_latest_ios12_legacy_ipa.ps1")
}
if (!(Test-Path $ipa)) {
    throw "IPA legacy iOS 12 nao encontrado: $ipa"
}
if (!(Test-Path $sideloadly)) {
    throw "Sideloadly nao encontrado: $sideloadly"
}

if (Test-Path $ideviceInfo) {
    $productType = & $ideviceInfo -k ProductType
    $productVersion = & $ideviceInfo -k ProductVersion
    $deviceName = & $ideviceInfo -k DeviceName
    Write-Host "Dispositivo conectado: $deviceName / $productType / iOS $productVersion"
    if ($productType -ne "iPad4,1" -or $productVersion -ne "12.5.8") {
        Write-Warning "O IPA foi preparado para iPad Air iPad4,1 com iOS 12.5.8."
    }
}

Write-Host "Abrindo Sideloadly com o IPA legacy compatível:"
Write-Host $ipa
Write-Host "No Sideloadly, selecione o iPad conectado, informe sua Apple ID e clique em Start para assinar e instalar."
Start-Process -FilePath $sideloadly -ArgumentList @($ipa)
