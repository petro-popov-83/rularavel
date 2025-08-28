# Развертывание {#deployment}

* [Введение](#introduction)
* [Системные требования сервера](#server-requirements)
* [Конфигурация сервера](#server-configuration)
  * [Nginx](#nginx)
  * [FrankenPHP](#frankenphp)
  * [Права на каталоги](#directory-permissions)
* [Оптимизация](#optimization)
  * [Кэширование конфигурации](#caching-configuration)
  * [Кэширование событий](#caching-events)
  * [Кэширование маршрутов](#caching-routes)
  * [Кэширование представлений](#caching-views)
* [Режим отладки](#debug-mode)
* [Маршрут проверки состояния](#the-health-route)
* [Развертывание с Laravel Cloud или Forge](#deploying-with-laravel-cloud-or-forge)
  * [Laravel Cloud](#laravel-cloud)
  * [Laravel Forge](#laravel-forge)

## Введение {#introduction}

Когда вы готовы развернуть приложение Laravel в производственную среду, важно выполнить ряд действий, чтобы ваше приложение работало максимально эффективно. В этом разделе описаны рекомендации и базовые шаги по правильному развертыванию.

## Системные требования сервера {#server-requirements}

Фреймворк Laravel предъявляет несколько минимальных требований к системе. Убедитесь, что ваш веб‑сервер поддерживает версию PHP 8.2 или выше и имеет включённые следующие расширения:

* Ctype PHP Extension
* cURL PHP Extension
* DOM PHP Extension
* Fileinfo PHP Extension
* Filter PHP Extension
* Hash PHP Extension
* Mbstring PHP Extension
* OpenSSL PHP Extension
* PCRE PHP Extension
* PDO PHP Extension
* Session PHP Extension
* Tokenizer PHP Extension
* XML PHP Extension

## Конфигурация сервера {#server-configuration}

### Nginx {#nginx}

Если вы развёртываете приложение на сервере, работающем под Nginx, используйте следующую конфигурацию в качестве отправной точки. Этот файл следует подстроить под вашу конкретную конфигурацию. Как и в примере ниже, веб‑сервер должен перенаправлять все запросы на файл `public/index.php`. Никогда не перемещайте `index.php` в корень проекта, иначе в интернет попадут конфигурационные файлы и другие чувствительные данные.

```
server {
    listen 80;
    listen [::]:80;
    server_name example.com;
    root /srv/example.com/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;
    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ ^/index\.php(/|$) {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

Если вам нужна помощь в управлении сервером, рассмотрите возможность использования полностью управляемой платформы, такой как Laravel Cloud.

### FrankenPHP {#frankenphp}

[FrankenPHP](https://frankenphp.dev) — современный PHP‑сервер приложений, написанный на Go. Чтобы запустить приложение Laravel с помощью FrankenPHP, достаточно выполнить команду:

```
frankenphp php-server -r public/
```

FrankenPHP поддерживает интеграцию с [Laravel Octane](https://laravel.com/docs/12.x/octane), HTTP/3, современное сжатие и позволяет упаковывать приложения Laravel в самостоятельные бинарники.

### Права на каталоги {#directory-permissions}

Laravel должен иметь возможность записывать данные в каталоги `bootstrap/cache` и `storage`. Убедитесь, что процесс веб‑сервера имеет права на запись в эти каталоги.

## Оптимизация {#optimization}

При развертывании приложения в производственную среду следует создать кэш для различных частей приложения: конфигурации, событий, маршрутов и представлений. Для этого предусмотрена удобная команда `optimize`, которая выполняет все действия сразу:

```
php artisan optimize
```

Чтобы очистить все созданные кэши, используйте команду:

```
php artisan optimize:clear
```

Ниже описаны отдельные команды, которые вызываются `optimize`.

### Кэширование конфигурации {#caching-configuration}

Во время процесса развертывания выполните команду `config:cache`:

```
php artisan config:cache
```

Эта команда объединяет все файлы конфигурации Laravel в один кэшированный файл, существенно сокращая количество обращений к файловой системе. После кэширования переменные из `.env` больше не загружаются, поэтому внутри конфигурационных файлов следует использовать функцию `env()` только до вызова `config:cache`.

### Кэширование событий {#caching-events}

Чтобы ускорить сопоставление событий и слушателей, выполните команду:

```
php artisan event:cache
```

### Кэширование маршрутов {#caching-routes}

Для крупных приложений с большим количеством маршрутов вызовите команду:

```
php artisan route:cache
```

Она сохраняет все маршруты в одном кэшированном файле, улучшая производительность регистрации маршрутов.

### Кэширование представлений {#caching-views}

Чтобы предварительно скомпилировать все шаблоны Blade и повысить производительность при отдаче представлений, выполните:

```
php artisan view:cache
```

## Режим отладки {#debug-mode}

Опция `debug` в файле `config/app.php` определяет, сколько информации об ошибке будет отображаться пользователю. По умолчанию она использует значение переменной окружения `APP_DEBUG`. В производственной среде это значение должно быть `false`, иначе вы рискуете раскрыть конфиденциальные данные приложения.

## Маршрут проверки состояния {#the-health-route}

Laravel содержит встроенный маршрут проверки состояния, который позволяет мониторить работоспособность приложения. В производстве этот маршрут можно использовать для уведомления системы мониторинга, балансировщика нагрузки или оркестратора, такого как Kubernetes.

По умолчанию маршрут доступен по адресу `/up` и возвращает код 200, если приложение стартовало без ошибок, и 500 в случае исключений. Переопределить путь можно в файле `bootstrap/app.php`:

```
->withRouting(
    web: __DIR__.'/../routes/web.php',
    commands: __DIR__.'/../routes/console.php',
    health: '/status',
)
```

При обращении к этому маршруту Laravel генерирует событие `Illuminate\Foundation\Events\DiagnosingHealth`, позволяя вам выполнить дополнительные проверки, например, подключение к базе данных или статус кэша. В слушателе события можно выбросить исключение, если обнаружена проблема, и маршрут вернёт 500.

## Развертывание с Laravel Cloud или Forge {#deploying-with-laravel-cloud-or-forge}

### Laravel Cloud {#laravel-cloud}

Если вам нужна полностью управляемая платформа развертывания с автоматическим масштабированием, обратите внимание на [Laravel Cloud](https://cloud.laravel.com). Этот сервис предоставляет готовую инфраструктуру для приложений Laravel: вычислительные ресурсы, базы данных, кэши и объектное хранилище. Платформа создана авторами Laravel и тесно интегрируется с фреймворком, поэтому вы можете продолжать писать код, как привыкли.

### Laravel Forge {#laravel-forge}

Если вы предпочитаете управлять собственными серверами, но не хотите вручную настраивать все сервисы для работы Laravel, воспользуйтесь [Laravel Forge](https://forge.laravel.com). Forge позволяет создавать серверы на провайдерах вроде DigitalOcean, Linode, AWS и других, устанавливает и настраивает все необходимые инструменты: Nginx, MySQL, Redis, Memcached, Beanstalk и т. д. Это упрощает запуск и поддержку надёжных Laravel‑приложений.