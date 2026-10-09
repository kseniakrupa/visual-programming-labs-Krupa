# Visual Programming Labs

Репозиторий для лабораторных работ по курсу «Визуальное программирование».

**Студент:** Крупа Ксения, группа ИИ-241
**Университет:** ГрГУ им. Я. Купалы

## Структура

```
visual-programming-labs-Krupa/
├── README.md
├── lab1/
│   ├── report.md
│   ├── diagrams/                  BPMN, UML Activity, Sequence, Flowchart
│   └── docs/
│       ├── process_description.md
│       ├── flowchart.md
│       └── sequence.md
└── lab2/                          Node-RED как low-code инструмент
    ├── docs/
    │   ├── api.md                 описание HTTP-эндпоинтов, параметров и ошибок
    │   └── report.md              отчёт по работе
    ├── flows/                     по одному файлу на поток (меню → Import)
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
    │   └── flow-13-rest-crud.json
    └── screenshots/               скриншоты редактора и браузера
```

## Лабораторные работы

| № | Тема | Каталог | Документация |
|---|------|---------|--------------|
| 1 | Моделирование бизнес-процессов | [`lab1/`](lab1/) | [`lab1/report.md`](lab1/report.md) |
| 2 | Node-RED как low-code инструмент | [`lab2/`](lab2/) | [`lab2/docs/report.md`](lab2/docs/report.md), [`lab2/docs/api.md`](lab2/docs/api.md) |

## Лабораторная работа №2 — кратко

* **Способ установки:** Docker, образ `nodered/node-red:latest`.
  Порт `1880`, том `node-red-data` → `/data` внутри контейнера.
* **Версии:** Node-RED v5.0.8, Node.js v24.21.0,
  `node-red-dashboard` 3.6.6, `node-red-contrib-telegrambot` 19.0.3.
* **Потоки:** 13 файлов в `lab2/flows/` — двенадцать по пунктам 2.1–2.12
  задания и один на ачивку.
* **Ачивка:** №5 «REST+ (полный CRUD)» — сущность `task`, пять эндпоинтов,
  статусы 200/201/400/404.
* **Уникальность:** фамилия и группа указаны в `msg.topic`
  (`lab2/krupa-ii241/...`), в именах нод, в payload и в названиях всех потоков.

Подробности — в [`lab2/docs/report.md`](lab2/docs/report.md).
