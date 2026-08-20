$ErrorActionPreference = "Stop"

$repo = "lzvsrx/aesdivinus-multiplataforma"
$artifactName = "AESDIVINUS_iPadAir_iOS12_5_8_unsigned_ipa"
$outputDir = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "builds\ios-ipad-air"

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

if (!(Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI (gh) nao encontrado. Instale o GitHub CLI ou baixe o artifact pelo site do GitHub Actions."
}

$runId = gh run list --repo $repo --workflow "Build iOS IPA" --branch main --status success --limit 1 --json databaseId --jq ".[0].databaseId"
if ([string]::IsNullOrWhiteSpace($runId)) {
    throw "Nenhuma execucao bem-sucedida do workflow Build iOS IPA foi encontrada."
}

gh run download $runId --repo $repo --name $artifactName --dir $outputDir

$ipa = Get-ChildItem $outputDir -Filter "*.ipa" -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($null -eq $ipa) {
    throw "Artifact baixado, mas nenhum .ipa foi encontrado em $outputDir."
}

Write-Host "IPA baixado em: $($ipa.FullName)"
Write-Host "Abra o Sideloadly e arraste este arquivo para instalar no iPad: $($ipa.FullName)"
