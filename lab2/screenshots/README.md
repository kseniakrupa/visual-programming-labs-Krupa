# Скриншоты

Ровно **22 штуки** — по одному на каждое требование методички, ни больше ни меньше.
Файлы кладутся в эту папку под именами из таблицы. Отчёт
[`../docs/report.md`](../docs/report.md) уже ссылается на них, поэтому картинки
появятся в отчёте сами, как только файлы будут на месте.

Как снимать: `Win + Shift + S` → выделить область → вставить в Paint (`Ctrl + V`)
→ сохранить под нужным именем.

---

## Соответствие требованиям методички

| Пункт | Что дословно сказано в задании | Файлы | Штук |
|-------|-------------------------------|-------|------|
| Часть 1 | «Сохранить скриншот с версией Node.js, используемой в docker-контейнере» | `00-node-versions.png` | 1 |
| 2.1 | «Скриншот + flow-01-inject-debug.json» | `01-inject-debug.png` | 1 |
| 2.2 | «Скриншот + flow-02-function.json» | `02-function.png` | 1 |
| 2.3 | «Скриншот + flow-03-switch.json» | `03-switch.png` | 1 |
| 2.4 | «Скриншот + flow-04-change.json» | `04-change.png` | 1 |
| 2.5 | «Скриншот + flow-05-template.json» | `05-template.png` | 1 |
| 2.6 | «Скриншот + flow-06-http-request.json» | `06-http-request.png` | 1 |
| 2.7 | «Скриншот + flow-07-mqtt.json» | `07-mqtt.png` | 1 |
| 2.8 | «Скриншоты браузера + flow-08-endpoints.json»; «Проверить все три через браузер: открыть URL и увидеть результат»; «Для третьего — показать минимум два запроса: успешный и с ошибкой» | `08-endpoints.png`, `08a-api-text.png`, `08b-api-info.png`, `08c-api-items-ok.png`, `08d-api-items-400.png` | 5 |
| 2.9 | «Скриншоты dashboard + flow-09-dashboard.json» | `09-dashboard.png`, `09a-dashboard-ui.png` | 2 |
| 2.10 | «Скриншот чата + flow-10-telegram.json» | `10-telegram-flow.png`, `10a-telegram-chat.png` | 2 |
| 2.11 | «Скриншот + flow-11-files.json»; «Показать, что данные сохраняются между перезапусками Node-RED» | `11-files.png`, `11a-file-restart.png` | 2 |
| 2.12 | «Скриншот + flow-12-context.json» | `12-context.png` | 1 |
| Ачивка 5 | «Ачивка считается взятой, когда студент показал преподавателю работающий flow, коммит и скриншоты» | `13-rest-crud.png`, `13b-crud-demo.png` | 2 |
| Часть 4 | «скриншоты всех flow» | покрыто строками 2.1–2.12 и ачивкой | — |
| | | **Итого** | **22** |

---

## По шагам: что открывать и что нажимать

### 1. Версия — `00-node-versions.png`

В редакторе меню (☰) → **About**. Видны версии Node-RED и Node.js.

### 2–8. По одной вкладке — `01`…`07`

Перед каждым снимком: открой вкладку, открой панель Debug (иконка жука справа),
нажми **Clear** в панели.

| Файл | Вкладка | Что нажать |
|------|---------|-----------|
| `01-inject-debug.png` | `01 · inject → debug` | ничего, работает само — подожди 5 секунд |
| `02-function.png` | `02 · function` | три inject-ноды по очереди |
| `03-switch.png` | `03 · switch` | две inject-ноды по очереди |
| `04-change.png` | `04 · change` | одну inject-ноду |
| `05-template.png` | `05 · template` | одну inject-ноду |
| `06-http-request.png` | `06 · http request` | одну inject-ноду |
| `07-mqtt.png` | `07 · mqtt` | ничего, работает само — подожди 10 секунд |

### 9–13. Эндпоинты (пункт 2.8)

Сначала вкладка:

| Файл | Что снять |
|------|-----------|
| `08-endpoints.png` | Вкладка `08 · GET endpoints` целиком. Уменьши масштаб (`Ctrl` + колесо мыши вниз), снимай весь экран редактора |

Потом четыре адреса в браузере — снимай так, чтобы был виден и адрес, и ответ:

| Файл | Адрес |
|------|-------|
| `08a-api-text.png` | `http://localhost:1880/api/text` |
| `08b-api-info.png` | `http://localhost:1880/api/info` |
| `08c-api-items-ok.png` | `http://localhost:1880/api/items?limit=2` — успешный запрос |
| `08d-api-items-400.png` | `http://localhost:1880/api/items?limit=99` — запрос с ошибкой |

### 14–15. Dashboard (пункт 2.9)

| Файл | Что снять |
|------|-----------|
| `09-dashboard.png` | Вкладка `09 · dashboard` в редакторе |
| `09a-dashboard-ui.png` | Адрес `http://localhost:1880/ui` — работающие gauge и график |

### 16–17. Telegram (пункт 2.10)

| Файл | Что снять |
|------|-----------|
| `10-telegram-flow.png` | Вкладка `10 · telegram` в редакторе |
| `10a-telegram-chat.png` | Чат с ботом: `/start`, `/time` и echo-ответ на обычное сообщение |

Чтобы бот заработал, сначала впиши токен от @BotFather в ноду `telegram bot`
и нажми **Deploy**.

### 18–19. Файлы (пункт 2.11)

| Файл | Что снять |
|------|-----------|
| `11-files.png` | Вкладка `11 · files`: нажми **три раза** inject «записать показание», затем один раз «прочитать». Снимай вкладку вместе с панелью Debug |
| `11a-file-restart.png` | Закрой окно `start.cmd`, запусти `start.cmd` заново, открой вкладку 11, нажми «прочитать» — в Debug видно `linesTotal: 3`, то есть данные не потерялись |

### 20. Контекст (пункт 2.12) — `12-context.png`

Вкладка `12 · context`. Ничего нажимать не надо, работает само — подожди 10 секунд.

### 21–22. Ачивка 5 (CRUD)

| Файл | Что снять |
|------|-----------|
| `13-rest-crud.png` | Вкладка `13 · REST CRUD (ачивка 5)` целиком |
| `13b-crud-demo.png` | Двойной клик по `lab2\scripts\demo-crud.cmd` → снять окно терминала. Должны быть видны все операции и коды `200, 201, 200, 200, 200, 404, 400, 400` |

---

## Итоговый список имён

```
00-node-versions.png
01-inject-debug.png
02-function.png
03-switch.png
04-change.png
05-template.png
06-http-request.png
07-mqtt.png
08-endpoints.png
08a-api-text.png
08b-api-info.png
08c-api-items-ok.png
08d-api-items-400.png
09-dashboard.png
09a-dashboard-ui.png
10-telegram-flow.png
10a-telegram-chat.png
11-files.png
11a-file-restart.png
12-context.png
13-rest-crud.png
13b-crud-demo.png
```

---

## После того как снимешь

```powershell
cd C:\Users\Ksenia\study\visual-programming-labs-Krupa
git add lab2/screenshots
git commit -m "lab2: add screenshots"
git push
```

Проверить: открой `lab2/docs/report.md` на GitHub — картинки должны быть на месте ссылок.
