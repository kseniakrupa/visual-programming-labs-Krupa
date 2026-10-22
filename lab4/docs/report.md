# Лабораторная работа №4. n8n

**Выполнил:** Крупа Ксения, группа ИИ-241

## Часть 1. Установка и запуск n8n

- **Образ Docker:** `n8nio/n8n`
- **Порт:** `5678`
- **Volumes:**
  - `./lab4/n8n-data` → `/home/node/.n8n` — база n8n, настройки и ключ шифрования
  - `./lab4/data` → `/data` — вторая volume-папка для рабочих файлов
- **Прочие параметры:** `GENERIC_TIMEZONE=Europe/Moscow`, `TZ=Europe/Moscow`,
  `N8N_SECURE_COOKIE=false` (вход по http), `N8N_RUNNERS_ENABLED=true`,
  `--add-host=host.docker.internal:host-gateway` (чтобы n8n из контейнера видел
  Redis, запущенный на хосте)

**Команда запуска:**

```powershell
docker run -d --name n8n -p 5678:5678 -v "${PWD}\lab4\n8n-data:/home/node/.n8n" -v "${PWD}\lab4\data:/data" -e GENERIC_TIMEZONE="Europe/Moscow" -e TZ="Europe/Moscow" -e N8N_SECURE_COOKIE=false -e N8N_RUNNERS_ENABLED=true --add-host=host.docker.internal:host-gateway n8nio/n8n
```

После старта контейнера редактор доступен на <http://localhost:5678>, выполнена
регистрация владельца. Версия n8n — 2.44.6.

![Версия n8n 2.44.6 (Settings → Usage and plan)](../screenshots/01-version.png)

## Часть 2. Изучение нод и создание workflow

Были освоены и собраны следующие воркфлоу (все файлы лежат в папке `flows/`):

- `flow-01-manual-set.json` (Manual Trigger → Set → Code)
- `flow-02-code.json` (Code с базовыми элементами JS)
- `flow-03-if.json` (Ветвление через IF)
- `flow-04-set.json` (Изменение полей, timestamp)
- `flow-05-http.json` (HTTP Request к публичному API)
- `flow-06-schedule.json` (Schedule Trigger каждые 5 минут)

![flow-01: Manual Trigger → Set → Code, все ноды выполнены](../screenshots/02-manual-set.png)

![flow-02: Manual Trigger → Code → NoOp](../screenshots/03-code.png)

![flow-03: Manual Trigger → Code → IF → NoOp (ветки true и false)](../screenshots/04-if.png)

![flow-04: Set с полями topic, timestamp, payload → Code](../screenshots/05-set.png)

![flow-05: HTTP Request к api.chucknorris.io → Code](../screenshots/06-http.png)

![flow-06: Schedule Trigger каждые 5 минут → Code](../screenshots/07-schedule.png)

## Часть 3. Redis

Redis был запущен в Docker. В n8n настроены Credentials (`host.docker.internal`,
порт 6379).

- `flow-09-redis.json` — создание (Set) и чтение (Get) ключа `krupa`.
- `flow-10-redis.json` — удаление (Delete) и проверка отсутствия (Get
  возвращает пусто) ключа `krupa`.

Подробности в [`redis.md`](redis.md).

![flow-09: Redis Set → Redis Get](../screenshots/08-redis-setget-all.png)

![flow-09: результат Get — значение «hello from Krupa»](../screenshots/08-redis-setget-output.png)

![flow-10: Redis Delete → Redis Get](../screenshots/09-redis-delete-all.png)

![flow-10: после удаления Get возвращает пусто](../screenshots/09-redis-delete-output.png)

## Часть 4. Ачивка

**Выбрана Ачивка 5.2: Написать Rest API для работы с заметками (хранилище — Redis).**

Было реализовано два независимых воркфлоу, работающих как REST API:

- `flow-11-achieve-rest-post.json` — принимает POST-запрос на `/webhook/notes`,
  берет `id` и `text` из тела запроса и сохраняет их в Redis.
- `flow-12-achieve-rest-get.json` — принимает GET-запрос на
  `/webhook/notes?id=...`, достает заметку из Redis по ID и возвращает её
  в ответе.

Оба workflow опубликованы (Published), поэтому доступны по production-URL.

Проверка работы API осуществлялась через PowerShell (команды `Invoke-RestMethod`):

```powershell
Invoke-RestMethod -Uri "http://localhost:5678/webhook/notes" -Method Post -Body '{"id": "note1", "text": "My first note in Redis"}' -ContentType "application/json"
Invoke-RestMethod -Uri "http://localhost:5678/webhook/notes?id=note1" -Method Get
```

Ответ на POST — `status: Created`, на GET — `note: My first note in Redis`.

![flow-11: Webhook (POST) → Redis Set → Edit Fields](../screenshots/10-achieve-api-post.png)

![flow-12: Webhook (GET) → Redis Get → Edit Fields](../screenshots/11-achieve-api-get.png)

![Проверка API из PowerShell: POST создаёт заметку, GET возвращает её](../screenshots/12-achieve-api-powershell.png)

## AI-промпты

В ходе работы использовались следующие промпты:

1. «Напиши JavaScript код для ноды Code, который использует let, const, цикл for
   и возвращает объект с полем payload».
2. «Как настроить креденшелы для Redis в n8n, если Redis запущен в Docker на том
   же компьютере?»
3. «Как передать сообщение между двумя разными workflow в n8n с помощью Redis
   Pub/Sub?» (примечание: от этого варианта отказались в пользу REST API).
4. «Как создать REST API на нодах Webhook и Redis в n8n?»

## Выводы

В ходе лабораторной работы я освоила n8n как low-code платформу для
автоматизации. Научилась запускать её в Docker с сохранением данных через
volumes. Изучила базовые ноды (Set, Code, IF) и научилась писать простые скрипты
на JavaScript. Поняла, как работают HTTP-запросы и триггеры (Manual, Schedule).
Отдельно разобралась с настройкой внешней базы данных Redis: создавала, читала
и удаляла ключи. В качестве ачивки реализовала полноценный REST API для работы
с заметками (POST и GET запросы), используя Redis в качестве хранилища.
