# Сервис-контейнер {#service-container}

- [Введение](#introduction)
- [Простое разрешение зависимостей](#resolving)
- [Регистрация привязок](#binding)
  - [Связывание классов](#binding-classes)
  - [Singleton](#singleton-bindings)
  - [Контекстные привязки](#contextual-binding)
- [Автоматическое внедрение](#automatic-injection)
- [Интерфейсы и контракты](#binding-interfaces)
- [Метод `extend`](#extending)
- [Метод `bindIf` и `scoped`](#conditional-binding)
- [PSR-11 контейнер](#psr11)

## Введение {#introduction}

Сервис-контейнер Laravel управляет зависимостями и внедрением классов. Он позволяет декларировать зависимости в конструкторах,
а контейнер создаёт и передаёт экземпляры автоматически.

## Простое разрешение зависимостей {#resolving}

Laravel может автоматически создавать объекты, используя рефлексию. Достаточно типизировать аргументы в контроллере или маршруте.

```php
Route::get('/report', function (ReportGenerator $generator) {
    return $generator->generate();
});
```

## Регистрация привязок {#binding}

### Связывание классов {#binding-classes}

```php
$this->app->bind(ReportGenerator::class, function ($app) {
    return new ReportGenerator($app->make(Client::class));
});
```

### Singleton {#singleton-bindings}

```php
$this->app->singleton(Connection::class, function () {
    return new Connection(config('services.crm'));
});
```

### Контекстные привязки {#contextual-binding}

Используйте метод `when`:

```php
$this->app->when(OrderController::class)
    ->needs(PaymentGateway::class)
    ->give(StripeGateway::class);
```

## Автоматическое внедрение {#automatic-injection}

Контейнер поддерживает внедрение в конструктор и методы (`call`). Вы можете вызывать `app()->call([Controller::class, 'method'])`,
и контейнер передаст необходимые зависимости.

## Интерфейсы и контракты {#binding-interfaces}

Привяжите интерфейсы к конкретным реализациям:

```php
$this->app->bind(LoggerInterface::class, FileLogger::class);
```

## Метод `extend` {#extending}

Метод `extend` позволяет модифицировать уже зарегистрированную службу:

```php
$this->app->extend(Cache::class, function ($cache, $app) {
    return new TaggedCache($cache);
});
```

## Метод `bindIf` и `scoped` {#conditional-binding}

`bindIf` регистрирует привязку, если она не определена. `scoped` создаёт экземпляры на время одного запроса.

## PSR-11 контейнер {#psr11}

Контейнер Laravel реализует `Psr\Container\ContainerInterface`. Вы можете внедрять его в сторонние библиотеки и использовать
методы `get` и `has`.
