# Фасады {#facades}

- [Введение](#introduction)
- [Использование фасадов](#using-facades)
- [Фасады и тестирование](#facade-testing)
- [Вспомогательные функции](#helper-functions)
- [Как работают фасады](#how-facades-work)
- [Собственные фасады](#creating-facades)
- [Справочник фасадов](#facade-class-reference)

## Введение {#introduction}

Фасады предоставляют «статический» интерфейс к службам, зарегистрированным в сервис-контейнере. Они упрощают доступ к часто
используемым функциям и повышают читаемость кода, сохраняя тестируемость.

## Использование фасадов {#using-facades}

Чтобы воспользоваться фасадом, импортируйте его из `Illuminate\Support\Facades`:

```php
use Illuminate\Support\Facades\Cache;

Cache::put('key', 'value', 600);
```

Фасады доступны для большинства подсистем: `Route`, `View`, `Response`, `Queue`, `Bus`, `Mail`, `Notification`, `Gate` и др.

## Фасады и тестирование {#facade-testing}

Laravel позволяет подменять поведение фасадов. Используйте метод `shouldReceive`, чтобы задать ожидания для моков:

```php
Cache::shouldReceive('get')
    ->once()
    ->with('key')
    ->andReturn('value');
```

Для сервисов, поддерживающих фейковые реализации, доступны методы `Cache::fake()`, `Mail::fake()`, `Bus::fake()`.

## Вспомогательные функции {#helper-functions}

Многие фасады имеют эквивалентные хелперы: `cache()`, `view()`, `config()`, `route()`. Вы можете использовать оба подхода в
одном приложении.

## Как работают фасады {#how-facades-work}

Фасады наследуются от `Illuminate\Support\Facades\Facade` и переопределяют метод `getFacadeAccessor`, возвращающий ключ привязки
в контейнере. При вызове статического метода фасад получает объект из контейнера и делегирует вызов.

## Собственные фасады {#creating-facades}

Создайте класс, реализующий нужную функциональность, зарегистрируйте его в сервис-провайдере и создайте фасад:

```php
class Payment extends Facade
{
    protected static function getFacadeAccessor(): string
    {
        return 'payment';
    }
}
```

Добавьте привязку в `AppServiceProvider`:

```php
$this->app->singleton('payment', function () {
    return new PaymentGateway();
});
```

Теперь вы можете вызывать `Payment::charge($order);`.

## Справочник фасадов {#facade-class-reference}

Официальная документация содержит таблицу соответствий между фасадами и классами-реализациями. Некоторые примеры:

- `Illuminate\Support\Facades\App` → `Illuminate\Foundation\Application`
- `Illuminate\Support\Facades\Auth` → `Illuminate\Contracts\Auth\Guard`
- `Illuminate\Support\Facades\DB` → `Illuminate\Database\DatabaseManager`
- `Illuminate\Support\Facades\Log` → `Psr\Log\LoggerInterface`
- `Illuminate\Support\Facades\Queue` → `Illuminate\Queue\QueueManager`

Полный перечень смотрите в репозитории документации.
