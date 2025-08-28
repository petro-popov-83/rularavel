# Защита от CSRF {#csrf-protection}

- [Введение](#introduction)
- [Предотвращение CSRF‑атак](#preventing-csrf-requests)
  - [Исключение URI](#excluding-uris)
- [Заголовок X‑CSRF‑Token](#x-csrf-token)
- [Заголовок X‑XSRF‑Token](#x-xsrf-token)

## Введение {#introduction}

Cross‑site request forgery (CSRF) — это атака, при которой злоумышленник заставляет
аутентифицированного пользователя выполнить нежелательный запрос. Например, если в
приложении есть маршрут `/user/email` для изменения адреса электронной почты
через POST‑запрос, злоумышленник может разместить на своём сайте форму,
отправляющую запрос с новым адресом. Как только пользователь перейдёт на этот
сайт, его адрес в вашем приложении будет изменён. Чтобы защититься, необходимо
проверять каждую входящую форму, которая использует методы `POST`, `PUT`,
`PATCH` или `DELETE`, на наличие секретного токена, которым злоумышленник не
может завладеть.

## Предотвращение CSRF‑атак {#preventing-csrf-requests}

Laravel автоматически генерирует CSRF‑токен для каждой активной сессии. Токен
хранится в сессии и используется для проверки того, что запрос исходит от
аутентифицированного пользователя. Получить текущий токен можно через объект
запроса или хелпер `csrf_token()`:

```php
use Illuminate\Http\Request;

Route::get('/token', function (Request $request) {
    // Токен из сессии
    $token = $request->session()->token();

    // Токен через вспомогательную функцию
    $token = csrf_token();

    // ...
});
```

При создании HTML‑форм с методами `POST`, `PUT`, `PATCH` или `DELETE`
необходимо включать скрытое поле `_token`, чтобы посредник
`ValidateCsrfToken` мог проверить запрос. В Blade существует директива
`@csrf`, которая автоматически генерирует это поле:

```html
<form method="POST" action="/profile">
    @csrf

    <!-- Эквивалентно... -->
    <input type="hidden" name="_token" value="{{ csrf_token() }}">
</form>
```

### Исключение URI {#excluding-uris}

Иногда нужно исключить определённые маршруты из проверки CSRF. Например,
если приложение обрабатывает веб‑хуки стороннего сервиса вроде Stripe,
этот сервис не знает о вашем CSRF‑токене. Обычно такие маршруты помещают
вне группы `web` в `routes/web.php`. Кроме того, можно передать
исключения в метод `validateCsrfTokens` при настройке посредников в
`bootstrap/app.php`:

```php
->withMiddleware(function (Middleware $middleware) {
    $middleware->validateCsrfTokens(except: [
        'stripe/*',
        'http://example.com/foo/bar',
        'http://example.com/foo/*',
    ]);
})
```

В режиме тестирования посредник CSRF автоматически отключается.

## Заголовок X‑CSRF‑Token {#x-csrf-token}

Помимо параметра `_token` посредник `ValidateCsrfToken` проверяет
заголовок `X‑CSRF‑TOKEN`. Токен можно добавить в HTML в виде meta‑тега и
затем автоматически вставлять его в заголовки AJAX‑запросов через
библиотеку, например jQuery:

```html
<meta name="csrf-token" content="{{ csrf_token() }}">

<script>
$.ajaxSetup({
    headers: {
        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    }
});
</script>
```

## Заголовок X‑XSRF‑Token {#x-xsrf-token}

Laravel также помещает текущий CSRF‑токен в зашифрованную cookie
`XSRF-TOKEN`, которая отправляется вместе с каждым ответом. Значение этой
cookie можно использовать для установки заголовка `X‑XSRF‑TOKEN`. Некоторые
JavaScript‑фреймворки (Angular, Axios) автоматически читают эту cookie и
устанавливают заголовок на запросах того же домена. По умолчанию файл
`resources/js/bootstrap.js` уже подключает Axios, поэтому этот заголовок
будет отправляться автоматически.