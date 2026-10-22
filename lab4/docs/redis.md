# Часть 3. Redis: создание и удаление ключа

- **Запуск Redis:** Redis запущен через Docker (`docker run -d --name redis -p 6379:6379 redis:7`).
- **Настройка Credentials в n8n:** Host = `host.docker.internal`, Port = `6379`. Пароль не используется.
- **Workflow 1 (flow-09-redis):** Создание ключа `krupa` со значением `hello from Krupa` с помощью ноды Redis (Set), затем чтение этого ключа с помощью ноды Redis (Get).
- **Workflow 2 (flow-10-redis):** Удаление ключа `krupa` с помощью ноды Redis (Delete), затем проверка отсутствия ключа с помощью ноды Redis (Get) — возвращает пустое значение.
- **Скриншоты:** `../screenshots/08-redis-setget-all.png`, `../screenshots/08-redis-setget-output.png` (создание/чтение), `../screenshots/09-redis-delete-all.png`, `../screenshots/09-redis-delete-output.png` (удаление/проверка).