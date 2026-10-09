# API лабораторной работы №2 (Node-RED)

**Студент:** Крупа Ксения, группа ИИ-241
**Способ установки:** Docker (образ `nodered/node-red`), порт `1880`, volume на `/data`
**Базовый URL:** `http://localhost:1880`
**Формат:** JSON (`Content-Type: application/json; charset=utf-8`), кроме `/api/text`.

Эндпоинты реализованы нодами `http in` → `function` → `http response`.
Коды состояния выставляются в `msg.statusCode` внутри function-ноды.

---

## Сводная таблица

| № | Метод | URL | Успех | Ошибки | Поток |
|---|-------|-----|-------|--------|-------|
| 1 | GET | `/api/text` | 200 | — | `flow-08-endpoints.json` |
| 2 | GET | `/api/info` | 200 | — | `flow-08-endpoints.json` |
| 3 | GET | `/api/items?limit=&category=` | 200 | 400 | `flow-08-endpoints.json` |
| 4 | GET | `/api/items/:id` | 200 | 400, 404 | `flow-08-endpoints.json` |
| 5 | GET | `/api/tasks?done=` | 200 | 400 | `flow-13-rest-crud.json` (ачивка 5) |
| 6 | GET | `/api/tasks/:id` | 200 | 400, 404 | `flow-13-rest-crud.json` (ачивка 5) |
| 7 | POST | `/api/tasks` | 201 | 400 | `flow-13-rest-crud.json` (ачивка 5) |
| 8 | PATCH | `/api/tasks/:id` | 200 | 400, 404 | `flow-13-rest-crud.json` (ачивка 5) |
| 9 | DELETE | `/api/tasks/:id` | 200 | 400, 404 | `flow-13-rest-crud.json` (ачивка 5) |

> Запросы удобно выполнять в браузере (только GET) или из командной строки.

## Как выполнять запросы

**Важно про Windows.** В PowerShell `curl` — это алиас командлета `Invoke-WebRequest`,
поэтому вызывать нужно именно `curl.exe`. И у Windows PowerShell 5.1 есть известная
особенность: при вызове внешней программы кавычки внутри аргумента теряются, и запрос

```powershell
curl.exe -d '{"title":"Задача"}' http://localhost:1880/api/tasks   # ТАК НЕ РАБОТАЕТ
```

уходит на сервер как `{title:Задача}` — Node-RED отвечает ошибкой разбора JSON.
Рабочих способов два: **нативный `Invoke-RestMethod`** (рекомендуется) или
**тело запроса из файла** через `--data-binary "@файл"`.

Для GET-запросов всё проще — кавычек в URL нет, поэтому `curl.exe -i <url>` работает как обычно.

```powershell
# GET — так можно
curl.exe -i http://localhost:1880/api/info
```

```powershell
# POST / PATCH / DELETE — так
Invoke-RestMethod -Method Post -Uri http://localhost:1880/api/tasks `
  -ContentType 'application/json; charset=utf-8' `
  -Body ([Text.Encoding]::UTF8.GetBytes('{"title":"Сдать лабораторную работу №2","done":false}'))
```

```bash
# Linux / macOS / Git Bash
curl -i -X POST http://localhost:1880/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Сдать лабораторную работу №2","done":false}'
```

Ниже для краткости примеры с телом запроса даны в двух вариантах: PowerShell и bash.

---

## 1. GET /api/text — простой текст

Возвращает плоский текст (`text/plain; charset=utf-8`).

```bash
curl.exe -i http://localhost:1880/api/text
```

**Ответ `200 OK`:**

```
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8

Крупа Ксения | lab2 (Node-RED) | GET /api/text отвечает простым текстом
```

---

## 2. GET /api/info — JSON с двумя полями

```bash
curl.exe -i http://localhost:1880/api/info
```

**Ответ `200 OK`:**

```json
{
  "student": "Крупа Ксения (ИИ-241)",
  "lab": 2
}
```

---

## 3. GET /api/items — query params

Каталог из пяти товаров. Поддерживает два необязательных query-параметра:

| Параметр | Тип | Обязателен | Ограничения | Описание |
|----------|-----|-----------|-------------|----------|
| `limit` | integer | нет | от 1 до 5 | Сколько записей вернуть (по умолчанию — все 5) |
| `category` | string | нет | `tech`, `fruit` | Фильтр по категории |

### 3.1. Успешный запрос

```bash
curl.exe -i "http://localhost:1880/api/items?limit=2"
```

**Ответ `200 OK`:**

```json
{
  "student": "Крупа Ксения (ИИ-241)",
  "lab": 2,
  "appliedLimit": 2,
  "appliedCategory": null,
  "count": 2,
  "items": [
    { "id": 1, "name": "Ноутбук", "category": "tech", "price": 1500 },
    { "id": 2, "name": "Яблоко", "category": "fruit", "price": 2 }
  ]
}
```

### 3.2. Фильтр по категории

```bash
curl.exe -i "http://localhost:1880/api/items?category=fruit&limit=5"
```

**Ответ `200 OK`:**

```json
{
  "student": "Крупа Ксения (ИИ-241)",
  "lab": 2,
  "appliedLimit": 5,
  "appliedCategory": "fruit",
  "count": 2,
  "items": [
    { "id": 2, "name": "Яблоко", "category": "fruit", "price": 2 },
    { "id": 4, "name": "Банан", "category": "fruit", "price": 1 }
  ]
}
```

### 3.3. Ошибка `400 Bad Request` — недопустимый `limit`

`limit` не целое число либо вне диапазона 1…5.

```bash
curl.exe -i "http://localhost:1880/api/items?limit=99"
curl.exe -i "http://localhost:1880/api/items?limit=abc"
```

**Ответ `400 Bad Request`:**

```json
{
  "error": "Bad Request",
  "message": "Параметр limit должен быть целым числом от 1 до 5",
  "received": "99",
  "student": "Крупа Ксения (ИИ-241)"
}
```

---

## 4. GET /api/items/:id — path param

| Параметр | Где | Тип | Ограничения |
|----------|-----|-----|-------------|
| `id` | path | integer | 1…5 |

### 4.1. Успешный запрос

```bash
curl.exe -i http://localhost:1880/api/items/3
```

**Ответ `200 OK`:**

```json
{
  "student": "Крупа Ксения (ИИ-241)",
  "lab": 2,
  "item": { "id": 3, "name": "Клавиатура", "category": "tech", "price": 80 }
}
```

### 4.2. Ошибка `400 Bad Request` — id не число

```bash
curl.exe -i http://localhost:1880/api/items/abc
```

**Ответ `400 Bad Request`:**

```json
{
  "error": "Bad Request",
  "message": "id должен быть целым числом",
  "received": "abc",
  "student": "Крупа Ксения (ИИ-241)"
}
```

### 4.3. Ошибка `404 Not Found` — товара нет

```bash
curl.exe -i http://localhost:1880/api/items/42
```

**Ответ `404 Not Found`:**

```json
{
  "error": "Not Found",
  "message": "Товар с id=42 не найден",
  "availableIds": [1, 2, 3, 4, 5],
  "student": "Крупа Ксения (ИИ-241)"
}
```

---

# Ачивка №5 — REST+ (полный CRUD)

**Сущность:** `task` — задача.
**Поля (2 штуки, как требует задание):**

| Поле | Тип | Ограничения | Описание |
|------|-----|-------------|----------|
| `title` | string | 3…100 символов, обязательное при создании | Текст задачи |
| `done` | boolean | по умолчанию `false` | Признак выполнения |

Служебные поля, которые выставляет сервер: `id` (integer, автоинкремент), `createdAt`, `updatedAt` (ISO-8601).

**Хранение: `flow context`** (переменная `krupa_tasks`).

Обоснование выбора:

* задание прямо разрешает `flow context` / `global context` / файл — выбран самый простой вариант без внешних зависимостей и без I/O;
* данные живут между сообщениями и переживают редеплой потока, чего достаточно для демонстрации CRUD;
* при рестарте контейнера контекст обнуляется, и inject «сидировать задачи» (`once: true`) заново наполняет его тремя тестовыми записями — поток всегда в рабочем состоянии;
* для настоящей персистентности в этом же репозитории есть ветка с файлом (`flow-11-files.json`) и предусмотрена ачивка №10 (SQLite) — то есть переход на дисковое хранилище очевиден и не требует менять API.

## 5. GET /api/tasks — список задач

Необязательный query-параметр `done` (`true` / `false`) фильтрует по признаку выполнения.

```bash
curl.exe -i http://localhost:1880/api/tasks
curl.exe -i "http://localhost:1880/api/tasks?done=false"
```

**Ответ `200 OK`:**

```json
{
  "student": "Крупа Ксения (ИИ-241)",
  "lab": 2,
  "total": 3,
  "count": 1,
  "tasks": [
    {
      "id": 3,
      "title": "Сделать CRUD на http in/response",
      "done": false,
      "createdAt": "2026-01-01T09:20:00.000Z"
    }
  ]
}
```

**Ошибка `400 Bad Request`** — `done` не равен `true`/`false`:

```bash
curl.exe -i "http://localhost:1880/api/tasks?done=yes"
```

```json
{
  "error": "Bad Request",
  "message": "Параметр done должен быть true или false",
  "student": "Крупа Ксения (ИИ-241)",
  "extra": { "received": "yes" }
}
```

## 6. GET /api/tasks/:id — задача по id

```bash
curl.exe -i http://localhost:1880/api/tasks/2
```

**Ответ `200 OK`:**

```json
{
  "student": "Крупа Ксения (ИИ-241)",
  "lab": 2,
  "task": {
    "id": 2,
    "title": "Собрать поток inject → debug",
    "done": true,
    "createdAt": "2026-01-01T09:10:00.000Z"
  }
}
```

**Ошибка `404 Not Found`:**

```bash
curl.exe -i http://localhost:1880/api/tasks/999
```

```json
{
  "error": "Not Found",
  "message": "Задача с id=999 не найдена",
  "student": "Крупа Ксения (ИИ-241)"
}
```

## 7. POST /api/tasks — создать задачу

Тело запроса — JSON-объект. `title` обязателен, `done` необязателен.

```powershell
Invoke-RestMethod -Method Post -Uri http://localhost:1880/api/tasks `
  -ContentType 'application/json; charset=utf-8' `
  -Body ([Text.Encoding]::UTF8.GetBytes('{"title":"Сдать лабораторную работу №2","done":false}'))
```

```bash
curl -i -X POST http://localhost:1880/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Сдать лабораторную работу №2","done":false}'
```

**Ответ `201 Created`** (реальный вывод при проверке):

```json
{
  "student": "Крупа Ксения (ИИ-241)",
  "message": "Задача создана",
  "task": {
    "id": 4,
    "title": "Сдать лабораторную работу №2",
    "done": false,
    "createdAt": "2026-10-08T19:03:47.032Z"
  },
  "total": 4
}
```

### Ошибки `400 Bad Request`

| Случай | Тело запроса | Ответ `message` |
|--------|--------------|-----------------|
| тело не объект | `[1,2,3]` | `Тело запроса должно быть JSON-объектом` |
| `title` отсутствует | `{}` | `Поле title обязательно и должно быть строкой` |
| `title` слишком короткий | `{"title":"ok"}` | `Длина title должна быть от 3 до 100 символов` |
| `done` не boolean | `{"title":"Задача","done":"yes"}` | `Поле done должно быть boolean` |

```powershell
Invoke-RestMethod -Method Post -Uri http://localhost:1880/api/tasks `
  -ContentType 'application/json; charset=utf-8' `
  -Body ([Text.Encoding]::UTF8.GetBytes('{"title":"ok"}'))
```

```json
{
  "error": "Bad Request",
  "message": "Длина title должна быть от 3 до 100 символов",
  "student": "Крупа Ксения (ИИ-241)",
  "extra": { "received": "ok" }
}
```

## 8. PATCH /api/tasks/:id — частичное обновление

Можно передать `title`, `done` или оба поля. Пустое тело — ошибка `400`.

```powershell
Invoke-RestMethod -Method Patch -Uri http://localhost:1880/api/tasks/3 `
  -ContentType 'application/json; charset=utf-8' `
  -Body ([Text.Encoding]::UTF8.GetBytes('{"done":true}'))
```

```bash
curl -i -X PATCH http://localhost:1880/api/tasks/3 \
  -H "Content-Type: application/json" -d '{"done":true}'
```

**Ответ `200 OK`** (реальный вывод при проверке):

```json
{
  "student": "Крупа Ксения (ИИ-241)",
  "message": "Задача обновлена",
  "task": {
    "id": 3,
    "title": "Сделать CRUD на http in/response",
    "done": true,
    "createdAt": "2026-01-01T09:20:00.000Z",
    "updatedAt": "2026-10-08T19:03:55.785Z"
  }
}
```

**Ошибка `400 Bad Request`** — тело без `title` и `done`:

```bash
curl -i -X PATCH http://localhost:1880/api/tasks/3 \
  -H "Content-Type: application/json" -d '{}'
```

```json
{
  "error": "Bad Request",
  "message": "Нужно передать хотя бы одно поле: title или done",
  "student": "Крупа Ксения (ИИ-241)",
  "extra": null
}
```

**Ошибка `404 Not Found`** — задачи с таким id нет (тело ответа как в п. 6).

## 9. DELETE /api/tasks/:id — удалить задачу

```bash
curl.exe -i -X DELETE http://localhost:1880/api/tasks/4
```

**Ответ `200 OK`:**

```json
{
  "student": "Крупа Ксения (ИИ-241)",
  "message": "Задача удалена",
  "deleted": {
    "id": 4,
    "title": "Сдать лабораторную работу №2",
    "done": false,
    "createdAt": "2026-01-15T12:34:56.789Z"
  },
  "total": 3
}
```

**Ошибка `404 Not Found`** — повторное удаление того же id:

```bash
curl.exe -i -X DELETE http://localhost:1880/api/tasks/4
```

```json
{
  "error": "Not Found",
  "message": "Задача с id=4 не найдена",
  "student": "Крупа Ксения (ИИ-241)"
}
```

---

## Сквозной сценарий проверки CRUD

PowerShell (проверено на этом стенде):

```powershell
$base = 'http://localhost:1880'

# 1. посмотреть стартовые данные
Invoke-RestMethod "$base/api/tasks" | ConvertTo-Json -Depth 5

# 2. создать задачу
$body = [Text.Encoding]::UTF8.GetBytes('{"title":"Проверить CRUD"}')
$created = Invoke-RestMethod -Method Post -Uri "$base/api/tasks" `
  -ContentType 'application/json; charset=utf-8' -Body $body
$id = $created.task.id
Write-Host "Создана задача id=$id"

# 3. прочитать её по id
Invoke-RestMethod "$base/api/tasks/$id" | ConvertTo-Json -Depth 5

# 4. изменить
$patch = [Text.Encoding]::UTF8.GetBytes('{"done":true}')
Invoke-RestMethod -Method Patch -Uri "$base/api/tasks/$id" `
  -ContentType 'application/json; charset=utf-8' -Body $patch | ConvertTo-Json -Depth 5

# 5. удалить
Invoke-RestMethod -Method Delete -Uri "$base/api/tasks/$id" | ConvertTo-Json -Depth 5

# 6. убедиться, что её больше нет -> ожидаем 404
try {
    Invoke-RestMethod "$base/api/tasks/$id"
} catch {
    Write-Host "Код ответа: $([int]$_.Exception.Response.StatusCode)"
}
```

bash:

```bash
BASE=http://localhost:1880

curl -s $BASE/api/tasks
curl -s -X POST $BASE/api/tasks -H 'Content-Type: application/json' -d '{"title":"Проверить CRUD"}'
curl -s $BASE/api/tasks/4
curl -s -X PATCH $BASE/api/tasks/4 -H 'Content-Type: application/json' -d '{"done":true}'
curl -s -X DELETE $BASE/api/tasks/4
curl -s -o /dev/null -w "%{http_code}\n" $BASE/api/tasks/4     # ожидаем 404
```
