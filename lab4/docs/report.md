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