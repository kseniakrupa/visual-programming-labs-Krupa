<#
.SYNOPSIS
    Демонстрация работы CRUD (ачивка №5): все операции по порядку с кодами ответа.

.DESCRIPTION
    Запускать при работающем Node-RED. Скрипт проходит полный сценарий:

        GET    /api/tasks        -> 200  список задач
        POST   /api/tasks        -> 201  создание
        GET    /api/tasks/:id    -> 200  чтение созданной
        PATCH  /api/tasks/:id    -> 200  изменение
        DELETE /api/tasks/:id    -> 200  удаление
        GET    /api/tasks/:id    -> 404  проверка, что удалена
        POST   /api/tasks        -> 400  ошибка валидации (title из 2 символов)
        GET    /api/tasks?done=x -> 400  ошибка параметра

    Вывод рассчитан на скриншот: одна команда — одна картинка.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File demo-crud.ps1
#>

$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)

$Base = 'http://localhost:1880'

function Call($method, $path, $jsonBody) {
    $uri = "$Base$path"
    try {
        if ($jsonBody) {
            $bytes = [Text.Encoding]::UTF8.GetBytes($jsonBody)
            $resp = Invoke-WebRequest -Method $method -Uri $uri `
                -ContentType 'application/json; charset=utf-8' -Body $bytes -UseBasicParsing
        } else {
            $resp = Invoke-WebRequest -Method $method -Uri $uri -UseBasicParsing
        }
        $code = [int]$resp.StatusCode
        $text = $resp.Content
    } catch {
        $code = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 'ERR' }
        # тело ответа с ошибкой PowerShell кладёт в ErrorDetails
        $text = $_.ErrorDetails.Message
        if (-not $text) {
            try {
                $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                $text = $reader.ReadToEnd()
            } catch { $text = '' }
        }
    }

    $color = 'Gray'
    if ("$code" -eq '200' -or "$code" -eq '201') { $color = 'Green' }
    elseif ("$code" -eq '400' -or "$code" -eq '404') { $color = 'Yellow' }

    Write-Host ("{0,-7} {1,-26} -> {2}" -f $method, $path, $code) -ForegroundColor $color
    if ($text) {
        try { $text = ($text | ConvertFrom-Json | ConvertTo-Json -Depth 6 -Compress) } catch { }
        Write-Host ("        " + $text) -ForegroundColor DarkGray
    }
    Write-Host ''
}

Write-Host ''
Write-Host '  CRUD для сущности task — ачивка №5' -ForegroundColor Cyan
Write-Host '  Студент: Крупа Ксения, группа ИИ-241' -ForegroundColor Cyan
Write-Host ('  ' + ('=' * 70)) -ForegroundColor DarkCyan
Write-Host ''

# 1. исходный список
Call 'GET' '/api/tasks'

# 2. создание
Call 'POST' '/api/tasks' '{"title":"Задача, созданная при показе лабы","done":false}'

# находим id только что созданной задачи
try {
    $all = Invoke-RestMethod "$Base/api/tasks" -UseBasicParsing
    $id = ($all.tasks | Sort-Object id | Select-Object -Last 1).id
} catch { $id = 4 }

# 3. чтение по id
Call 'GET' "/api/tasks/$id"

# 4. изменение
Call 'PATCH' "/api/tasks/$id" '{"done":true}'

# 5. удаление
Call 'DELETE' "/api/tasks/$id"

# 6. проверка, что задачи больше нет
Call 'GET' "/api/tasks/$id"

# 7. ошибка валидации: title из двух символов
Call 'POST' '/api/tasks' '{"title":"ok"}'

# 8. ошибка параметра: done не true/false
Call 'GET' '/api/tasks?done=maybe'

Write-Host ('  ' + ('=' * 70)) -ForegroundColor DarkCyan
Write-Host '  Готово. Ожидаемые коды: 200, 201, 200, 200, 200, 404, 400, 400' -ForegroundColor Cyan
Write-Host ''
Read-Host 'Нажми Enter, чтобы закрыть'
