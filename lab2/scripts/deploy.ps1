<#
.SYNOPSIS
    Разворачивает Node-RED для лабораторной работы №2 в Docker.

.DESCRIPTION
    Скрипт идемпотентный: прежний контейнер удаляется, volume на хосте не трогается,
    поэтому данные из потока 2.11 сохраняются.

    Что делает:
      1. создаёт каталог lab2/node-red-data (он же /data в контейнере);
      2. поднимает контейнер nodered/node-red с портом 1880 и volume;
      3. ждёт, пока Node-RED ответит;
      4. ставит модули node-red-dashboard и node-red-contrib-telegrambot;
      5. подкладывает lab2/flows/flows.json в volume и перезапускает контейнер;
      6. проверяет готовность и печатает версии.

.EXAMPLE
    pwsh -File lab2/scripts/deploy.ps1
#>

[CmdletBinding()]
param(
    [string]$Container = 'krupa-lab2-nodered',
    [string]$Image     = 'nodered/node-red:latest',
    [int]   $Port      = 1880
)

$ErrorActionPreference = 'Stop'

# Каталог lab2 вычисляем от расположения самого скрипта: lab2/scripts/deploy.ps1
$LabDir    = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$DataDir   = Join-Path $LabDir 'node-red-data'
$FlowsFile = Join-Path $LabDir 'flows\flows.json'
$EnvFile   = Join-Path $LabDir 'scripts\lab2.env'
$BaseUrl   = "http://localhost:$Port"

function Step($text) { Write-Host "`n=== $text ===" -ForegroundColor Cyan }

function Wait-NodeRed([int]$Seconds = 180) {
    $deadline = (Get-Date).AddSeconds($Seconds)
    while ((Get-Date) -lt $deadline) {
        try {
            $r = Invoke-WebRequest -Uri "$BaseUrl/" -UseBasicParsing -TimeoutSec 5
            if ($r.StatusCode -eq 200) { return $true }
        } catch { }
        Start-Sleep -Seconds 3
    }
    return $false
}

if (-not (Test-Path $FlowsFile)) {
    throw "Не найден $FlowsFile — сначала соберите сводный файл потоков."
}

Step 'Готовлю каталог-том'
New-Item -ItemType Directory -Force -Path $DataDir | Out-Null
Write-Host "  $DataDir -> /data"

Step "Удаляю прежний контейнер $Container (если был)"
$existing = docker ps -a --filter "name=^/$Container$" --format '{{.Names}}'
if ($existing) { docker rm -f $Container | Out-Null; Write-Host '  удалён' }
else { Write-Host '  нечего удалять' }

Step 'Запускаю контейнер'
docker run -d --name $Container `
    -p "${Port}:1880" `
    -v "${DataDir}:/data" `
    --env-file $EnvFile `
    --restart unless-stopped `
    $Image | Out-Null

if (-not (Wait-NodeRed)) { throw 'Node-RED не ответил за отведённое время' }
Write-Host "  Node-RED отвечает на $BaseUrl" -ForegroundColor Green

Step 'Ставлю дополнительные модули'
docker exec $Container npm install --prefix /data --no-audit --no-fund `
    node-red-dashboard node-red-contrib-telegrambot

Step 'Подкладываю потоки в volume'
Copy-Item $FlowsFile (Join-Path $DataDir 'flows.json') -Force
docker restart $Container | Out-Null

if (-not (Wait-NodeRed)) { throw 'Node-RED не поднялся после перезапуска' }
Write-Host '  потоки загружены' -ForegroundColor Green

Step 'Проверка эндпоинтов'
foreach ($path in @('/api/text', '/api/info', '/api/items?limit=2', '/api/tasks')) {
    try {
        $r = Invoke-WebRequest -Uri "$BaseUrl$path" -UseBasicParsing -TimeoutSec 10
        Write-Host ("  {0,-28} -> {1}" -f $path, $r.StatusCode) -ForegroundColor Green
    } catch {
        $code = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 'ERR' }
        Write-Host ("  {0,-28} -> {1}" -f $path, $code) -ForegroundColor Red
    }
}

Step 'Версии'
docker exec $Container node-red -v 2>&1 | Select-String 'Node-RED version|Node.js  version'
Write-Host "`nГотово. Редактор: $BaseUrl   Dashboard: $BaseUrl/ui" -ForegroundColor Green
