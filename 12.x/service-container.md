# Контейнер сервисов {#service-container}

## Оглавление {#on-this-page}

- [Введение](#introduction)
- [Разрешение без конфигурации](#zero-configuration-resolution)
- [Когда использовать контейнер](#when-to-utilize-the-container)
- [Привязывание](#binding)
  - [Основы привязывания](#binding-basics)
    - [Простые привязки](#simple-bindings)
    - [Привязка синглтонов](#binding-a-singleton)
    - [Scoped‑синглтон](#binding-scoped-singletons)
    - [Привязка существующих экземпляров](#binding-instances)
  - [Привязывание интерфейсов к реализациям](#binding-interfaces-to-implementations)
  - [Контекстное привязывание](#contextual-binding)
    - [Контекстные атрибуты](#contextual-attributes)
    - [Привязывание примитивов](#binding-primitives)
    - [Typed variadic и теги](#binding-typed-variadics)
    - [Тегирование и расширение привязок](#tagging)
- [Разрешение зависимостей](#resolving)
  - [Метод make](#the-make-method)
  - [Автоматическое внедрение](#automatic-injection)
  - [Вызов методов и внедрение](#method-invocation-and-injection)
- [События контейнера](#container-events)
  - [Перебиндинг](#re-binding)
- [PSR‑11](#psr-11)

## Введение {#introduction}

Сервисный контейнер Laravel (container) — это мощный инструмент для управления зависимостями классов и их внедрения. Он позволяет вам объявлять зависимости в конструкторах и методах, а контейнер будет автоматически строить нужные объекты. Например, если контроллеру требуется сервис `AppleMusic`, достаточно указать его в конструкторе, и контейнер создаст экземпляр и передаст его контроллеру【935521583157179†L277-L373】.

Контейнер использует механизм *внедрения зависимостей* (dependency injection):

```php
namespace App\Http\Controllers;

use App\Services\AppleMusic;

class PodcastController extends Controller
{
    /**
     * Создать новый экземпляр контроллера.
     */
    public function __construct(protected AppleMusic $apple)
    {
    }

    /**
     * Показать информацию о подкасте.
     */
    public function show(string $id): Podcast
    {
        return $this->apple->findPodcast($id);
    }
}
```

Контейнер анализирует сигнатуру конструктора и автоматически разрешает все классы, указанные в параметрах.

## Разрешение без конфигурации {#zero-configuration-resolution}

Если ваш класс зависит только от конкретных классов, то вам не нужно заранее регистрировать привязки в контейнере. Laravel автоматически создаст объект, используя рефлексию, когда вы укажете его в маршруте или контроллере. Например, вы можете типизировать аргументы в замыкании маршрута, и контейнер разрешит их сам:

```php
use App\Services\Service;

Route::get('/service', function (Service $service) {
    // $service автоматически создан и передан контейнером
});
```

Этот механизм называется *zero configuration resolution* — контейнер умеет строить объекты без дополнительной настройки【935521583157179†L375-L416】.

## Когда использовать контейнер {#when-to-utilize-the-container}

В большинстве случаев вы будете взаимодействовать с контейнером неявно: достаточно типизировать зависимости в конструкторах, маршрутах, обработчиках очередей и т. д. Однако есть ситуации, когда необходимо явно работать с контейнером:

1. **Привязка интерфейса к реализации.** Если класс реализует интерфейс, и вы хотите указывать интерфейс в типизации, контейнер должен знать, какую конкретную реализацию использовать.
2. **Создание пакетов Laravel.** При разработке пакетов может потребоваться зарегистрировать собственные сервисы в контейнере【192217184031980†L450-L460】.

В этих случаях используется метод `bind` и другие методы привязки, описанные ниже.

## Привязывание {#binding}

### Основы привязывания {#binding-basics}

#### Простые привязки {#simple-bindings}

Большинство привязок регистрируется в *поставщиках сервисов* (service providers). Внутри метода `register` вы можете получить доступ к контейнеру через свойство `$this->app`. Метод `bind` принимает имя класса или интерфейса и замыкание, возвращающее экземпляр:

```php
use App\Services\Transistor;
use App\Services\PodcastParser;
use Illuminate\Contracts\Foundation\Application;

// Внутри ServiceProvider::register
$this->app->bind(Transistor::class, function (Application $app) {
    return new Transistor($app->make(PodcastParser::class));
});
```

Если вы хотите регистрировать привязки вне поставщика, можно использовать фасад `App`:

```php
use App\Services\Transistor;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Support\Facades\App;

App::bind(Transistor::class, function (Application $app) {
    // ...
});
```

Контейнер предоставляет метод `bindIf`, который регистрирует привязку только если она ещё не существует:

```php
$this->app->bindIf(Transistor::class, function (Application $app) {
    return new Transistor($app->make(PodcastParser::class));
});
```

Для удобства можно опустить аргумент типа и указать его в возвращаемом типе замыкания. Laravel самостоятельно определит тип на основе типа возврата:

```php
use App\Services\Transistor;
use App\Services\PodcastParser;

App::bind(function (Application $app): Transistor {
    return new Transistor($app->make(PodcastParser::class));
});
```

Примечание: если класс не зависит от интерфейса, его не нужно регистрировать — контейнер автоматически разрешит такие классы с помощью рефлексии【192217184031980†L542-L558】.

#### Привязка синглтонов {#binding-a-singleton}

Иногда вам нужно, чтобы при каждом разрешении возвращался один и тот же экземпляр. Для этого используется метод `singleton`. После первого разрешения сервис будет сохранён и возвращён при последующих вызовах:

```php
use App\Services\Transistor;
use App\Services\PodcastParser;
use Illuminate\Contracts\Foundation\Application;

$this->app->singleton(Transistor::class, function (Application $app) {
    return new Transistor($app->make(PodcastParser::class));
});
```

Аналогично методу `bindIf` существует метод `singletonIf`, регистрирующий синглтон только если привязка отсутствует【192217184031980†L560-L599】.

С версии 12 вы можете использовать атрибут `#[Singleton]`, чтобы пометить класс как синглтон, и контейнер будет разрешать его только один раз:

```php
use Illuminate\Container\Attributes\Singleton;

#[Singleton]
class Transistor
{
    // ...
}
```

#### Scoped‑синглтон {#binding-scoped-singletons}

Метод `scoped` регистрирует привязку, которая действует в рамках одного жизненного цикла приложения (запрос или фоновая задача). В отличие от обычного синглтона, scoped‑экземпляры сбрасываются при каждом новом запросе или задании очереди. Вы также можете использовать метод `scopedIf` и атрибут `#[Scoped]`, чтобы указать, что класс должен быть создан заново для каждого запроса【192217184031980†L640-L722】.

#### Привязка существующих экземпляров {#binding-instances}

Если у вас уже есть готовый экземпляр, его можно зарегистрировать с помощью метода `instance`. Контейнер всегда будет возвращать именно этот экземпляр:

```php
use App\Services\Transistor;
use App\Services\PodcastParser;

$service = new Transistor(new PodcastParser);
$this->app->instance(Transistor::class, $service);
```

### Привязывание интерфейсов к реализациям {#binding-interfaces-to-implementations}

Одной из сильных сторон контейнера является возможность привязывать интерфейсы к конкретным реализациям. Например, если у вас есть интерфейс `EventPusher` и реализация `RedisEventPusher`, можно зарегистрировать их так:

```php
use App\Contracts\EventPusher;
use App\Services\RedisEventPusher;

$this->app->bind(EventPusher::class, RedisEventPusher::class);
```

Теперь вы можете типизировать интерфейс `EventPusher` в конструкторах, и контейнер внедрит реализацию `RedisEventPusher`【192217184031980†L749-L801】.

Laravel также предоставляет атрибут `#[Bind]`, который можно применять на интерфейсе для указания реализации по умолчанию. Атрибут может быть повторён несколько раз для разных сред (например, `local` или `testing`) и может сочетаться с атрибутами `#[Singleton]` и `#[Scoped]`【192217184031980†L854-L887】. Это уменьшает необходимость писать код в сервис‑провайдерах.

### Контекстное привязывание {#contextual-binding}

Иногда разные классы требуют разных реализаций одного и того же интерфейса. Контейнер предоставляет fluent‑интерфейс `when()->needs()->give()`, который позволяет задавать разные привязки для разных классов. Например, разные контроллеры могут использовать разные диски файловой системы:

```php
use App\Http\Controllers\PhotoController;
use App\Http\Controllers\VideoController;
use Illuminate\Contracts\Filesystem\Filesystem;
use Illuminate\Support\Facades\Storage;

$this->app->when(PhotoController::class)
    ->needs(Filesystem::class)
    ->give(function () {
        return Storage::disk('local');
    });

$this->app->when([VideoController::class, UploadController::class])
    ->needs(Filesystem::class)
    ->give(fn () => Storage::disk('s3'));
```

#### Контекстные атрибуты {#contextual-attributes}

Для типичных случаев Laravel предлагает ряд атрибутов, упрощающих контекстное привязывание. Например, атрибут `#[Storage('local')]` позволяет указать, что нужно использовать локальный диск файловой системы. Существуют атрибуты `Auth`, `Cache`, `Config`, `Context`, `DB`, `Give`, `Log`, `RouteParameter`, `Tag` и другие. Их можно применять к параметрам конструктора, и контейнер автоматически предоставит соответствующее значение【192217184031980†L995-L1070】. Дополнительно есть атрибут `#[CurrentUser]` для внедрения текущего аутентифицированного пользователя в маршрут или класс【192217184031980†L1126-L1146】.

Вы можете создавать собственные атрибуты, реализуя контракт `ContextualAttribute` и определяя метод `resolve` для получения значения. В документации приведён пример, как реализовать кастомный атрибут `Config`, который извлекает значения из конфигурации【192217184031980†L1149-L1249】.

#### Привязывание примитивов {#binding-primitives}

Контекстное привязывание позволяет внедрять не только классы, но и простые значения. Например, чтобы передать в контроллер строку или число, используйте `needs('$variableName')->give(value)`:

```php
$this->app->when(UserController::class)
    ->needs('$pageSize')
    ->give(25);
```

Вы можете использовать метод `giveTagged` для передачи массива всех привязок, отмеченных конкретным тегом, или `giveConfig('app.timezone')` для передачи значения из конфигурационного файла【192217184031980†L1273-L1298】.

#### Typed variadic и теги {#binding-typed-variadics}

Если класс принимает массив объектов через *variadic* аргумент (например, `Filter ...$filters`), можно предоставить массив через контекстное привязывание:

```php
$this->app->when(Firewall::class)
    ->needs(Filter::class)
    ->give(function (Application $app) {
        return [
            $app->make(NullFilter::class),
            $app->make(ProfanityFilter::class),
            $app->make(TooLongFilter::class),
        ];
    });
```

Также можно передать массив имён классов:

```php
$this->app->when(Firewall::class)
    ->needs(Filter::class)
    ->give([
        NullFilter::class,
        ProfanityFilter::class,
        TooLongFilter::class,
    ]);
```

Чтобы сгруппировать разные сервисы в категорию, используйте метод `tag`, а затем получите их все с помощью `tagged`. Например, можно пометить репорты тегом `reports` и затем получить массив всех репортов при разрешении `ReportAnalyzer`【192217184031980†L1452-L1498】.

Метод `extend` позволяет изменять или декорировать уже разрешённые сервисы. Он принимает имя сервиса и замыкание, которое получает текущий экземпляр и контейнер и должно вернуть модифицированный сервис【192217184031980†L1500-L1518】.

## Разрешение зависимостей {#resolving}

### Метод make {#the-make-method}

Чтобы получить экземпляр класса из контейнера вручную, используйте метод `make`. Он принимает имя класса или интерфейса:

```php
use App\Services\Transistor;

$transistor = $this->app->make(Transistor::class);
```

Если у класса есть зависимости, которые невозможно автоматически разрешить, можно передать их массивом через `makeWith`:

```php
$transistor = $this->app->makeWith(Transistor::class, ['id' => 1]);
```

Метод `bound` проверяет, зарегистрирована ли привязка для данного класса. Вне сервис‑провайдеров можно использовать фасад `App` или глобальный вспомогательный метод `app()` для получения экземпляра:

```php
$transistor = App::make(Transistor::class);
$transistor = app(Transistor::class);
```

Если вы хотите внедрить сам экземпляр контейнера, типизируйте `Illuminate\Container\Container` в конструкторе класса, и контейнер передаст себя【192217184031980†L1589-L1616】.

### Автоматическое внедрение {#automatic-injection}

Самый распространённый способ использования контейнера — указать зависимости в конструкторах контроллеров, слушателей событий, посредников (middleware) и обработчиков очередей. Контейнер автоматически разрешит и внедрит нужные сервисы. Пример с контроллером `PodcastController` приведён в разделе «Введение»【192217184031980†L1626-L1697】.

### Вызов методов и внедрение {#method-invocation-and-injection}

Контейнер позволяет вызывать методы и внедрять их зависимости «на лету». С помощью статического метода `App::call()` можно вызвать метод объекта или замыкание, и контейнер передаст все необходимые зависимости:

```php
use App\PodcastStats;
use Illuminate\Support\Facades\App;

$stats = App::call([new PodcastStats, 'generate']);

$result = App::call(function (AppleMusic $apple) {
    // в $apple будет автоматически внедрён сервис AppleMusic
});
```

## События контейнера {#container-events}

Контейнер может испускать события. Метод `resolving` позволяет выполнить код каждый раз, когда контейнер разрешает определённый класс или любой класс. Вы можете использовать это для установки дополнительных свойств или логирования:

```php
$this->app->resolving(Transistor::class, function (Transistor $transistor, Application $app) {
    // вызывается при каждом разрешении Transistor
});

$this->app->resolving(function (mixed $object, Application $app) {
    // вызывается при разрешении любого класса
});
```

### Перебиндинг {#re-binding}

Метод `rebinding` позволяет слушать момент, когда сервис повторно привязывается к контейнеру (например, когда привязка переопределяется). Это полезно, если вам нужно изменить поведение при каждой повторной привязке:

```php
use App\Contracts\PodcastPublisher;
use App\Services\SpotifyPublisher;
use App\Services\TransistorPublisher;

$this->app->bind(PodcastPublisher::class, SpotifyPublisher::class);

$this->app->rebinding(PodcastPublisher::class, function (Application $app, PodcastPublisher $newInstance) {
    // ...
});

// переопределение привязки вызовет callback
$this->app->bind(PodcastPublisher::class, TransistorPublisher::class);
```

## PSR‑11 {#psr-11}

Контейнер Laravel реализует стандартный интерфейс [PSR‑11](https://www.php-fig.org/psr/psr-11/). Поэтому вы можете типизировать `Psr\Container\ContainerInterface` в конструкторе, чтобы получить экземпляр контейнера. Метод `get()` позволит извлечь зарегистрированный сервис, а если сервис не найден, будет выброшено исключение `NotFoundExceptionInterface` или `ContainerExceptionInterface`【192217184031980†L1896-L1931】.
