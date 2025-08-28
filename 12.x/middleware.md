# Посредники {#middleware}

## Введение {#introduction}

Посредники (middleware) — это слои, через которые проходят HTTP‑запросы по пути к вашему приложению. Они позволяют анализировать и фильтровать запросы. Например, в Laravel есть посредник, проверяющий, авторизован ли пользователь. Если нет — он перенаправляет на страницу входа; если да — пропускает запрос дальше. Другие посредники могут вести журнал входящих запросов, проверять CSRF‑токены и т. д. Пользовательские посредники обычно хранятся в каталоге `app/Http/Middleware`.

## Создание посредников {#defining-middleware}

Для генерации посредника используйте команду Artisan:

```bash
php artisan make:middleware EnsureTokenIsValid
```

Эта команда создаст класс `EnsureTokenIsValid` в каталоге `app/Http/Middleware`. В методе `handle` вы можете проверить условие и либо отклонить запрос (например, вернуть редирект), либо передать его дальше, вызвав `$next($request)`. Представьте посредники как цепочку слоёв — каждый может проверить запрос и даже полностью остановить его прохождение.

### Работа до и после обработки

Посредник может выполнять действия до передачи запроса в приложение или после. Чтобы выполнить действие **до**, просто поместите код перед вызовом `$next($request)`. Чтобы выполнить действие **после**, сохраните результат `$response = $next($request)` и затем выполните необходимые операции перед возвращением ответа.

## Регистрация посредников {#registering-middleware}

### Глобальные посредники

Чтобы посредник выполнялся для каждого запроса, добавьте его в глобальный стек в файле `bootstrap/app.php` с помощью метода `withMiddleware`:

```php
use App\Http\Middleware\EnsureTokenIsValid;

->withMiddleware(function (Middleware $middleware) {
    $middleware->append(EnsureTokenIsValid::class); // добавит в конец списка
    // $middleware->prepend(EnsureTokenIsValid::class) — добавит в начало
});
```

Если хотите полностью контролировать глобальный стек, вы можете передать массив классов в метод `use` и изменять порядок по своему усмотрению.

### Назначение посредников маршрутам

Чтобы назначить посредник конкретному маршруту, вызовите метод `middleware` при определении маршрута:

```php
use App\Http\Middleware\EnsureTokenIsValid;

Route::get('/profile', function () {
    // ...
})->middleware(EnsureTokenIsValid::class);

// назначение нескольких
Route::get('/', function () {
    // ...
})->middleware([First::class, Second::class]);
```

Можно исключить посредник из одного маршрута внутри группы с помощью `withoutMiddleware`. Метод `withoutMiddleware` работает только с маршрутными посредниками и не влияет на глобальные.

### Группы посредников

Несколько посредников можно объединить под одним ключом, чтобы затем применять их как единое целое. В файле `bootstrap/app.php` используйте метод `appendToGroup` или `prependToGroup` для добавления посредников в группу:

```php
use App\Http\Middleware\First;
use App\Http\Middleware\Second;

->withMiddleware(function (Middleware $middleware) {
    $middleware->appendToGroup('group-name', [First::class, Second::class]);
    $middleware->prependToGroup('group-name', [First::class, Second::class]);
});
```

Затем вы можете назначить группу маршруту:

```php
Route::middleware(['group-name'])->group(function () {
    // все маршруты в этой группе используют указанные посредники
});
```

Laravel поставляется с готовыми группами `web` и `api`, которые автоматически применяются к файлам `routes/web.php` и `routes/api.php`. В группу `web` входят посредники для шифрования cookie, запуска сессии, передачи ошибок во представления, проверки CSRF и подстановки привязок моделей; в группу `api` входит посредник `SubstituteBindings`. Вы можете добавлять, заменять или удалять посредники в этих группах с помощью методов `web()` и `api()` или `append`, `prepend`, `replace` и `remove`. Чтобы полностью переопределить содержимое групп, используйте метод `group` и передайте массив классов.

### Псевдонимы посредников

Чтобы использовать короткие имена вместо длинных пространств имён классов, назначьте псевдоним в файле `bootstrap/app.php`:

```php
use App\Http\Middleware\EnsureUserIsSubscribed;

->withMiddleware(function (Middleware $middleware) {
    $middleware->alias([
        'subscribed' => EnsureUserIsSubscribed::class,
    ]);
});

// использование псевдонима
Route::get('/profile', function () {
    // ...
})->middleware('subscribed');
```

Laravel уже определяет ряд стандартных псевдонимов, например: `auth` (Authenticate), `guest`, `signed`, `throttle`, `verified` и другие.

### Упорядочивание посредников

Если вам необходимо задать приоритет выполнения посредников, используйте метод `priority` в `bootstrap/app.php`. Передайте массив классов в порядке, в котором они должны выполняться.

## Параметры посредников {#middleware-parameters}

Посредники могут принимать дополнительные параметры после аргумента `$next`. Например, посредник `EnsureUserHasRole` может проверять, что у пользователя есть конкретная роль:

```php
public function handle(Request $request, Closure $next, string $role): Response
{
    if (! $request->user()->hasRole($role)) {
        // перенаправить или вернуть ошибку
    }
    return $next($request);
}
```

При назначении такого посредника укажите параметры после имени класса через двоеточие и разделяйте несколько параметров запятыми:

```php
Route::put('/post/{id}', function (string $id) {
    // ...
})->middleware(EnsureUserHasRole::class.':editor,publisher');
```

## Завершаемые (terminable) посредники {#terminable-middleware}

Иногда посредник должен выполнить работу после отправки ответа браузеру. Для этого добавьте метод `terminate(Request $request, Response $response)` к вашему посреднику. Этот метод будет вызван автоматически, если ваш веб‑сервер поддерживает FastCGI. Не забудьте зарегистрировать такой посредник в списке глобальных или маршрутных посредников.
