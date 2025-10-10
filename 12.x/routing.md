# Маршрутизация {#routing}

- [Основы](#basic-routing)
- [Параметры маршрутов](#route-parameters)
  - [Обязательные параметры](#required-parameters)
  - [Необязательные параметры](#optional-parameters)
  - [Ограничения регулярными выражениями](#regular-expression-constraints)
  - [Глобальные ограничения](#global-constraints)
- [Именованные маршруты](#named-routes)
- [Группы маршрутов](#route-groups)
  - [Промежуточное ПО](#route-group-middleware)
  - [Префиксы](#route-group-prefixes)
  - [Общая конфигурация](#route-group-configuration)
- [Маршрутизация контроллеров](#route-model-binding)
  - [Неявная привязка](#implicit-binding)
  - [Неявная привязка по параметрам перечисления](#enum-binding)
  - [Явная привязка](#explicit-binding)
- [Fallback и перенаправления](#fallback-routes)
- [API и автоматическое оглавление](#api-routes)
- [Кэширование маршрутов](#route-caching)

## Основы {#basic-routing}

Все веб-маршруты Laravel определяются в файлах каталога `routes`. По умолчанию `routes/web.php` обслуживает браузерные
запросы, а `routes/api.php` — stateless API. Для быстрого определения маршрута используйте методы фасада `Route`:

```php
use Illuminate\Support\Facades\Route;

Route::get('/welcome', function () {
    return 'Добро пожаловать!';
});
```

Методы `get`, `post`, `put`, `patch`, `delete`, `options` и `match` соответствуют HTTP-глаголам. Для маршрутов, возвращающих
представления, удобен метод `view`, а для перенаправлений — `redirect`.

```php
Route::view('/about', 'about');
Route::redirect('/old', '/new', 301);
```

Маршруты регистрируются во время выполнения метода `Application::configure()->withRouting(...)` в `bootstrap/app.php`. Вы
можете передать дополнительные файлы маршрутов или полностью взять на себя регистрацию, предоставив замыкание.

Для просмотра списка маршрутов используйте `php artisan route:list`. Добавьте флаги `--path` или `--columns` для фильтрации и
управления выводом.

## Параметры маршрутов {#route-parameters}

### Обязательные параметры {#required-parameters}

```php
Route::get('/users/{user}', function (string $userId) {
    return "Пользователь {$userId}";
});
```

Laravel автоматически извлекает значение между фигурными скобками и передаёт его в обработчик. Параметры передаются в том
порядке, в котором они определены в URI.

При использовании внедрения зависимостей убедитесь, что параметр следует после зависимостей:

```php
use Illuminate\Http\Request;

Route::get('/users/{user}', function (Request $request, string $user) {
    return $request->ip().' → '.$user;
});
```

### Необязательные параметры {#optional-parameters}

Добавьте `?` к имени параметра и укажите значение по умолчанию:

```php
Route::get('/user/{name?}', function (?string $name = 'Гость') {
    return $name;
});
```

### Ограничения регулярными выражениями {#regular-expression-constraints}

Используйте метод `where`, чтобы ограничить формат параметров:

```php
Route::get('/user/{id}/{slug}', function (int $id, string $slug) {
    // ...
})->where(['id' => '[0-9]+', 'slug' => '[A-Za-z-]+']);
```

Часто встречающиеся шаблоны можно задать с помощью `whereNumber`, `whereAlpha`, `whereAlphaNumeric`, `whereUuid`, `whereUlid`,
`whereIn`.

### Глобальные ограничения {#global-constraints}

Определите шаблон в `App\Providers\RouteServiceProvider::boot`:

```php
public function boot(): void
{
    Route::pattern('id', '[0-9]+');
}
```

Все маршруты с параметром `id` автоматически унаследуют это ограничение.

## Именованные маршруты {#named-routes}

Именованные маршруты упрощают генерацию URL и перенаправлений. Используйте метод `name`:

```php
Route::get('/profile', [ProfileController::class, 'show'])
    ->name('profile.show');

return to_route('profile.show');
```

Названия могут быть вложенными (`admin.users.index`). Вы можете проверять активный маршрут в шаблонах с помощью `Route::is`
или директивы Blade `@routeIs`.

## Группы маршрутов {#route-groups}

### Промежуточное ПО {#route-group-middleware}

Чтобы применить один или несколько посредников ко множеству маршрутов, объедините их в группу:

```php
Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('/dashboard', DashboardController::class)->name('dashboard');
    Route::post('/logout', [AuthenticatedSessionController::class, 'destroy']);
});
```

### Префиксы {#route-group-prefixes}

Используйте `prefix` и `name` для добавления префикса URI и имени:

```php
Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('/users', [AdminUsersController::class, 'index'])->name('users.index');
});
```

### Общая конфигурация {#route-group-configuration}

Метод `group` также принимает ключи `controller`, `domain`, `scopeBindings`, `where` и `withoutMiddleware`. Это упрощает
конфигурацию API и панелей администрирования.

## Маршрутизация контроллеров {#route-model-binding}

### Неявная привязка {#implicit-binding}

Laravel может автоматически извлекать модели по параметрам маршрута. Если маршрут содержит `{user}` и контроллер ожидает
`App\Models\User`, Laravel выполнит запрос к базе данных и передаст модель в действие контроллера. По умолчанию поиск выполняется
по первичному ключу (`id`). Вы можете переопределить ключ с помощью метода `getRouteKeyName()` на модели.

Для вложенных отношений используйте функцию `scopeBindings()` или метод `->scopeBindings()` в группе маршрутов, чтобы убедиться,
что дочерняя модель принадлежит родительской.

### Неявная привязка по перечислениям {#enum-binding}

Параметры можно типизировать enum-классами. Laravel преобразует значение URI в соответствующий элемент перечисления:

```php
Route::get('/reports/{status}', function (ReportStatus $status) {
    // ...
});
```

### Явная привязка {#explicit-binding}

В `RouteServiceProvider` вы можете явно указать, как разрешать параметры:

```php
use App\Models\User;

Route::bind('username', function (string $value) {
    return User::where('username', $value)->firstOrFail();
});
```

## Fallback и перенаправления {#fallback-routes}

Используйте `Route::fallback()` для обработки неизвестных маршрутов. Этот маршрут должен быть определён последним, так как
он срабатывает, когда ни один из других маршрутов не подошёл.

## API и автоматическое оглавление {#api-routes}

Файл `routes/api.php` загружает маршруты в группу `api`, добавляя префикс `api` и посредник `api`. Эти маршруты stateless и
не используют сессии. При необходимости переопределите конфигурацию в `bootstrap/app.php` через `withRouting`.

Laravel также предоставляет команду `php artisan route:show` для вывода подробной информации о маршруте.

## Кэширование маршрутов {#route-caching}

На продуктивных серверах используйте `php artisan route:cache` для генерации оптимизированного файла маршрутов. Это особенно
полезно для приложений с большим числом маршрутов и контроллеров. Для сброса кэша выполните `php artisan route:clear`.
