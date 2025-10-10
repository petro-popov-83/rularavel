# Деплой {#deployment}

- [Общие рекомендации](#introduction)
- [Подготовка к релизу](#preparing-your-application)
  - [Оптимизация автозагрузки](#autoloader-optimization)
  - [Кэширование конфигурации и маршрутов](#optimizing-configuration)
  - [Сборка ассетов](#optimizing-assets)
- [Серверные требования](#server-requirements)
- [Laravel Vapor и Cloud](#laravel-cloud-platforms)
- [Forge и ручное развёртывание](#forge)
- [Запуск очередей и фоновых задач](#queues)
- [Zero-downtime релизы](#zero-downtime)
- [Мониторинг и наблюдаемость](#monitoring)

## Общие рекомендации {#introduction}

Перед деплоем убедитесь, что ваш код проходит тесты и статический анализ. Используйте CI/CD для автоматизации сборок и проверок.
Старайтесь хранить конфиденциальные данные в переменных окружения и секретах платформы.

## Подготовка к релизу {#preparing-your-application}

### Оптимизация автозагрузки {#autoloader-optimization}

В продакшене выполните:

```bash
composer install --optimize-autoloader --no-dev
```

Команда установит зависимости без dev-пакетов и оптимизирует карту классов.

### Кэширование конфигурации и маршрутов {#optimizing-configuration}

```bash
php artisan config:cache
php artisan route:cache
php artisan event:cache
php artisan view:cache
```

Эти команды сокращают время загрузки приложения.

### Сборка ассетов {#optimizing-assets}

```bash
npm ci
npm run build
```

Или используйте `bun install --frozen-lockfile` для Bun. Убедитесь, что манифест Vite загружен в `public/build`.

## Серверные требования {#server-requirements}

Laravel требует PHP 8.2+, расширения `BCMath`, `Ctype`, `Fileinfo`, `JSON`, `Mbstring`, `OpenSSL`, `PDO`, `Tokenizer`, `XML`,
`Curl`, а также веб-сервер (Nginx, Apache). Убедитесь, что Document Root указывает на директорию `public`. Настройте очередь и
кеш (Redis, Memcached) при необходимости.

## Laravel Vapor и Cloud {#laravel-cloud-platforms}

[Laravel Vapor](https://vapor.laravel.com) и [Laravel Cloud](https://cloud.laravel.com) предлагают управляемые решения для
AWS. Они поддерживают бесшовное масштабирование, zero-downtime деплой и интеграцию с SQS, Redis, RDS. Загрузка приложения и
окружения осуществляется через CLI.

## Forge и ручное развёртывание {#forge}

[Laravel Forge](https://forge.laravel.com) упрощает настройку серверов на DigitalOcean, Linode, AWS и других провайдерах.
Forge устанавливает PHP, Nginx, базу данных, очереди и SSL. При ручной настройке используйте Supervisor или systemd для
запуска очередей и планировщика.

## Запуск очередей и фоновых задач {#queues}

Запустите воркер:

```bash
php artisan queue:work --daemon
```

Используйте Supervisor или systemd для обеспечения постоянной работы. Планировщик запускается cron-записью:

```cron
* * * * * php /path/to/artisan schedule:run >> /dev/null 2>&1
```

## Zero-downtime релизы {#zero-downtime}

Применяйте миграции в транзакциях, используйте флаги `--force` и `--step`. Для zero-downtime примените инструменты,
например, Envoyer, Deployer, Laravel Vapor, которые переключают симлинк на новую сборку после успешного релиза.

## Мониторинг и наблюдаемость {#monitoring}

Используйте Laravel Telescope, Horizon, сторонние сервисы (Laravel Pulse, Bugsnag, Sentry, New Relic). Настройте Health Check
через `Route::get('/up')` и следите за логами в `storage/logs` или через централизованное хранилище.
