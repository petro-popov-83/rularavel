# Логирование {#logging}

- [Введение](#introduction)
- [Конфигурация каналов](#configuration)
- [Стек каналов](#building-log-stacks)
- [Ежедневные файлы](#daily-files)
- [Внешние сервисы](#logging-external-services)
- [Контекст и дополнительные данные](#contextual-information)
- [Создание собственных каналов](#customizing-monolog)
- [Тестирование логов](#testing)

## Введение {#introduction}

Laravel использует библиотеку [Monolog](https://github.com/Seldaek/monolog). Конфигурация находится в `config/logging.php`. Вы
можете определять каналы, комбинировать их в стеки и отправлять логи в файлы, syslog, Slack, Papertrail и другие сервисы.

## Конфигурация каналов {#configuration}

В файле `config/logging.php` определите драйвер по умолчанию (`LOG_CHANNEL`). Доступные драйверы: `single`, `daily`, `stack`,
`slack`, `papertrail`, `syslog`, `errorlog`, `monolog`, `stackdriver`.

## Стек каналов {#building-log-stacks}

Канал `stack` позволяет объединять несколько каналов. Например, записывать логи одновременно в файл и Slack. Настройте массив
`channels` и укажите `driver` => `stack`.

## Ежедневные файлы {#daily-files}

Драйвер `daily` создаёт новый лог-файл каждый день и хранит заданное количество дней (`days`).

## Внешние сервисы {#logging-external-services}

Драйверы `slack` и `papertrail` позволяют отправлять критические уведомления. Укажите токен или хост/порт. Вы можете добавить
дополнительные каналы Monolog через ключ `tap`, чтобы регистрировать процессоры или форматтеры.

## Контекст и дополнительные данные {#contextual-information}

Используйте методы `Log::info('Сообщение', ['user_id' => 1])`, чтобы добавить контекст. Laravel автоматически добавляет контекст
запроса (идентификатор, IP), если включен `config('app.debug')`.

## Создание собственных каналов {#customizing-monolog}

Используйте драйвер `monolog` и передайте класс обработчика. Вы также можете определить замыкание в массиве `tap`, чтобы
кастомизировать экземпляр Monolog.

## Тестирование логов {#testing}

Метод `Log::fake()` позволяет перехватывать записи и проверять, что сообщение было создано:

```php
Log::fake();

Log::info('Информация');

Log::assertLogged('info', function ($message) {
    return str_contains($message['message'], 'Информация');
});
```
