$ErrorActionPreference = "Stop"

$repo = "lzvsrx/aesdivinus-multiplataforma"
$artifactName = "AESDIVINUS_iOS12_Legacy_unsigned_ipa"
$outputDir = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "builds\ios12-legacy"

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

if (!(Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI (gh) nao encontrado. Instale o GitHub CLI ou baixe o artifact pelo site do GitHub Actions."
}

$runId = gh run list --repo $repo --workflow "Build iOS 12 Legacy IPA" --branch main --status success --limit 1 --json databaseId --jq ".[0].databaseId"
if ([string]::IsNullOrWhiteSpace($runId)) {
    throw "Nenhuma execucao bem-sucedida do workflow Build iOS 12 Legacy IPA foi encontrada."
}

gh run download $runId --repo $repo --name $artifactName --dir $outputDir

$ipa = Get-ChildItem $outputDir -Filter "*.ipa" -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($null -eq $ipa) {
    throw "Artifact baixado, mas nenhum .ipa foi encontrado em $outputDir."
}

Write-Host "IPA legacy iOS 12 baixado em: $($ipa.FullName)"
Write-Host "Use este IPA no Sideloadly para instalar no iPad Air iOS 12.5.8."
