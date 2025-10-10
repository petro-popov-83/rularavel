# Сервис-провайдеры {#service-providers}

- [Введение](#introduction)
- [Что делают провайдеры](#what-is-a-service-provider)
- [Создание провайдера](#writing-service-providers)
- [Методы `register` и `boot`](#register-method)
- [Регистрация провайдеров](#registering-providers)
- [Отложенные провайдеры](#deferred-providers)
- [Публикация ресурсов](#publishing)

## Введение {#introduction}

Сервис-провайдеры — точка инициализации Laravel. Они регистрируют привязки в контейнере, события, посредников, маршруты,
прослушиватели очередей и все остальные элементы, необходимые вашему приложению.

## Что делают провайдеры {#what-is-a-service-provider}

Провайдеры содержат методы `register` и `boot`. Метод `register` добавляет сервисы в контейнер, а `boot` выполняет дополнительную
логику после загрузки всех провайдеров.

## Создание провайдера {#writing-service-providers}

Создайте провайдер командой:

```bash
php artisan make:provider BillingServiceProvider
```

Laravel добавит его в `bootstrap/providers.php`, если используется автоматическая регистрация.

## Методы `register` и `boot` {#register-method}

В `register` определите привязки и singleton'ы:

```php
public function register(): void
{
    $this->app->singleton(BillingManager::class);
}
```

Метод `boot` получает любые зависимости через внедрение и может подписываться на события или определять маршруты:

```php
public function boot(Dispatcher $events): void
{
    $events->listen(OrderShipped::class, SendShipmentNotification::class);
}
```

## Регистрация провайдеров {#registering-providers}

Провайдеры перечисляются в `bootstrap/providers.php`. Вы можете добавлять свои классы вручную или через `config/app.php` в массиве
`providers`.

## Отложенные провайдеры {#deferred-providers}

Провайдеры могут грузиться только при необходимости. Реализуйте интерфейс `DeferrableProvider` и определите метод `provides`,
возвращающий список сервисов. Laravel загрузит такой провайдер только при попытке разрешить указанные службы.

## Публикация ресурсов {#publishing}

Провайдеры пакетов могут публиковать конфигурацию, миграции и ресурсы. Используйте метод `publishes` в `boot` и команду
`php artisan vendor:publish` для копирования файлов в приложение.
