<#
.SYNOPSIS
    Включает Node-RED для лабораторной работы №2: Docker Desktop + контейнер + браузер.

.DESCRIPTION
    Скрипт для запуска вручную, перед показом работы. Делает по порядку:
      1. проверяет, работает ли Docker, и при необходимости запускает Docker Desktop;
      2. ждёт, пока движок Docker будет готов;
      3. запускает контейнер krupa-lab2-nodered (или создаёт его заново,
         если контейнера нет);
      4. ждёт, пока Node-RED ответит;
      5. открывает редактор в браузере.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File start.ps1
#>

[CmdletBinding()]
param(
    [string]$Container = 'krupa-lab2-nodered',
    [string]$Image     = 'nodered/node-red:latest',
    [int]   $Port      = 1880,
    [switch]$NoBrowser
)

$ErrorActionPreference = 'Continue'

$LabDir  = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$DataDir = Join-Path $LabDir 'node-red-data'
$EnvFile = Join-Path $LabDir 'scripts\lab2.env'
$Url     = "http://localhost:$Port"

function Say($text, $color = 'Gray') { Write-Host $text -ForegroundColor $color }

function Test-Docker {
    docker info --format '{{.ServerVersion}}' 2>$null | Out-Null
    return ($LASTEXITCODE -eq 0)
}

function Wait-Docker([int]$Seconds = 180) {
    $deadline = (Get-Date).AddSeconds($Seconds)
    while ((Get-Date) -lt $deadline) {
        if (Test-Docker) { return $true }
        Start-Sleep -Seconds 5
    }
    return $false
}

function Wait-NodeRed([int]$Seconds = 180) {
    $deadline = (Get-Date).AddSeconds($Seconds)
    while ((Get-Date) -lt $deadline) {
        try {
            $r = Invoke-WebRequest -Uri "$Url/" -UseBasicParsing -TimeoutSec 5
            if ($r.StatusCode -eq 200) { return $true }
        } catch { }
        Start-Sleep -Seconds 3
    }
    return $false
}

Say ''
Say '  Node-RED для лабораторной работы №2' 'Cyan'
Say '  -----------------------------------' 'Cyan'
Say ''

# --- 1. Docker -------------------------------------------------------------
Say '  [1/4] Проверяю Docker...' 'White'
if (Test-Docker) {
    Say '        Docker уже работает' 'Green'
} else {
    $desktop = @(
        "$env:LOCALAPPDATA\Programs\DockerDesktop\Docker Desktop.exe",
        "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $desktop) {
        Say '        Не найден Docker Desktop. Установи его и запусти скрипт снова.' 'Red'
        Read-Host 'Нажми Enter, чтобы закрыть'
        exit 1
    }

    Say '        Запускаю Docker Desktop, это занимает до полутора минут...' 'Yellow'
    Start-Process $desktop | Out-Null

    if (-not (Wait-Docker)) {
        Say '        Docker так и не запустился. Открой Docker Desktop вручную и повтори.' 'Red'
        Read-Host 'Нажми Enter, чтобы закрыть'
        exit 1
    }
    Say '        Docker готов' 'Green'
}

# --- 2. Контейнер ----------------------------------------------------------
Say '  [2/4] Включаю Node-RED...' 'White'
New-Item -ItemType Directory -Force -Path $DataDir | Out-Null

$exists = docker ps -a --filter "name=^/$Container$" --format '{{.Names}}'
if ($exists) {
    docker start $Container 2>&1 | Out-Null
    Say '        контейнер запущен' 'Green'
} else {
    Say '        контейнера нет, создаю заново' 'Yellow'
    docker run -d --name $Container `
        -p "${Port}:1880" `
        -v "${DataDir}:/data" `
        --env-file $EnvFile `
        --restart unless-stopped `
        $Image 2>&1 | Out-Null

    Say '        ставлю дополнительные модули...' 'Yellow'
    docker exec $Container npm install --prefix /data --no-audit --no-fund `
        node-red-dashboard node-red-contrib-telegrambot 2>&1 | Out-Null
    docker restart $Container 2>&1 | Out-Null
    Say '        контейнер создан' 'Green'
}

# --- 3. Ждём ---------------------------------------------------------------
Say '  [3/4] Жду, пока Node-RED загрузится...' 'White'
if (-not (Wait-NodeRed)) {
    Say "        Node-RED не ответил. Посмотри логи: docker logs $Container" 'Red'
    Read-Host 'Нажми Enter, чтобы закрыть'
    exit 1
}
Say '        Node-RED работает' 'Green'

# --- 4. Браузер ------------------------------------------------------------
Say '  [4/4] Открываю браузер' 'White'
if (-not $NoBrowser) {
    Start-Process $Url
    Start-Process "$Url/ui"      # дашборд из пункта 2.9
}

Say ''
Say '  ГОТОВО' 'Green'
Say ''
Say "  Редактор:  $Url" 'White'
Say "  Дашборд:   $Url/ui" 'White'
Say ''
Say '  Что делать дальше — в файле lab2/docs/kak-pokazat.md' 'Cyan'
Say ''
Read-Host 'Нажми Enter, чтобы закрыть это окно'
