# Генерация URL {#url-generation}

- [Введение](#introduction)
- [Основы](#basic-usage)
- [URL именованных маршрутов](#named-routes)
- [URL к действиям контроллеров](#controller-actions)
- [Поддомены и URL](#signed-urls)
- [Подписанные URL](#temporary-signed-routes)
- [Локализованные URL](#localization)

## Введение {#introduction}

Laravel предоставляет хелперы для генерации URL на основе маршрутов, действий контроллеров и имен. Это упрощает изменение
маршрутизации без поиска всех ссылок вручную.

## Основы {#basic-usage}

Используйте хелпер `url()` или фасад `URL`:

```php
$url = url('/home');
URL::to('/home');
```

## URL именованных маршрутов {#named-routes}

```php
route('profile', ['user' => 1]);
```

Метод `route` автоматически подставляет параметры маршрута и учитывает текущую схему (HTTP/HTTPS). Для создания относительных
ссылок используйте `route('profile', ['user' => 1], false)`.

## URL к действиям контроллеров {#controller-actions}

```php
action([HomeController::class, 'index']);
```

## Поддомены и URL {#signed-urls}

Используйте `URL::route('dashboard', [], true)` для принудительного HTTPS. Для поддоменов определите их в маршруте и передайте
значение:

```php
route('tenant.dashboard', ['account' => $tenant->slug]);
```

## Подписанные URL {#temporary-signed-routes}

Подписанные ссылки позволяют гарантировать, что URL не был изменён. Используйте `URL::signedRoute` или `URL::temporarySignedRoute`:

```php
URL::temporarySignedRoute('unsubscribe', now()->addMinutes(30), ['user' => $user->id]);
```

Middleware `ValidateSignature` проверяет подпись и срок действия.

## Локализованные URL {#localization}

При использовании локализации маршрутов вы можете генерировать URL с нужной локалью. Пакет Laravel Localization или собственные
решения позволяют добавлять префикс языка (`/ru`, `/en`).
