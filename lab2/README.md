# lab2 — Node-RED

Лабораторная работа №2 по курсу «Технологии визуального программирования».

**Студент:** Крупа Ксения
**Способ установки:** Docker (образ `nodered/node-red`)

## Структура

```
lab2/
├── docs/
│   ├── api.md        — описание всех HTTP-эндпоинтов, параметров, примеров и ошибок
│   └── report.md     — отчёт по работе (установка, ноды, потоки, скриншоты, выводы)
├── flows/            — по одному файлу на поток (импорт через меню → Import)
│   ├── flow-01-inject-debug.json
│   ├── ...
│   ├── flow-13-rest-crud.json
│   └── flows.json    — сводный файл всех потоков (используется контейнером)
├── scripts/
│   ├── deploy.ps1        — развернуть Node-RED в Docker и загрузить потоки
│   └── verify-flows.js   — сквозная проверка всех потоков через поток Debug
├── screenshots/      — скриншоты редактора и браузера
└── node-red-data/    — docker-volume, смонтированный в /data (в git не хранится)
```

## Запуск

### 1. Контейнер

```powershell
docker run -d --name krupa-lab2-nodered `
  -p 1880:1880 `
  -v "C:\Users\Ksenia\study\visual-programming-labs-Krupa\lab2\node-red-data:/data" `
  -e LAB2_STUDENT=Krupa `
  -e LAB2_LAB=2 `
  --restart unless-stopped `
  nodered/node-red:latest
```

Ключевые параметры:

| Параметр | Зачем |
|----------|-------|
| `-p 1880:1880` | редактор доступен на <http://localhost:1880> |
| `-v ...\node-red-data:/data` | `flows.json`, логи и файл из 2.11 лежат на хосте и переживают пересоздание контейнера |
| `-e LAB2_STUDENT`, `-e LAB2_LAB` | переменные окружения для потока 2.12 (читаются через `env.get()`) |
| `--restart unless-stopped` | Node-RED поднимается сам после перезагрузки |

### 2. Дополнительные модули

```powershell
# dashboard (поток 2.9) и telegram-бот (поток 2.10)
docker exec krupa-lab2-nodered npm install --prefix /data node-red-dashboard node-red-contrib-telegrambot
docker restart krupa-lab2-nodered
```

### 3. Потоки

Скопировать сводный файл в volume и перезапустить контейнер:

```powershell
Copy-Item .\flows\flows.json .\node-red-data\flows.json -Force
docker restart krupa-lab2-nodered
```

Либо импортировать потоки по одному: в редакторе <http://localhost:1880> →
меню (☰) → **Import** → **select a file to import** → выбрать `flows/flow-NN-*.json`.

### 4. Проверка

| Что | Где смотреть |
|-----|--------------|
| Редактор | <http://localhost:1880> |
| Dashboard | <http://localhost:1880/ui> |
| API | <http://localhost:1880/api/text>, `/api/info`, `/api/items`, `/api/tasks` |
| Версия Node-RED / Node.js | меню (☰) → **About**, либо `docker exec krupa-lab2-nodered node-red -v` |

## Потоки

| Файл | Пункт задания | Что демонстрирует |
|------|---------------|-------------------|
| `flow-01-inject-debug.json` | 2.1 | inject → debug, `complete msg object` |
| `flow-02-function.json` | 2.2 | function-нода: `let`/`const`, `if/else`, `for`, массив, объект |
| `flow-03-switch.json` | 2.3 | switch: ветвление `msg.payload.avg` на два выхода |
| `flow-04-change.json` | 2.4 | change/set: `topic`, `timestamp`, `payload` через JSONata |
| `flow-05-template.json` | 2.5 | template: Mustache → JSON (`Output = parsed JSON`) |
| `flow-06-http-request.json` | 2.6 | http request к публичному API, `Return = parsed JSON object` |
| `flow-07-mqtt.json` | 2.7 | mqtt out + mqtt in через `broker.hivemq.com:1883` |
| `flow-08-endpoints.json` | 2.8 | три GET-эндпоинта (+ path param), статусы 200/400/404 |
| `flow-09-dashboard.json` | 2.9 | dashboard: gauge + chart, имитация датчика |
| `flow-10-telegram.json` | 2.10 | telegram-бот: `/start`, `/help`, `/time`, echo |
| `flow-11-files.json` | 2.11 | file out (append) + file in + разбор JSON Lines |
| `flow-12-context.json` | 2.12 | flow context (счётчик), global context (журнал), env-переменные |
| `flow-13-rest-crud.json` | Ачивка 5 | полный CRUD: GET/GET:id/POST/PATCH/DELETE |

Подробное описание HTTP-эндпоинтов — в [`docs/api.md`](docs/api.md).
