# Контроллеры {#controllers}

- [Введение](#introduction)
- [Создание контроллеров](#writing-controllers)
  - [Базовые контроллеры](#basic-controllers)
  - [Single Action Controllers](#single-action-controllers)
  - [Вложенные контроллеры и пространства имён](#controller-namespaces)
- [Маршрутизация контроллеров](#controller-routing)
  - [Маршруты контроллеров](#controller-routes)
  - [Маршруты ресурса](#resource-controllers)
  - [Частичные ресурсы](#partial-resource-routes)
  - [Вложенные ресурсы](#nested-resources)
  - [Shallow-маршруты](#shallow-nesting)
  - [Soft-deletable ресурсы](#soft-deletable-resources)
  - [API-ресурсы](#api-resource-routes)
  - [Переименование действий](#restful-naming)
  - [Именование маршрутов](#resource-route-names)
- [Dependency Injection и контейнер](#dependency-injection-and-controllers)
- [Промежуточное ПО](#controller-middleware)
- [Контроллеры-инвокеры](#invokable-controllers)

## Введение {#introduction}

Контроллеры группируют связанную бизнес-логику обработки запросов. Вместо того чтобы определять всю логику непосредственно
в маршрутах, вы можете вынести её в классы. Контроллеры располагаются в каталоге `app/Http/Controllers` и могут быть
организованы по областям ответственности: `Admin`, `Auth`, `API` и т. д.

## Создание контроллеров {#writing-controllers}

Создайте контроллер командой Artisan:

```bash
php artisan make:controller PhotoController
```

Команда создаст класс в `app/Http/Controllers`. Используйте флаг `--invokable`, чтобы сгенерировать контроллер с единственным
методом `__invoke`, и `--resource` для контроллера-ресурса со стандартными действиями.

### Базовые контроллеры {#basic-controllers}

Контроллер — это обычный PHP-класс, который расширяет `App\Http\Controllers\Controller`. Вы можете возвращать строки, ответы,
представления или объекты Response. Пример:

```php
namespace App\Http\Controllers;

use App\Models\Photo;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class PhotoController extends Controller
{
    public function index(): View
    {
        return view('photos.index', [
            'photos' => Photo::latest()->paginate(),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'image' => ['required', 'image'],
        ]);

        $photo = $request->user()->photos()->create($validated);

        return redirect()->route('photos.show', $photo);
    }
}
```

### Single Action Controllers {#single-action-controllers}

Если контроллер обслуживает единственное действие, реализуйте метод `__invoke`:

```php
php artisan make:controller UploadAvatar --invokable
```

```php
class UploadAvatar extends Controller
{
    public function __invoke(Request $request): RedirectResponse
    {
        $request->user()->updateAvatar($request->file('avatar'));

        return back();
    }
}
```

Маршрут регистрируется с помощью `Route::post('/avatar', UploadAvatar::class);`.

### Вложенные контроллеры и пространства имён {#controller-namespaces}

Вы можете группировать контроллеры по подпапкам. Laravel автоматически определит пространство имён на основе расположения
файла. Для контроллеров API можно использовать `php artisan make:controller API/PostController --api`, что создаст класс в
`App\Http\Controllers\API`.

## Маршрутизация контроллеров {#controller-routing}

### Маршруты контроллеров {#controller-routes}

Используйте метод `controller`, чтобы сопоставить множество URI одному классу:

```php
Route::controller(OrderController::class)->group(function () {
    Route::get('/orders/{order}', 'show');
    Route::post('/orders', 'store');
});
```

Метод `controller` применяет базовый префикс ко всем маршрутам группы и позволяет писать имена методов в виде строк без
явного указания контроллера.

### Маршруты ресурса {#resource-controllers}

Контроллер-ресурс соответствует REST-стилю и включает действия `index`, `create`, `store`, `show`, `edit`, `update`, `destroy`.
Генерация маршрута выполняется так:

```php
Route::resource('photos', PhotoController::class);
```

Созданные маршруты можно просмотреть с помощью `php artisan route:list --path=photos`.

### Частичные ресурсы {#partial-resource-routes}

Чтобы сгенерировать только нужные действия, используйте `only` или `except`:

```php
Route::resource('photos', PhotoController::class)->only(['index', 'show']);
```

### Вложенные ресурсы {#nested-resources}

```php
Route::resource('users.posts', PostController::class);
```

URL вида `/users/{user}/posts/{post}` автоматически получат привязку моделей. Используйте `scopeBindings`, чтобы ограничить
дочерние модели родительскими.

### Shallow-маршруты {#shallow-nesting}

Для вложенных ресурсов вы можете сократить вложенность маршрутов, используя `shallow()`:

```php
Route::resource('users.posts', PostController::class)->shallow();
```

Методы `show`, `edit`, `update`, `destroy` получат URI вида `/posts/{post}`.

### Soft-deletable ресурсы {#soft-deletable-resources}

Если модель использует мягкое удаление (`SoftDeletes`), добавьте `->withTrashed()` для маршрутов, которые должны работать с
удалёнными ресурсами, и `->onlyTrashed()` — если маршрут обслуживает только удалённые записи.

### API-ресурсы {#api-resource-routes}

Маршруты API-ресурсов не включают действия `create` и `edit`, предназначенные для отображения форм:

```php
Route::apiResource('photos', Api\PhotoController::class);
```

Laravel также предоставляет метод `apiResources` для регистрации нескольких ресурсов сразу.

### Переименование действий {#restful-naming}

Чтобы изменить имена методов или URI, используйте `names` и `parameters`:

```php
Route::resource('photos', PhotoController::class)->names([
    'create' => 'photos.build',
])->parameters([
    'photos' => 'image',
]);
```

### Именование маршрутов {#resource-route-names}

Стандартные имена маршрутов включают `photos.index`, `photos.store`, `photos.update`. Используйте их для генерации URL через
`route()` и `to_route()`.

## Dependency Injection и контейнер {#dependency-injection-and-controllers}

Контроллеры создаются через сервис-контейнер, поэтому вы можете запрашивать зависимости в конструкторах или методах. Контейнер
автоматически разрешит типизированные аргументы (`Request`, собственные классы, контракты). Для методов ресурсов можно указать
тип прямо в сигнатуре действия.

```php
public function __construct(private PaymentGateway $gateway)
{
    $this->middleware('auth');
}
```

## Промежуточное ПО {#controller-middleware}

Метод `middleware` контроллера позволяет регистрировать посредников для отдельных действий. Вы можете использовать `only` и
`except` для ограничения применения.

```php
public function __construct()
{
    $this->middleware('auth')->only(['create', 'store']);
}
```

## Контроллеры-инвокеры {#invokable-controllers}

Контроллер с методом `__invoke` полезен, когда требуется одна точка входа, например обработчик вебхука. Laravel автоматически
вызывает `__invoke`, когда класс указан в маршруте без метода. Вы можете использовать dependency injection так же, как и в
обычных контроллерах.
