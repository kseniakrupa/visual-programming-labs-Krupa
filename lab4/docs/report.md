# Лабораторная работа №4. n8n

**Выполнил:** Крупа Ксения, группа ИИ-241

## Часть 1. Установка и запуск n8n

- **Образ Docker:** `n8nio/n8n`
- **Порт:** 5678
- **Volumes:**
  - `./lab4/n8n-data` → `/home/node/.n8n` (для сохранения данных n8n)
  - `./lab4/data` → `/data` (вторая volume-папка)
- **Прочие параметры:** `GENERIC_TIMEZONE`, `TZ`, `N8N_SECURE_COOKIE=false`, `N8N_RUNNERS_ENABLED=true`, `--add-host=host.docker.internal:host-gateway`
- **Команда запуска:**
```powershell
docker run -d --name n8n -p 5678:5678 -v "${PWD}\lab4\n8n-data:/home/node/.n8n" -v "${PWD}\lab4\data:/data" -e GENERIC_TIMEZONE="Europe/Moscow" -e TZ="Europe/Moscow" -e N8N_SECURE_COOKIE=false -e N8N_RUNNERS_ENABLED=true --add-host=host.docker.internal:host-gateway n8nio/n8n


## Часть 2. Изучение нод и создание workflow

Были освоены и собраны следующие воркфлоу (все файлы лежат в папке `flows/`):
- `flow-01-manual-set.json` (Manual Trigger → Set → Code)
- `flow-02-code.json` (Code с базовыми элементами JS)
- `flow-03-if.json` (Ветвление через IF)
- `flow-04-set.json` (Изменение полей, timestamp)
- `flow-05-http.json` (HTTP Request к публичному API)
- `flow-06-schedule.json` (Schedule Trigger каждые 5 минут)

Скриншоты: `02-manual-set.png` - `07-schedule.png`.

## Часть 3. Redis

Redis был запущен в Docker. В n8n настроены Credentials (`host.docker.internal`, порт 6379).
- `flow-09-redis.json` — создание (Set) и чтение (Get) ключа `krupa`.
- `flow-10-redis.json` — удаление (Delete) и проверка отсутствия (Get возвращает пусто) ключа `krupa`.
Подробности в `docs/redis.md`. Скриншоты: `08-redis-setget.png`, `09-redis-delete.png`.

## Часть 4. Ачивка

**Выбрана Ачивка 5.2: Написать Rest API для работы с заметками (хранилище — Redis).**

Было реализовано два независимых воркфлоу, работающих как REST API:
- `flow-11-achieve-rest-post.json` — принимает POST-запрос на `/webhook/notes`, берет `id` и `text` из тела запроса и сохраняет их в Redis.
- `flow-12-achieve-rest-get.json` — принимает GET-запрос на `/webhook/notes?id=...`, достает заметку из Redis по ID и возвращает её в ответе.

Проверка работы API осуществлялась через PowerShell (команды `Invoke-RestMethod`).
Скриншоты: `10-achieve-api-post.png`, `11-achieve-api-get.png`, `12-achieve-api-powershell.png`.

## AI-промпты

В ходе работы использовались следующие промпты:
1. «Напиши JavaScript код для ноды Code, который использует let, const, цикл for и возвращает объект с полем payload».
2. «Как настроить креденшелы для Redis в n8n, если Redis запущен в Docker на том же компьютере?»
3. «Как передать сообщение между двумя разными workflow в n8n с помощью Redis Pub/Sub?» *(Примечание: от этого варианта отказались в пользу REST API).*
4. «Как создать REST API на нодах Webhook и Redis в n8n?»

## Выводы

В ходе лабораторной работы я освоила n8n как low-code платформу для автоматизации. Научилась запускать её в Docker с сохранением данных через volumes. Изучила базовые ноды (Set, Code, IF) и научилась писать простые скрипты на JavaScript. Поняла, как работают HTTP-запросы и триггеры (Manual, Schedule). Отдельно разобралась с настройкой внешней базы данных Redis: создавала, читала и удаляла ключи. В качестве ачивки реализовала полноценный REST API для работы с заметками (POST и GET запросы), используя Redis в качестве хранилища.