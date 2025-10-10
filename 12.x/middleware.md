# Middleware {#middleware}

- [Введение](#introduction)
- [Определение middleware](#defining-middleware)
- [Назначение маршрутам](#registering-middleware)
- [Группы посредников](#middleware-groups)
- [Параметры посредников](#middleware-parameters)
- [Завершение запроса](#terminable-middleware)
- [Очистка пользовательских данных](#middleware-and-csrf)
- [Приоритет выполнения](#middleware-priority)

## Введение {#introduction}

Middleware — фильтры HTTP-запросов. Они проверяют аутентификацию, CSRF-токены, кешируют ответы и выполняют другие задачи до и
после обработки запроса.

## Определение middleware {#defining-middleware}

Создайте посредника командой:

```bash
php artisan make:middleware EnsureTokenIsValid
```

В методе `handle` вы можете анализировать запрос и решить, передавать его далее или вернуть ответ:

```php
public function handle(Request $request, Closure $next): Response
{
    if ($request->token !== config('services.api.token')) {
        abort(403);
    }

    return $next($request);
}
```

## Назначение маршрутам {#registering-middleware}

Зарегистрируйте посредник в `App\Http\Kernel::$routeMiddleware`, после чего используйте псевдоним:

```php
Route::get('/profile', ProfileController::class)->middleware('auth');
```

Вы можете применять несколько посредников, передав массив.

## Группы посредников {#middleware-groups}

Laravel предоставляет группы `web` и `api`. Вы можете определять собственные группы в `Kernel::$middlewareGroups` и применять их к
маршрутам или RouteServiceProvider.

## Параметры посредников {#middleware-parameters}

Передайте дополнительные параметры через двоеточие:

```php
Route::post('/posts', PostController::class)->middleware('throttle:60,1');
```

Внутри посредника параметры доступны как дополнительные аргументы метода `handle`.

## Завершение запроса {#terminable-middleware}

Если посреднику нужно выполнить код после отправки ответа, реализуйте метод `terminate`:

```php
public function terminate($request, $response): void
{
    // запись в лог, очистка ресурсов
}
```

## Очистка пользовательских данных {#middleware-and-csrf}

Middleware `TrimStrings` и `ConvertEmptyStringsToNull` автоматически обрабатывают входящие данные. Вы можете настроить их в
`App\Http\Middleware`.

## Приоритет выполнения {#middleware-priority}

Некоторые посредники должны выполняться в определённом порядке. Массив `$middlewarePriority` в `Kernel` задаёт приоритеты для
глобальных и назначаемых посредников.
