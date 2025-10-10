# Валидация {#validation}

- [Введение](#introduction)
- [Быстрая проверка](#quick-defining-routes)
- [Использование Validator](#manually-creating-validators)
- [Правила валидации](#available-validation-rules)
- [Сообщения об ошибках](#custom-error-messages)
- [Переводы ошибок](#localization)
- [Форматированные ошибки для API](#validation-and-forms)
- [Форма Request](#form-request-validation)
- [Пользовательские правила](#custom-validation-rules)

## Введение {#introduction}

Валидация защищает приложение от некорректных данных. Laravel предоставляет множество правил и удобных методов для проверки
запросов, массивов и произвольных данных.

## Быстрая проверка {#quick-defining-routes}

Используйте метод `validate` объекта `Request` или глобальный хелпер `validator`:

```php
$request->validate([
    'title' => ['required', 'string', 'max:255'],
    'email' => ['required', 'email'],
]);
```

При ошибке Laravel автоматически перенаправит назад и сохранит ошибки и введённые данные в сессии.

## Использование Validator {#manually-creating-validators}

```php
$validator = Validator::make($data, [
    'name' => 'required|string',
]);

if ($validator->fails()) {
    return back()->withErrors($validator)->withInput();
}
```

Метод `after` позволяет добавить произвольную логику проверки.

## Правила валидации {#available-validation-rules}

Laravel включает десятки правил: `accepted`, `active_url`, `after`, `between`, `boolean`, `confirmed`, `date`, `distinct`, `exists`,
`image`, `integer`, `json`, `min`, `unique`, `url`. Полный список смотрите в официальной документации.

## Сообщения об ошибках {#custom-error-messages}

Передайте массив кастомных сообщений в метод `validate` или `Validator::make`:

```php
$request->validate([
    'email' => 'required|email',
], [
    'email.required' => 'Введите email',
]);
```

## Переводы ошибок {#localization}

Строки ошибок хранятся в `lang/<locale>/validation.php` и `validation.php`. Вы можете переводить сообщения и атрибуты.

## Форматированные ошибки для API {#validation-and-forms}

Для JSON-запросов Laravel возвращает ответ со статусом 422 и списком ошибок. Используйте `throw ValidationException::withMessages()`
для ручного управления.

## Форма Request {#form-request-validation}

Form Request объединяет авторизацию и валидацию. Метод `rules` возвращает набор правил. Используйте `$request->validated()` для
получения проверенных данных.

## Пользовательские правила {#custom-validation-rules}

Создайте правило командой:

```bash
php artisan make:rule Uppercase
```

Реализуйте метод `passes` и `message`. Вы также можете использовать замыкания или `Rule::in`, `Rule::exists`, `Rule::unique` для
сложных сценариев.
