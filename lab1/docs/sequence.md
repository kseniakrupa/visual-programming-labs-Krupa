# Sequence Diagram — бронирование номера в отеле

```mermaid
sequenceDiagram
    actor Guest as Гость
    participant Site as Система бронирования
    participant Pay as Платёжный шлюз
    participant Mail as Email/SMS-сервис

    Guest->>Site: Запрос на бронь (даты, гости, тип номера)
    Site->>Site: Проверка доступности
    alt Номер доступен
        Site-->>Guest: Показать варианты и цены
        Guest->>Site: Выбор номера и данные гостя
        Site->>Pay: Запрос оплаты
        Pay-->>Site: Результат транзакции
        alt Оплата прошла
            Site->>Mail: Отправить подтверждение
            Mail-->>Guest: Email + SMS с бронью
            Site-->>Guest: Бронь подтверждена
        else Оплата не прошла
            Site-->>Guest: Бронь отменена (таймаут)
        end
    else Номер недоступен
        Site-->>Guest: Предложить альтернативные даты
    end