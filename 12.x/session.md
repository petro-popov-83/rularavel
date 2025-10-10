# Сессии {#session}

- [Введение](#introduction)
- [Конфигурация](#session-configuration)
- [Драйверы сессий](#session-drivers)
- [Чтение и запись данных](#session-usage)
- [Flash-данные](#flash-data)
- [Блокировка сессий](#session-blocking)
- [Удаление и регенерация](#session-lifecycle)

## Введение {#introduction}

Laravel предлагает единый API для различных механизмов хранения сессий: файлы, cookies, БД, Redis, Memcached. По умолчанию
используется драйвер `file`, который хранит сессии в `storage/framework/sessions`.

## Конфигурация {#session-configuration}

Настройки находятся в `config/session.php`. В `.env` используйте переменные `SESSION_DRIVER`, `SESSION_LIFETIME`, `SESSION_DOMAIN`,
`SESSION_SECURE_COOKIE`.

## Драйверы сессий {#session-drivers}

Доступные драйверы:

- `file`
- `cookie`
- `database`
- `apc`
- `memcached`
- `redis`
- `array` (только для тестов)

Для драйвера `database` выполните `php artisan session:table` и `php artisan migrate`.

## Чтение и запись данных {#session-usage}

```php
session(['key' => 'value']);
$value = session('key');

$request->session()->put('cart', $cart);
$request->session()->get('cart', []);
```

## Flash-данные {#flash-data}

Flash-данные доступны только в следующем запросе. Используйте `session()->flash('status', 'Сохранено')` или `reflash`, `keep` для
продления данных.

## Блокировка сессий {#session-blocking}

Для предотвращения гонок используйте `->block()` в RouteServiceProvider или middleware `StartSession`, чтобы блокировать доступ к
сессии на время запроса. Это особенно полезно для драйверов Redis и database.

## Удаление и регенерация {#session-lifecycle}

Методы `forget`, `flush`, `invalidate`, `regenerate` позволяют управлять жизненным циклом. Регенерируйте ID после логина для
защиты от фиксации сессии:

```php
$request->session()->regenerate();
```
