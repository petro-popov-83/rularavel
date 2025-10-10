# HTTP-запросы {#requests}

- [Введение](#introduction)
- [Доступ к объекту Request](#accessing-the-request)
- [Получение входных данных](#retrieving-input)
- [Файлы и загрузки](#files)
- [Cookies](#cookies)
- [Старые значения](#old-input)
- [Запросы из форм](#request-forms)
- [Пользовательские классы Form Request](#form-requests)

## Введение {#introduction}

Laravel оборачивает входящий HTTP-запрос в экземпляр `Illuminate\Http\Request`, предоставляя удобные методы для работы с данными,
заголовками, файлами и куками.

## Доступ к объекту Request {#accessing-the-request}

Вы можете получить запрос через внедрение зависимостей в контроллер или маршрут:

```php
use Illuminate\Http\Request;

Route::get('/user', function (Request $request) {
    return $request->user();
});
```

## Получение входных данных {#retrieving-input}

Методы `input`, `boolean`, `integer`, `date` и `collect` позволяют безопасно получать данные:

```php
$name = $request->input('name');
$active = $request->boolean('active');
```

Также доступны `only`, `except`, `has`, `filled`, `missing`. Для JSON-запросов используйте `json()`.

## Файлы и загрузки {#files}

Файлы доступны через `file('avatar')`. Используйте `store`, `storeAs` для сохранения в файловой системе:

```php
$path = $request->file('avatar')->store('avatars');
```

Метод `hasFile` проверяет, был ли загружен файл.

## Cookies {#cookies}

Получите куки с помощью `$request->cookie('name')`. Для установки используйте фасад `Cookie` или метод ответа `cookie()`.

## Старые значения {#old-input}

После редиректа значения формы сохраняются в сессии. Используйте `old('email')` в шаблонах Blade. Если необходимо вручную
сохранить значения, вызовите `$request->flash()` или `$request->flashOnly(['email'])`.

## Запросы из форм {#request-forms}

Методы `all`, `query`, `post`, `header` дают доступ к разным источникам данных. Laravel автоматически объединяет значения из
строки запроса и тела POST.

## Пользовательские классы Form Request {#form-requests}

Form Request — классы, объединяющие валидацию и авторизацию. Создайте класс командой:

```bash
php artisan make:request UpdateProfileRequest
```

Определите методы `rules`, `authorize` и при необходимости `messages`. В контроллере укажите тип параметра — Laravel
автоматически выполнит валидацию и передаст проверенные данные через `$request->validated()`.
