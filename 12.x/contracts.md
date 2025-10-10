# Контракты {#contracts}

- [Введение](#introduction)
- [Зачем использовать контракты](#when-to-use-contracts)
- [Сравнение с фасадами](#contracts-vs-facades)
- [Список основных контрактов](#contract-reference)
- [Как реализованы контракты](#how-contracts-work)
- [Контракты и тестирование](#contracts-and-testing)

## Введение {#introduction}

Контракты Laravel — это набор интерфейсов, определяющих основные службы фреймворка: очередь, кеш, маршрутизация, события,
посредники, запросы и многое другое. Они находятся в пакете `illuminate/contracts` и могут использоваться независимо от
ядра Laravel.

## Зачем использовать контракты {#when-to-use-contracts}

Контракты описывают, какие методы должны быть реализованы сервисом. Они предоставляют стабильный API и упрощают подмену
реализаций. Используйте контракты, когда:

- вы создаёте пакет, который должен работать вне Laravel;
- необходимо явно объявить зависимости класса для упрощения тестирования;
- вы хотите воспользоваться преимуществами инверсии зависимостей.

## Сравнение с фасадами {#contracts-vs-facades}

Фасады предоставляют удобный статический синтаксис, тогда как контракты — явную зависимость через сигнатуру конструктора или
метода. Оба подхода могут использоваться одновременно. Фасады быстрее в использовании, но контракты делают зависимости
явными и упрощают замену реализации в тестах или альтернативных окружениях.

## Список основных контрактов {#contract-reference}

Некоторые часто используемые контракты:

- `Illuminate\Contracts\Auth\Authenticatable`
- `Illuminate\Contracts\Broadcasting\Broadcaster`
- `Illuminate\Contracts\Cache\Repository`
- `Illuminate\Contracts\Config\Repository`
- `Illuminate\Contracts\Container\Container`
- `Illuminate\Contracts\Database\ModelIdentifier`
- `Illuminate\Contracts\Events\Dispatcher`
- `Illuminate\Contracts\Filesystem\Filesystem`
- `Illuminate\Contracts\Mail\Mailer`
- `Illuminate\Contracts\Queue\Queue`
- `Illuminate\Contracts\Routing\UrlGenerator`
- `Illuminate\Contracts\Support\Arrayable`

Полный список доступен в репозитории `illuminate/contracts`. Документация Laravel также содержит таблицу соответствия
между фасадами и контрактами.

## Как реализованы контракты {#how-contracts-work}

В сервис-контейнере каждому контракту соответствует привязка. Например, `Illuminate\Contracts\Queue\Queue` сопоставляется
с реализацией очереди (Redis, database, SQS). При типизации аргумента контейнер автоматически предоставит нужную реализацию.

```php
use Illuminate\Contracts\Queue\Queue;

class ReportController
{
    public function __construct(private Queue $queue)
    {
    }
}
```

## Контракты и тестирование {#contracts-and-testing}

Контракты упрощают подмену зависимостей в тестах. Используйте `Queue::fake()`, `Mail::fake()` или создайте мок, зарегистрировав
его в контейнере:

```php
$this->app->instance(Queue::class, new FakeQueue);
```

Таким образом, ваш код остаётся гибким и готовым к замене реализаций без изменения бизнес-логики.
