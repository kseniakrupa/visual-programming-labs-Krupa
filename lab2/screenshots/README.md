# Скриншоты

Файлы должны называться по шаблону `NN-<краткое-имя>.png` и лежать в этой папке.
Они автоматически подхватятся отчётом [`../docs/report.md`](../docs/report.md).

## Список

| Файл | Что снять |
|------|-----------|
| `00-node-versions.png` | Версии Node-RED и Node.js: меню (☰) → About, либо вывод `docker exec krupa-lab2-nodered node-red -v` и логи запуска Docker-контейнера |
| `01-inject-debug.png` | Вкладка `01 · inject → debug`, панель Debug открыта, видны `payload`, `topic`, `_msgid` |
| `02-function.png` | Вкладка `02 · function`, в Debug — результат функции (объект с `avg`, `verdict`) |
| `03-switch.png` | Вкладка `03 · switch`, два сообщения в Debug: одно с выхода 1, одно с выхода 2 |
| `04-change.png` | Вкладка `04 · change`, в Debug видны новые `topic`, `timestamp`, `changedBy`, `payload` |
| `05-template.png` | Вкладка `05 · template`, в Debug — собранный JSON-объект |
| `06-http-request.png` | Вкладка `06 · http request`, в Debug — ответ публичного API |
| `07-mqtt.png` | Вкладка `07 · mqtt`, в Debug — сообщение, вернувшееся из топика `student/krupa/lab2/sensor` |
| `08-endpoints.png` | Вкладка `08 · GET endpoints` целиком (все 4 пары http in/response) |
| `08a-api-text.png` | Браузер: `http://localhost:1880/api/text` |
| `08b-api-info.png` | Браузер: `http://localhost:1880/api/info` |
| `08c-api-items-ok.png` | Браузер: `http://localhost:1880/api/items?limit=2` — успешный запрос |
| `08d-api-items-400.png` | Браузер: `http://localhost:1880/api/items?limit=99` — ошибка 400 |
| `08e-api-item-404.png` | Браузер: `http://localhost:1880/api/items/42` — ошибка 404 |
| `09-dashboard.png` | Вкладка `09 · dashboard` в редакторе |
| `09a-dashboard-ui.png` | Браузер: `http://localhost:1880/ui` — работающие gauge и chart |
| `10-telegram-flow.png` | Вкладка `10 · telegram` в редакторе |
| `10a-telegram-chat.png` | Чат с ботом `@tvl_lab2_krupa_bot`: `/start`, `/time`, echo-ответ |
| `11-files.png` | Вкладка `11 · files` + Debug с разобранным содержимым файла |
| `11a-file-restart.png` | Доказательство сохранения файла: `docker restart` контейнера и повторное чтение — данные на месте |
| `12-context.png` | Вкладка `12 · context`, в Debug видны счётчик и значения env-переменных |
| `13-rest-crud.png` | Вкладка `13 · REST CRUD (ачивка 5)` целиком (все 5 пар http in/response) |
| `13a-crud-get.png` | Браузер или curl: `GET /api/tasks` — список из трёх задач |
| `13b-crud-post.png` | curl: `POST /api/tasks` — ответ `201 Created` |
| `13c-crud-patch.png` | curl: `PATCH /api/tasks/:id` — ответ `200 OK` |
| `13d-crud-delete.png` | curl: `DELETE /api/tasks/:id` — ответ `200 OK` |
| `13e-crud-400-404.png` | curl: ошибки `400 Bad Request` и `404 Not Found` |

## Как снимать

* Полноэкранный скриншот — `Win + Shift + S` либо `Win + PrtScn`.
* В редакторе Node-RED удобно нажимать **Ctrl + Shift + L** (показать/скрыть sidebar) и
  кнопку **Clear** в панели Debug перед каждым снимком, чтобы в кадр попадали только нужные сообщения.
* Для curl-запросов удобно открыть PowerShell и снять окно терминала целиком вместе с командой.
