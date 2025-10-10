# Защита от CSRF {#csrf-protection}

- [Введение](#introduction)
- [Как работает CSRF-защита](#csrf-introduction)
- [Встроенный middleware](#csrf-middleware)
- [Исключения из проверки](#csrf-excluding-uris)
- [CSRF-токен в формах](#csrf-in-forms)
- [AJAX-запросы и SPA](#csrf-ajax)
- [Проверка в тестах](#csrf-testing)

## Введение {#introduction}

Laravel защищает веб-приложения от подделки межсайтовых запросов (CSRF). Каждый запрос, изменяющий состояние, должен
включать уникальный токен, связанный с текущей сессией пользователя.

## Как работает CSRF-защита {#csrf-introduction}

При загрузке страницы Laravel генерирует токен и сохраняет его в сессии. Когда пользователь отправляет форму, токен передаётся
вместе с запросом и сверяется middleware `VerifyCsrfToken`. Если токен отсутствует или неверен, выбрасывается исключение
`TokenMismatchException`.

## Встроенный middleware {#csrf-middleware}

Middleware `VerifyCsrfToken` зарегистрирован в группе `web`. Он автоматически применяет защиту ко всем POST, PUT, PATCH,
DELETE-запросам. API-маршруты, определённые в `routes/api.php`, не используют сессии и, следовательно, не требуют CSRF.

## Исключения из проверки {#csrf-excluding-uris}

Иногда необходимо отключить проверку токена для определённых URL, например, для вебхуков. Добавьте URI в свойство `$except`
класса `App\Http\Middleware\VerifyCsrfToken`:

```php
protected $except = [
    'stripe/webhook',
];
```

## CSRF-токен в формах {#csrf-in-forms}

Используйте директиву Blade `@csrf` или хелпер `csrf_field()` внутри HTML-форм:

```blade
<form method="POST" action="/profile">
    @csrf
    <!-- поля -->
</form>
```

Для форм, отправляемых методом PUT, PATCH или DELETE, добавьте `@method('PUT')`.

## AJAX-запросы и SPA {#csrf-ajax}

При работе с Axios или другими библиотеками отправляйте токен в заголовке `X-CSRF-TOKEN`. В шаблонах используйте мета-тег:

```blade
<meta name="csrf-token" content="{{ csrf_token() }}">
```

В `resources/js/bootstrap.js` Laravel по умолчанию считывает мета-тег и добавляет заголовок ко всем запросам Axios. Если вы
пишете SPA на Inertia или Livewire, токены обрабатываются автоматически.

## Проверка в тестах {#csrf-testing}

Методы HTTP-хелперов тестирования (`post`, `put`, `delete`) автоматически добавляют корректный токен, поэтому дополнительная
настройка не требуется. Если вы отключаете middleware в тестах, можете использовать `withoutMiddleware(VerifyCsrfToken::class)`
или передавать `['_token' => csrf_token()]` вручную.
