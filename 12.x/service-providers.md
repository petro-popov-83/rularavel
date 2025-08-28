# Поставщики сервисов {#service-providers}

## Оглавление {#on-this-page}

- [Введение](#introduction)
- [Создание собственных поставщиков](#writing-service-providers)
  - [Метод register](#the-register-method)
  - [Свойства bindings и singletons](#bindings-and-singletons)
  - [Метод boot](#the-boot-method)
  - [Внедрение зависимостей в boot](#boot-method-dependency-injection)
- [Регистрация поставщиков](#registering-providers)
- [Отложенные поставщики](#deferred-providers)

## Введение {#introduction}

**Поставщики сервисов** — это центральная точка начальной загрузки (bootstrapping) приложения Laravel. Ваше приложение и все встроенные компоненты Laravel инициализируются через поставщики сервисов. Под *bootstrapping* подразумевается регистрация различных частей приложения: привязок в контейнере, слушателей событий, посредников, маршрутов и прочего. Именно в поставщиках вы настраиваете компоненты вашего приложения.

Laravel использует десятки поставщиков для загрузки ядра: почтовой системы, очередей, кеша и других. Многие поставщики являются *отложенными*: они не загружаются при каждом запросе, а только когда действительно нужны. Все пользовательские поставщики перечислены в файле `bootstrap/providers.php`.

## Создание собственных поставщиков {#writing-service-providers}

Все поставщики наследуются от базового класса `Illuminate\Support\ServiceProvider`. Обычно в них определены два метода — `register` и `boot`. Для генерации каркаса поставщика используйте Artisan:

```bash
php artisan make:provider ExampleServiceProvider
```

Laravel автоматически добавит новый класс в массив `bootstrap/providers.php`.

### Метод register {#the-register-method}

В методе `register` следует **только** привязывать сервисы в контейнер. Не регистрируйте слушателей событий, маршруты или другие функции, так как другие поставщики могут быть ещё не загружены. В этом методе у вас всегда есть доступ к контейнеру через свойство `$app`. Например, создадим синглтон соединения с Riak:

```php
namespace App\Providers;

use App\Services\Riak\Connection;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Support\ServiceProvider;

class RiakServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(Connection::class, function (Application $app) {
            return new Connection(config('riak'));
        });
    }
}
```

### Свойства bindings и singletons {#bindings-and-singletons}

Если ваш поставщик регистрирует много простых привязок, вы можете воспользоваться свойствами `$bindings` и `$singletons`. Laravel автоматически прочитает эти свойства и зарегистрирует привязки при загрузке поставщика:

```php
namespace App\Providers;

use App\Contracts\DowntimeNotifier;
use App\Contracts\ServerProvider;
use App\Services\DigitalOceanServerProvider;
use App\Services\PingdomDowntimeNotifier;
use App\Services\ServerToolsProvider;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Привязки для контейнера.
     *
     * @var array
     */
    public $bindings = [
        ServerProvider::class => DigitalOceanServerProvider::class,
    ];

    /**
     * Синглтоны для контейнера.
     *
     * @var array
     */
    public $singletons = [
        DowntimeNotifier::class => PingdomDowntimeNotifier::class,
        ServerProvider::class => ServerToolsProvider::class,
    ];
}
```

### Метод boot {#the-boot-method}

Метод `boot` вызывается **после** того, как все остальные поставщики зарегистрированы. Здесь вы можете использовать уже доступные сервисы, регистрировать view‑композиторы, роуты и т. д. Например, зарегистрируем композитор представления:

```php
namespace App\Providers;

use Illuminate\Support\Facades\View;
use Illuminate\Support\ServiceProvider;

class ComposerServiceProvider extends ServiceProvider
{
    public function boot(): void
    {
        View::composer('view', function () {
            // ...
        });
    }
}
```

#### Внедрение зависимостей в boot {#boot-method-dependency-injection}

В методе `boot` можно типизировать зависимости, и контейнер автоматически внедрит их. Например, можно определить макрос для ответа:

```php
use Illuminate\Contracts\Routing\ResponseFactory;

public function boot(ResponseFactory $response): void
{
    $response->macro('serialized', function (mixed $value) {
        // ...
    });
}
```

## Регистрация поставщиков {#registering-providers}

Список поставщиков сервисов хранится в файле `bootstrap/providers.php`. Он возвращает массив классов поставщиков, которые должны быть загружены приложением:

```php
return [
    App\Providers\AppServiceProvider::class,
    App\Providers\ComposerServiceProvider::class,
];
```

При вызове команды `make:provider` Laravel добавит новый класс в этот массив автоматически. Если вы создаёте класс поставщика вручную, добавьте его сами.

## Отложенные поставщики {#deferred-providers}

Если ваш поставщик только регистрирует привязки в контейнере, его можно *отложить*, чтобы улучшить производительность. Отложенные поставщики загружаются только тогда, когда нужно разрешить зарегистрированный сервис. Для этого реализуйте интерфейс `DeferrableProvider` и определите метод `provides`, возвращающий список классов, которые предоставляет поставщик:

```php
namespace App\Providers;

use App\Services\Riak\Connection;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Contracts\Support\DeferrableProvider;
use Illuminate\Support\ServiceProvider;

class RiakServiceProvider extends ServiceProvider implements DeferrableProvider
{
    public function register(): void
    {
        $this->app->singleton(Connection::class, function (Application $app) {
            return new Connection($app['config']['riak']);
        });
    }

    /**
     * Вернуть список сервисов, предоставляемых этим поставщиком.
     */
    public function provides(): array
    {
        return [Connection::class];
    }
}
```

Когда Laravel попытается разрешить класс `Connection`, отложенный поставщик будет автоматически загружен.
