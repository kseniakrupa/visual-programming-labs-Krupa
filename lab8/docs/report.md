# Лабораторная работа №8. Xano

**Студент:** Крупа Ксения, группа ИИ-241
**Workspace:** `lab8-krupa-api`
**Предметная область:** трекер ML-экспериментов учебной лаборатории
**Ссылка на Swagger:** `https://<instance>.xano.io/api:lab8-krupa/documentation` (подставить свой instance)

---

## 1. Предметная область

Бэкенд обслуживает внутренний трекер ML-экспериментов: проекты, запуски моделей,
наборы данных и участников. Домен выбран по профилю специальности (ИИ), поэтому
модель отличается от типовых «трекеров задач» и «каталогов книг».

Все сущности имеют префикс `krupa_` — фамилия и группа видны в названиях таблиц,
эндпоинтов и в заголовке Swagger (`Krupa — lab8-krupa-api`).

## 2. Промпт для ИИ и что исправлено

### Промпт

> Придумай уникальную предметную область для учебного бэкенда на Xano в рамках
> специальности «Искусственный интеллект». Нужно 3–4 связанные таблицы, минимум
> 2 связи reference, поля типов text, integer, decimal, boolean, timestamp,
> enum, reference. Доменная область — трекер ML-экспериментов. Для каждой
> таблицы — не менее 3 полей. Предложи минимум 4 REST-эндпоинта (список,
> получение по id, создание, обновление, удаление) и укажи, где нужны path- и
> query-параметры. Названия таблиц и эндпоинтов — с префиксом `krupa`.

### Ответ ИИ (сокращённо)

Таблицы `member`, `project`, `experiment`, `dataset`; связи
`project.owner_id → member`, `experiment.project_id → project`,
`dataset.project_id → project`; эндпоинты `GET /experiments`,
`GET /experiments/{id}`, `POST /experiments`, `PATCH /experiments/{id}`,
`DELETE /experiments/{id}`, `GET /projects/{id}/stats`.

### Что исправлено после проверки

| Что предложил ИИ | Что исправлено | Почему |
|---|---|---|
| Отдельная таблица `metric` для метрик | Убрана, метрика хранится в `experiment.metric_name` + `metric_value` | Лишняя нормализация для 2 полей; усложняла бы чтение |
| `dataset.project_id` как обычное integer-поле | Заменено на reference → `krupa_project` | Задание требует минимум 2 связи, а целостность лучше держать на уровне БД |
| `status` строкой | Enum `draft / active / archived` | Валидация на входе, предсказуемые значения в фильтрах |
| Пагинация только `page` | Добавлены `per_page` и `sort` + метаданные `total`, `total_pages` | Без `per_page` нельзя ограничить размер ответа |
| `DELETE` возвращал 200 с телом | 204 No Content | Семантика REST |
| Названия без фамилии | Добавлен префикс `krupa_` | Требование уникальности работы |

## 3. Модель данных

### `krupa_member` — участники

| Поле | Тип | Ограничения |
|---|---|---|
| id | integer (PK, auto) | |
| full_name | text | required, max 120 |
| email | text | required, unique, format email |
| role | enum | `student`, `researcher`, `admin`; default `student` |
| created_at | timestamp | auto |

### `krupa_project` — проекты

| Поле | Тип | Ограничения |
|---|---|---|
| id | integer (PK, auto) | |
| title | text | required, max 140 |
| description | text | optional |
| status | enum | `draft`, `active`, `archived`; default `draft` |
| owner_id | reference → `krupa_member` | required |
| created_at | timestamp | auto |

### `krupa_experiment` — запуски моделей

| Поле | Тип | Ограничения |
|---|---|---|
| id | integer (PK, auto) | |
| project_id | reference → `krupa_project` | required |
| name | text | required, max 120 |
| metric_name | text | required, max 40 |
| metric_value | decimal(10,4) | required |
| epochs | integer | min 1 |
| is_successful | boolean | default false |
| run_at | timestamp | auto |

### `krupa_dataset` — наборы данных

| Поле | Тип | Ограничения |
|---|---|---|
| id | integer (PK, auto) | |
| project_id | reference → `krupa_project` | required |
| title | text | required |
| rows_count | integer | min 0 |
| size_mb | decimal(10,2) | min 0 |
| is_public | boolean | default true |
| uploaded_at | timestamp | auto |

**Связи (3, все reference):**
`krupa_project.owner_id → krupa_member.id`,
`krupa_experiment.project_id → krupa_project.id`,
`krupa_dataset.project_id → krupa_project.id`.

**Данные:** 12 участников, 10 проектов, 18 экспериментов, 14 наборов данных.

## 4. Эндпоинты

| Метод | Путь | Параметры | Назначение |
|---|---|---|---|
| GET | `/experiments` | query: `page`, `per_page`, `project_id`, `is_successful`, `sort` | Список с пагинацией, фильтрами и сортировкой |
| GET | `/experiments/{experiment_id}` | path | Получение по id |
| POST | `/experiments` | body | Создание |
| PATCH | `/experiments/{experiment_id}` | path + body | Обновление |
| DELETE | `/experiments/{experiment_id}` | path | Удаление, 204 |
| GET | `/projects/{project_id}/stats` | path | Агрегаты по проекту |

Ответ списка: `{ items, page, per_page, total, total_pages }`.
Ошибки: 401 без токена, 404 для отсутствующего id, 422 при невалидном теле.

Контракт продублирован в [`../exports/openapi.yaml`](../exports/openapi.yaml).

## 5. Освоенные компоненты Xano

- Database: таблицы, типы полей, enum, decimal, reference, unique-индекс.
- Validation: required, min/max, формат email.
- API Endpoints: GET/POST/PATCH/DELETE, path- и query-параметры.
- Function stack: `db.query`, `db.get`, `db.add`, `db.edit`, `db.delete`,
  `precondition`, `return`, `api.response`.
- Filters: `where`, `sort`, `paginate` (page/per_page), `count`.
- Aggregation: `count`, `sum`, `average` по связанной таблице.
- Swagger / API Documentation: авто-генерация из описаний эндпоинтов.
- Environment variables (base URL) и тестовые запросы во встроенном раннере.

## 6. Ачивки

### Ачивка 2: Пагинация и сортировка

Эндпоинт `GET /experiments` принимает `page` (default 1), `per_page`
(default 10, max 100) и `sort` (например `-run_at`, `metric_value`).
В function stack: `db.query` с `sort` по выбранному полю → `paginate`
(`page`, `per_page`) → `count` для `total` → `return`
`{ items, page, per_page, total, total_pages }`.

**Настройки:** `per_page` ограничен 100, чтобы ответ не превышал лимит;
`sorted` применяется до `paginate`; `total_pages` считается как
`ceil(total / per_page)`.

![Ачивка 2 — пагинация и сортировка](../screenshots/06-achievement-pagination.png)

### Ачивка 1: Агрегация / Rollup

Эндпоинт `GET /projects/{project_id}/stats` возвращает
`experiments_count`, `successful_count`, `avg_metric_value`,
`datasets_count`, `total_dataset_rows`. Реализация — `db.query` по
`krupa_experiment` с фильтром `project_id`, затем `count` и `average` по
`metric_value`; отдельный `db.query` по `krupa_dataset` с `count` и `sum`
по `rows_count`.

**Настройки:** агрегаты считаются на бэкенде в одном запросе, без выгрузки
строк на клиент; пустой проект возвращает нули, а не 404 (404 — только если
самого проекта нет).

![Ачивка 1 — rollup-статистика](../screenshots/07-achievement-rollup.png)

## 7. Swagger

Документация открывается из раздела API → Documentation. В заголовке
присутствует `Krupa`, в описании — `lab8-krupa-api`. Все 6 эндпоинтов
видны в списке, у каждого описаны параметры и схема ответа.

![Swagger со списком эндпоинтов](../screenshots/05-swagger.png)

## 8. Ограничения бесплатного тарифа

- Недоступны Middleware и Triggers — фоновая обработка (например,
  пересчёт статистики по расписанию) не настраивалась, агрегаты считаются
  по запросу.
- Лимит на отправку писем — 100 писем; почтовые эндпоинты в работе не
  использовались.
- Ограниченный размер workspace — 18 экспериментов и 14 датасетов
  занимают незначительную часть квоты.
- Нет доступа к расширенным логам и командным ролям — отладка велась через
  встроенный раннер и историю запросов.

## 9. Скриншоты

| Файл | Что видно |
|---|---|
| `01-dashboard.png` | Главный экран workspace `lab8-krupa-api`, фамилия Krupa |
| `02-entity-model.png` | Схема таблиц и связей |
| `03-database.png` | Таблицы и данные (≥10 записей) |
| `04-endpoints.png` | Список эндпоинтов |
| `05-swagger.png` | Swagger со всеми эндпоинтами |
| `06-achievement-pagination.png` | Запрос с `page`/`per_page`/`sort` и метаданными |
| `07-achievement-rollup.png` | Ответ rollup-эндпоинта |
| `08-export.png` | Экспорт workspace в архив |

## 10. Выводы

Xano позволяет собрать рабочий REST-бэкенд без кода: таблицы с типами и
reference-связями, function stack из готовых операций, пагинация и агрегаты
на стороне сервера, автоматический Swagger. Основная сложность — не в
запросах, а в дисциплине модели: enum и reference экономят валидацию, а
ограничение `per_page` и серверные агрегаты напрямую влияют на стоимость
запроса. Ограничения free-тарифа (нет Middleware/Triggers, 100 писем)
заставляют проектировать вычисления «по требованию», а не по расписанию.
