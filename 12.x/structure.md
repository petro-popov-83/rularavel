# Структура каталогов {#directory-structure}

- [Введение](#introduction)
- [Корневой каталог](#the-root-directory)
  - [Каталог app](#the-app-directory)
  - [Каталог bootstrap](#the-bootstrap-directory)
  - [Каталог config](#the-config-directory)
  - [Каталог database](#the-database-directory)
  - [Каталог public](#the-public-directory)
  - [Каталог resources](#the-resources-directory)
  - [Каталог routes](#the-routes-directory)
  - [Каталог storage](#the-storage-directory)
  - [Каталог tests](#the-tests-directory)
  - [Каталог vendor](#the-vendor-directory)
- [Каталог app](#the-app-directory-second)
  - [Каталог Broadcasting](#the-broadcasting-directory)
  - [Каталог Console](#the-console-directory)
  - [Каталог Events](#the-events-directory)
  - [Каталог Exceptions](#the-exceptions-directory)
  - [Каталог Http](#the-http-directory)
  - [Каталог Jobs](#the-jobs-directory)
  - [Каталог Listeners](#the-listeners-directory)
  - [Каталог Mail](#the-mail-directory)
  - [Каталог Models](#the-models-directory)
  - [Каталог Notifications](#the-notifications-directory)
  - [Каталог Policies](#the-policies-directory)
  - [Каталог Providers](#the-providers-directory)
  - [Каталог Rules](#the-rules-directory)

## Введение {#introduction}

Стандартная структура каталога Laravel предназначена для того, чтобы обеспечить удобный старт как для небольших, так и для крупных приложений. Тем не менее вы свободны организовывать приложение так, как вам удобно. Laravel практически не ограничивает расположение классов — главное, чтобы Composer мог автоматически загрузить их.

## Корневой каталог {#the-root-directory}

### Каталог app {#the-app-directory}

Каталог `app` содержит основной код вашего приложения. Большинство классов будет располагаться именно здесь.

### Каталог bootstrap {#the-bootstrap-directory}

Каталог `bootstrap` содержит файл `app.php`, который загружает и инициализирует фреймворк. Здесь же находится каталог `cache` с кэшированными файлами, такими как маршруты и сервисы.

### Каталог config {#the-config-directory}

В каталоге `config` находятся все файлы конфигурации. Полезно пройтись по ним и ознакомиться с доступными параметрами.

### Каталог database {#the-database-directory}

Каталог `database` содержит миграции, фабрики моделей и сиды. При желании здесь можно хранить файл SQLite базы данных.

### Каталог public {#the-public-directory}

Каталог `public` содержит файл `index.php`, который является точкой входа для всех HTTP‑запросов. Здесь располагаются общедоступные ресурсы вашего приложения: изображения, JavaScript и CSS.

### Каталог resources {#the-resources-directory}

Каталог `resources` хранит ваши представления (Blade‑шаблоны) и исходные не‑скомпилированные ресурсы, такие как стили и скрипты.

### Каталог routes {#the-routes-directory}

Каталог `routes` содержит определения маршрутов. По умолчанию присутствуют файлы `web.php` и `console.php`.

`web.php` содержит маршруты, относящиеся к группе middleware `web` ( состояние сессии, защита от CSRF, шифрование cookie ). Если ваше приложение не предоставляет статичный API, большинство маршрутов будет находиться здесь.

`console.php` позволяет определять анонимные консольные команды и задачи планировщика. Также вы можете установить дополнительные файлы маршрутов: `api.php` для REST API и `channels.php` для каналов вещания. Маршруты `api` являются stateless; аутентификация осуществляется через токены, и у них нет доступа к сессии.

### Каталог storage {#the-storage-directory}

Каталог `storage` содержит логи, скомпилированные Blade‑шаблоны, файловые сессии, кеши и другие файлы, сгенерированные фреймворком. Внутри него находятся подкаталоги `app`, `framework` и `logs`.

- `app` можно использовать для хранения файлов, создаваемых вашим приложением.
- `framework` содержит файлы и кэши фреймворка.
- `logs` хранит логи приложения.

Директория `storage/app/public` предназначена для пользовательских файлов ( например, аватары ), которые должны быть доступны по вебу. Создайте символическую ссылку `public/storage`, указывающую на эту директорию, командой:

```
php artisan storage:link
```

### Каталог tests {#the-tests-directory}



## Каталог app {#the-app-directory-second}

### Каталог Broadcasting {#the-broadcasting-directory}

Каталог `Broadcasting` содержит классы каналов вещания. Он создётся автоматически при выполнении команды:

```
php artisan make:channel
```

### Каталог Console {#the-console-directory}

Каталог `Console` включает все пользовательские консольные команды (Artisan). Эти классы генерируются командой `php artisan make:command`.

### Каталог Events {#the-events-directory}

Каталог `Events` создаётся при выполнении `php artisan event:generate` или `php artisan make:event`. В нём хранятся классы событий, которые можно использовать для оповещения различных частей приложения.

### Каталог Exceptions {#the-exceptions-directory}

Каталог `Exceptions` содержит ваши классы исключений. Создавать новые исключения можно с помощью `php artisan make:exception`.

### Каталог Http {#the-http-directory}

Каталог `Http` содержит ваши контроллеры, middleware и form‑запросы. Практически вся логика обработки входящих HTTP‑запросов располагается здесь.

### Каталог Jobs {#the-jobs-directory}

Каталог `Jobs` создаётся командой `php artisan make:job`. Здесь хранятся очереди заданий (queueable jobs) вашего приложения, которые могут выполняться асинхронно либо синхронно в текущем запросе.

### Каталог Listeners {#the-listeners-directory}

Каталог `Listeners` создаётся при генерации слушателей командой `php artisan make:listener` или `php artisan event:generate`. Слушатели обрабатывают события, получая объект события и выполняя логику (например, отправка приветственного письма после регистрации пользователя).

### Каталог Mail {#the-mail-directory}

Каталог `Mail` создаётся командой `php artisan make:mail` и содержит классы, представляющие электронные письма. Они позволяют инкапсулировать логику формирования и отправки почты.

### Каталог Models {#the-models-directory}

Каталог `Models` содержит ваши Eloquent‑модели. Каждая таблица базы данных соответствует классу модели, который отвечает за выполнение запросов и вставку данных.

### Каталог Notifications {#the-notifications-directory}

Каталог `Notifications` создаётся командой `php artisan make:notification`. В нём хранятся классы уведомлений, отправляемые через различные каналы (email, SMS, Slack, база данных и др.).

### Каталог Policies {#the-policies-directory}

Каталог `Policies` создаётся командой `php artisan make:policy` и содержит классы авторизационных политик, которые определяют, может ли пользователь выполнить определённое действие над ресурсом.

### Каталог Providers {#the-providers-directory}

Каталог `Providers` содержит сервис‑провайдеры вашего приложения. Провайдеры загружают сервисы в контейнер, регистрируют события и выполняют другую подготовительную работу. Например, в новом приложении Laravel уже есть `AppServiceProvider`, но вы можете добавлять собственные провайдеры.

### Каталог Rules {#the-rules-directory}

Каталог `Rules` создаётся командой `php artisan make:rule` и содержит классы пользовательских правил валидации. С помощью объектов правил вы можете инкапсулировать сложную логику проверки данных.
Каталог `tests` содержит ваши автоматические тесты. Приложение Laravel поставляется с примерами unit‑ и feature‑тестов на базе Pest или PHPUnit. Выполнить тесты можно через `php artisan test` или `./vendor/bin/phpunit`.

### Каталог vendor {#the-vendor-directory}

Каталог `vendor` содержит зависимости Composer вашего проекта.
