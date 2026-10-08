# Visual Programming Labs

Репозиторий для лабораторных работ по курсу «Визуальное программирование».

**Студент:** Крупа Ксения
**Университет:** ГрГУ им. Я. Купалы

## Структура

```
visual-programming-labs-Krupa/
├── README.md
├── .gitignore
├── lab1/
│   └── docs/
│       └── process_description.md
└── lab2/                          — Node-RED (low-code)
    ├── README.md                  — как развернуть и запустить
    ├── docs/
    │   ├── api.md                 — описание всех HTTP-эндпоинтов
    │   └── report.md              — отчёт по работе
    ├── flows/                     — потоки Node-RED (по файлу на поток)
    │   ├── flow-01-inject-debug.json
    │   ├── flow-02-function.json
    │   ├── flow-03-switch.json
    │   ├── flow-04-change.json
    │   ├── flow-05-template.json
    │   ├── flow-06-http-request.json
    │   ├── flow-07-mqtt.json
    │   ├── flow-08-endpoints.json
    │   ├── flow-09-dashboard.json
    │   ├── flow-10-telegram.json
    │   ├── flow-11-files.json
    │   ├── flow-12-context.json
    │   ├── flow-13-rest-crud.json  — ачивка №5 (REST+ полный CRUD)
    │   └── flows.json              — сводный файл всех потоков
    ├── screenshots/               — скриншоты редактора и браузера
    └── node-red-data/             — docker-volume (в git не хранится)
```

## Лабораторные работы

| № | Тема | Каталог | Документация |
|---|------|---------|--------------|
| 1 | — | [`lab1/`](lab1/) | [`lab1/docs/process_description.md`](lab1/docs/process_description.md) |
| 2 | Node-RED как low-code инструмент | [`lab2/`](lab2/) | [`lab2/docs/report.md`](lab2/docs/report.md), [`lab2/docs/api.md`](lab2/docs/api.md) |

## Лабораторная работа №2 — кратко

* **Установка:** Docker, образ `nodered/node-red:latest`, порт `1880`, volume `lab2/node-red-data` → `/data`.
* **Версии:** Node-RED v5.0.8, Node.js v24.21.0, `node-red-dashboard` 3.6.6, `node-red-contrib-telegrambot` 19.0.3.
* **Потоки:** 13 файлов в `lab2/flows/`, из них 12 — пункты 2.1–2.12 задания, 1 — ачивка.
* **Ачивка:** №5 «REST+ (полный CRUD)» — сущность `task`, пять эндпоинтов, статусы 200/201/400/404.
* **Как запустить:** см. [`lab2/README.md`](lab2/README.md).
