# Трансляции событий {#broadcasting}

- [Введение](#introduction)
- [Конфигурация](#configuration)
  - [Драйверы](#driver-prerequisites)
  - [Учетные данные](#broadcasting-configuration)
- [Определение событий](#defining-broadcast-events)
- [Трансляция событий](#broadcasting-events)
  - [Каналы](#broadcast-channels)
  - [Приватные каналы](#defining-authorization-callbacks)
  - [Присутствие](#authorizing-presence-channels)
- [Прослушивание на клиенте](#client-side-installation)
  - [Laravel Echo](#installing-laravel-echo)
  - [События типа notification](#listening-for-events)
- [Трансляции с Reverb / Pusher / Ably](#supported-broadcasters)
- [Трансляции через очереди](#broadcasting-and-queues)
- [Тестирование](#testing)

## Введение {#introduction}

Laravel предоставляет удобный API для трансляции серверных событий в браузер в реальном времени. Это упрощает создание
чатов, панелей мониторинга, уведомлений и совместной работы. Laravel поддерживает WebSocket-сервер [Laravel Reverb](https://laravel.com/docs/reverb), а также внешние сервисы Pusher, Ably и Socket.io.

## Конфигурация {#configuration}

Все настройки находятся в `config/broadcasting.php`. По умолчанию драйвер `log` просто пишет события в логи. Чтобы
использовать WebSocket-подключение, выберите драйвер `reverb`, `pusher` или `ably` в `.env` (переменная `BROADCAST_DRIVER`).

### Драйверы {#driver-prerequisites}

- **Reverb.** Требует Laravel 11+ и установленный пакет `laravel/reverb`. Запустите `php artisan reverb:install` для генерации
  конфигурации и `php artisan reverb:start` для запуска локального сервера.
- **Pusher.** Зарегистрируйтесь на [pusher.com](https://pusher.com), создайте приложение и скопируйте ключи.
- **Ably.** Создайте аккаунт на [ably.com](https://ably.com) и используйте API-ключ.
- **Redis.** Можно использовать для внутренних трансляций, но для браузера потребуется дополнительный сервер WebSocket.

### Учетные данные {#broadcasting-configuration}

Настройте значения `PUSHER_APP_ID`, `PUSHER_APP_KEY`, `PUSHER_APP_SECRET`, `PUSHER_APP_CLUSTER` или аналогичные ключи Ably.
Для Reverb используйте `REVERB_APP_ID`, `REVERB_APP_KEY`, `REVERB_APP_SECRET` и настройте порт/хост в `config/reverb.php`.

## Определение событий {#defining-broadcast-events}

Создайте событие командой `php artisan make:event OrderShipped`. Реализуйте интерфейс `ShouldBroadcast` или `ShouldBroadcastNow`
для немедленной трансляции:

```php
class OrderShipped implements ShouldBroadcast
{
    use SerializesModels;

    public function __construct(public Order $order) {}

    public function broadcastOn(): array
    {
        return [new PrivateChannel('orders.'.$this->order->id)];
    }
}
```

Метод `broadcastAs` позволяет задать пользовательское имя события. По умолчанию событие будет транслироваться с именем класса.

## Трансляция событий {#broadcasting-events}

Диспатчите события с помощью `event(new OrderShipped($order));`. Если событие реализует `ShouldBroadcast`, оно будет отправлено
в очередь `broadcasting`. Убедитесь, что обработчик очереди запущен (`php artisan queue:work`).

### Каналы {#broadcast-channels}

Laravel предоставляет типы каналов: `PublicChannel`, `PrivateChannel`, `PresenceChannel`.

### Приватные каналы {#defining-authorization-callbacks}

Приватные каналы требуют авторизации. Определите правила в `routes/channels.php`:

```php
Broadcast::channel('orders.{order}', function (User $user, Order $order) {
    return $user->id === $order->user_id;
});
```

### Присутствие {#authorizing-presence-channels}

Каналы присутствия позволяют видеть список участников. Возвращайте массив данных о пользователе:

```php
Broadcast::channel('chat.{roomId}', function (User $user, int $roomId) {
    return ['id' => $user->id, 'name' => $user->name];
});
```

## Прослушивание на клиенте {#client-side-installation}

### Laravel Echo {#installing-laravel-echo}

Laravel Echo — библиотека JavaScript для подписки на каналы. Установите её:

```bash
npm install --save-dev laravel-echo pusher-js
```

Для Reverb используйте `laravel-reverb-js`. Настройте Echo в `resources/js/bootstrap.js`:

```js
import Echo from 'laravel-echo';

window.Echo = new Echo({
    broadcaster: 'pusher',
    key: import.meta.env.VITE_PUSHER_APP_KEY,
    wsHost: window.location.hostname,
    wsPort: 6001,
    forceTLS: false,
});
```

### События типа notification {#listening-for-events}

Используйте `Echo.private('orders.' + orderId).listen('OrderShipped', (event) => { ... });` для обработки событий. Для каналов
присутствия используйте `join`, `here`, `joining`, `leaving`.

## Трансляции с Reverb / Pusher / Ably {#supported-broadcasters}

Laravel Reverb предоставляет управляемый сервер WebSocket с масштабированием. Pusher и Ably — облачные провайдеры, которые
автоматически масштабируют соединения и предлагают дополнительные функции (воспроизведение сообщений, отложенные события).
Выберите решение, соответствующее вашему бюджету и требованиям к инфраструктуре.

## Трансляции через очереди {#broadcasting-and-queues}

Трансляции выполняются через очередь `broadcast`. Настройте драйвер очереди (Redis, database, SQS) и запустите воркер. Используйте
`ShouldBroadcastNow`, чтобы пропустить очередь и отправить событие немедленно.

## Тестирование {#testing}

Вы можете фейкать трансляции в тестах:

```php
Broadcast::fake();

event(new OrderShipped($order));

Broadcast::assertSentOnChannel('private-orders.'.$order->id);
```

Также доступны методы `assertNotSent`, `assertSent` и проверка данных события.
