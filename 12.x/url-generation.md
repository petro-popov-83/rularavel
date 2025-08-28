# Генерация URL‑адресов {#url-generation}

**Содержание**

- [Введение](#introduction)
- [Основы](#the-basics)
  - [Создание URL‑адресов](#generating-urls)
  - [Доступ к текущему URL](#accessing-the-current-url)
- [URL‑адреса для именованных маршрутов](#urls-for-named-routes)
  - [Подписанные URL](#signed-urls)
  - [Проверка подписанных URL](#validating-signed-route-requests)
  - [Обработка недействительных подписей](#responding-to-invalid-signed-routes)
- [URL‑адреса для действий контроллеров](#urls-for-controller-actions)
- [Fluent‑объекты URI](#fluent-uri-objects)
- [Значения по умолчанию](#default-values)
  - [Приоритет посредников](#url-defaults-and-middleware-priority)

## Введение {#introduction}

Laravel предоставляет ряд вспомогательных функций для генерации URL‑адресов приложения. Эти функции полезны при построении ссылок в шаблонах, формировании ссылок в API‑ответах и создании перенаправлений в другие части приложения【787950979903197†L269-L272】.

## Основы {#the-basics}

### Создание URL‑адресов {#generating-urls}

Для генерации произвольного URL‑адреса используется вспомогательная функция `url()`. Она автоматически применяет схему (HTTP или HTTPS) и домен из текущего запроса. Например, чтобы создать ссылку на пост с идентификатором 1, можно написать:

```php
$post = App\Models\Post::find(1);
echo url("/posts/{$post->id}");
// http://example.com/posts/1
```

Чтобы добавить параметры строки запроса, можно использовать метод `query()` на возвращаемом объекте URL‑генератора. Этот метод объединит существующие параметры и новые значения. Например:

```php
echo url()->query('/posts', ['search' => 'Laravel']);
// https://example.com/posts?search=Laravel

echo url()->query('/posts?sort=latest', ['search' => 'Laravel']);
// http://example.com/posts?sort=latest&search=Laravel

// Значения, переданные вторым аргументом, перезаписывают существующие параметры:
echo url()->query('/posts?sort=latest', ['sort' => 'oldest']);
// http://example.com/posts?sort=oldest

// Можно передавать массивы для генерации параметров с индексами:
$url = url()->query('/posts', ['columns' => ['title', 'body']]);
// http://example.com/posts?columns[0]=title&columns[1]=body
```

### Доступ к текущему URL {#accessing-the-current-url}

Если вызвать `url()` без аргументов, Laravel вернет экземпляр `Illuminate\Routing\UrlGenerator`, который предоставляет методы для работы с текущим URL【787950979903197†L360-L399】:

```php
// Получить текущий URL без строки запроса
echo url()->current();

// Получить текущий URL со строкой запроса
echo url()->full();

// Получить полный URL предыдущего запроса
echo url()->previous();

// Получить путь предыдущего запроса
echo url()->previousPath();
```

Эти методы также доступны через фасад `URL`:

```php
use Illuminate\Support\Facades\URL;
echo URL::current();
```

## URL‑адреса для именованных маршрутов {#urls-for-named-routes}

Вспомогательная функция `route()` позволяет генерировать URL‑адреса для именованных маршрутов. Поскольку ссылки создаются по имени, изменение реального пути маршрута не потребует изменений в коде. Например, если маршрут определен так:

```php
Route::get('/post/{post}', function (Post $post) {
    // ...
})->name('post.show');
```

URL‑адрес можно сгенерировать следующим образом:

```php
echo route('post.show', ['post' => 1]);
// http://example.com/post/1
```

Если маршрут принимает несколько параметров, их можно передать в виде ассоциативного массива. Параметры, отсутствующие в определении маршрута, будут добавлены в строку запроса【787950979903197†L460-L479】:

```php
Route::get('/post/{post}/comment/{comment}', function (Post $post, Comment $comment) {
    // ...
})->name('comment.show');

echo route('comment.show', ['post' => 1, 'comment' => 3]);
// http://example.com/post/1/comment/3

// Дополнительный параметр будет добавлен в query‑строку:
echo route('post.show', ['post' => 1, 'search' => 'rocket']);
// http://example.com/post/1?search=rocket
```

#### Eloquent‑модели

Часто в качестве параметра передается модель Eloquent. В этом случае `route()` автоматически использует ключ маршрута модели (обычно первичный ключ)【787950979903197†L481-L489】:

```php
echo route('post.show', ['post' => $post]);
```

### Подписанные URL {#signed-urls}

Для публично доступных маршрутов, которым требуется защита от подделки ссылок, Laravel поддерживает подписанные URL‑адреса. Они содержат хэш подписи в строке запроса, который позволяет проверить, что URL не был изменен【787950979903197†L492-L521】. Создать подписанный URL можно с помощью метода `signedRoute` фасада `URL`:

```php
use Illuminate\Support\Facades\URL;

return URL::signedRoute('unsubscribe', ['user' => 1]);
```

Если необходимо временно ограничить срок действия ссылки, используйте `temporarySignedRoute` и укажите время истечения:

```php
return URL::temporarySignedRoute(
    'unsubscribe', now()->addMinutes(30), ['user' => 1]
);
```

### Проверка подписанных URL {#validating-signed-route-requests}

Проверить подпись входящего запроса можно вызвав метод `hasValidSignature()` у объекта `Illuminate\Http\Request`【787950979903197†L544-L573】:

```php
use Illuminate\Http\Request;

Route::get('/unsubscribe/{user}', function (Request $request) {
    if (! $request->hasValidSignature()) {
        abort(401);
    }
    // ...
})->name('unsubscribe');
```

При необходимости разрешить изменение некоторых параметров (например, `page` и `order` для пагинации), можно использовать `hasValidSignatureWhileIgnoring()`【787950979903197†L575-L589】:

```php
if (! $request->hasValidSignatureWhileIgnoring(['page', 'order'])) {
    abort(401);
}
```

Вместо ручной проверки подписи можно назначить маршрутному действию посредник `signed`. Он автоматически возвращает код 403 при недействительной подписи【787950979903197†L590-L617】:

```php
Route::post('/unsubscribe/{user}', function (Request $request) {
    // ...
})->name('unsubscribe')->middleware('signed');

// Если подпись не содержит домен, используйте вариант signed:relative
Route::post('/unsubscribe/{user}', function (Request $request) {
    // ...
})->name('unsubscribe')->middleware('signed:relative');
```

#### Обработка недействительных подписей {#responding-to-invalid-signed-routes}

Чтобы настроить собственную страницу для истекших или недействительных подписей, перехватите исключение `InvalidSignatureException` в методе `withExceptions` файла `bootstrap/app.php`【787950979903197†L619-L647】:

```php
use Illuminate\Routing\Exceptions\InvalidSignatureException;

->withExceptions(function (Exceptions $exceptions) {
    $exceptions->render(function (InvalidSignatureException $e) {
        return response()->view('errors.link-expired', status: 403);
    });
});
```

## URL‑адреса для действий контроллеров {#urls-for-controller-actions}

Функция `action()` генерирует URL‑адрес для указанного действия контроллера. Параметры маршрута передаются вторым аргументом в виде массива【787950979903197†L651-L668】:

```php
use App\Http\Controllers\HomeController;

$url = action([HomeController::class, 'index']);

$url = action([UserController::class, 'profile'], ['id' => 1]);
```

## Fluent‑объекты URI {#fluent-uri-objects}

Класс `Illuminate\Support\Uri` предоставляет объектно‑ориентированный интерфейс для создания и модификации URI. Можно получить экземпляр URI из строки, пути, именованного маршрута или действия контроллера【787950979903197†L670-L729】:

```php
use Illuminate\Support\Uri;
use App\Http\Controllers\UserController;
use App\Http\Controllers\InvokableController;

// Создать URI из строки
$uri = Uri::of('https://example.com/path');

// Создать URI для пути, маршрута или действия
$uri = Uri::to('/dashboard');
$uri = Uri::route('users.show', ['user' => 1]);
$uri = Uri::signedRoute('users.show', ['user' => 1]);
$uri = Uri::temporarySignedRoute('user.index', now()->addMinutes(5));
$uri = Uri::action([UserController::class, 'index']);
$uri = Uri::action(InvokableController::class);

// Создать URI для текущего URL запроса
$uri = $request->uri();

// Изменить компоненты URI
$uri = Uri::of('https://example.com')
    ->withScheme('http')
    ->withHost('test.com')
    ->withPort(8000)
    ->withPath('/users')
    ->withQuery(['page' => 2])
    ->withFragment('section-1');
```

## Значения по умолчанию {#default-values}

Иногда удобно задать значения по умолчанию для некоторых параметров маршрутов на протяжении всего запроса. Например, многие маршруты могут содержать параметр `{locale}` для локали. Вместо того чтобы передавать локаль при каждом вызове `route()`, можно определить значение по умолчанию через метод `URL::defaults()`【787950979903197†L758-L776】:

```php
use Illuminate\Support\Facades\URL;

URL::defaults(['locale' => app()->getLocale()]);
```

Наиболее удобное место для вызова `URL::defaults()` — собственный посредник. Например, посредник `SetDefaultLocaleForUrls` может установить локаль текущего пользователя до обработки запроса【787950979903197†L774-L849】:

```php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\URL;
use Symfony\Component\HttpFoundation\Response;

class SetDefaultLocaleForUrls
{
    public function handle(Request $request, Closure $next): Response
    {
        URL::defaults(['locale' => $request->user()->locale]);
        return $next($request);
    }
}
```

После задания значения по умолчанию параметр `locale` можно не передавать при вызове `route()`.

### Приоритет посредников {#url-defaults-and-middleware-priority}

При использовании посредников, устанавливающих значения по умолчанию, важно, чтобы они выполнялись до стандартного посредника `SubstituteBindings`. Это можно настроить в `bootstrap/app.php`, добавив ваш посредник в начало списка приоритета【787950979903197†L853-L879】:

```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->prependToPriorityList(
        before: \Illuminate\Routing\Middleware\SubstituteBindings::class,
        prepend: \App\Http\Middleware\SetDefaultLocaleForUrls::class,
    );
});
```

Таким образом, Laravel будет автоматически использовать значение по умолчанию для параметра, и вам не придется передавать его вручную.
