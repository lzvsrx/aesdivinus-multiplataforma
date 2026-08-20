$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$outputDir = Join-Path $projectRoot "builds\android"
$outputFile = Join-Path $outputDir "AESDIVINUS.apk"
$templateDir = Join-Path $env:APPDATA "Godot\export_templates\4.7.1.stable"
$androidTemplate = Join-Path $templateDir "android_source.zip"
$keystoreDir = Join-Path $projectRoot "android\keystores"
$releaseKeystore = Join-Path $keystoreDir "aesdivinus-release.keystore"
$releaseAlias = "aesdivinus"
$releasePassword = "Aesdivinus2026"

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
New-Item -ItemType Directory -Force -Path $keystoreDir | Out-Null
if (Test-Path $outputFile) {
    Remove-Item -LiteralPath $outputFile -Force
}
if (!(Test-Path $androidTemplate)) {
    throw "Template Android nao encontrado: $androidTemplate. Instale os Export Templates do Godot 4.7.1 e configure Android SDK/JDK no editor."
}
if (!(Test-Path $releaseKeystore)) {
    & keytool -genkeypair -v -keystore $releaseKeystore -alias $releaseAlias -storepass $releasePassword -keypass $releasePassword -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=AESDIVINUS,O=AESDIVINUS,C=BR"
    if ($LASTEXITCODE -ne 0) {
        throw "Nao foi possivel criar a keystore Android de release."
    }
}

$env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH = $releaseKeystore
$env:GODOT_ANDROID_KEYSTORE_RELEASE_USER = $releaseAlias
$env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD = $releasePassword

$args = "--headless --path `"$projectRoot`" --export-release `"Android APK`" `"$outputFile`""
$godot = Start-Process -FilePath "godot.exe" -ArgumentList $args -Wait -PassThru -NoNewWindow
$godotExitCode = $godot.ExitCode
if ($godotExitCode -ne 0) {
    throw "Godot falhou ao exportar o APK Android. Codigo: $godotExitCode"
}
if (!(Test-Path $outputFile)) {
    $packFile = Join-Path $outputDir "AESDIVINUS.pck"
    $packArgs = "--headless --path `"$projectRoot`" --export-pack `"Android APK`" `"$packFile`""
    Start-Process -FilePath "godot.exe" -ArgumentList $packArgs -Wait -NoNewWindow
    if (Test-Path $packFile) {
        throw "APK Android nao foi gerado pelo exportador local, mas o pack Android foi gerado em $packFile. Verifique Android SDK/JDK/assinatura no Godot. Codigo Godot: $godotExitCode"
    }
    throw "APK Android nao encontrado: $outputFile. Codigo Godot: $godotExitCode"
}

$apksigner = Get-ChildItem "C:\android\build-tools" -Recurse -Filter "apksigner.bat" -ErrorAction SilentlyContinue | Sort-Object { [version]$_.Directory.Name } -Descending | Select-Object -First 1 -ExpandProperty FullName
if ($null -eq $apksigner) {
    throw "apksigner nao encontrado no Android SDK. Instale Android build-tools."
}
& $apksigner verify --verbose $outputFile
if ($LASTEXITCODE -ne 0) {
    throw "APK Android gerado, mas a assinatura/verificacao falhou."
}

Write-Host "APK Android gerado em: $outputFile"
