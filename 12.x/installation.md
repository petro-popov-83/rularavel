# Установка {#installation}

- [Знакомство с Laravel](#meet-laravel)
  - [Почему Laravel?](#why-laravel)
- [Создание приложения Laravel](#creating-a-laravel-project)
  - [Установка PHP и Composer](#installing-php)
  - [Использование Laravel Installer](#laravel-installer)
  - [Создание через Composer](#via-composer)
  - [Создание через GitHub Codespaces](#codespaces)
- [Начальная конфигурация](#initial-configuration)
  - [Переменные окружения](#environment-based-configuration)
  - [Конфигурация приложения](#application-configuration)
  - [Базы данных и миграции](#databases-and-migrations)
- [Локальная среда разработки](#local-development-environments)
  - [Laravel Herd](#laravel-herd)
  - [Laravel Sail](#laravel-sail)
  - [Сторонние решения](#other-local-environments)
- [Поддержка IDE и инструменты](#ide-support)
- [Laravel и ИИ](#laravel-and-ai)
- [Следующие шаги](#next-steps)
  - [Laravel как full-stack фреймворк](#laravel-the-fullstack-framework)
  - [Laravel как API-бекенд](#laravel-the-api-backend)

## Знакомство с Laravel {#meet-laravel}

Laravel — это современный веб-фреймворк с выразительным, элегантным синтаксисом. Он предоставляет структуру и стартовую
точку для разработки вашего приложения, позволяя сосредоточиться на создании продукта, пока инфраструктура и типовые
задачи берёт на себя сам фреймворк.

Мы стремимся сделать работу с Laravel приятной и продуктивной. Фреймворк включает мощные возможности вроде внедрения
зависимостей, выразительного ORM, очередей и задач по расписанию, средств для модульного и интеграционного тестирования,
широкого набора вспомогательных функций и инструментов командной строки.

Laravel одинаково подходит как новичкам, делающим первые шаги в веб-разработке, так и опытным инженерам. Богатая
документация, Laracasts, конференции и активное сообщество помогут вам расти вместе с фреймворком, а когда вы будете
готовы решать задачи уровня предприятия, Laravel предложит инструменты для этого.

### Почему Laravel? {#why-laravel}

#### Прогрессивный фреймворк

Laravel развивается вместе с вами. Стартуйте с базовых руководств, расширяйте знания за счёт пакетов и сервисов экосистемы,
используйте встроенную автоматизацию. Когда возникнет потребность в большем контроле, вы сможете «опуститься на уровень
ниже» и переопределить практически любую часть инфраструктуры.

#### Масштабируемый фреймворк

Благодаря природе PHP и поддержке распределённых систем кеширования (Redis, DynamoDB и др.) горизонтальное масштабирование
Laravel-проектов — понятная задача. Для критичных нагрузок доступны такие сервисы, как [Laravel Cloud](https://cloud.laravel.com)
и [Vapor](https://vapor.laravel.com), которые автоматически управляют инфраструктурой в облаке AWS.

#### Сообщество и экосистема

Laravel объединяет лучшие библиотеки PHP-мира: Symfony-компоненты, популярные пакеты сообщества, инструменты для DevOps.
Тысячи разработчиков создают модули, пакеты и обучающие материалы. Стандартные пакеты Laravel, такие как Horizon, Telescope,
Scout, Cashier, Breeze, Jetstream и другие, закрывают частые бизнес-задачи из коробки.

## Создание приложения Laravel {#creating-a-laravel-project}

### Установка PHP и Composer {#installing-php}

Для работы с Laravel требуется PHP версии 8.2 или выше, расширения `ctype`, `curl`, `dom`, `fileinfo`, `json`, `mbstring`,
`openssl`, `pdo`, `tokenizer`, `xml`. Также необходим менеджер зависимостей [Composer](https://getcomposer.org) и Node.js или
Bun для компиляции ресурсов фронтенда.

- **macOS.** Установите [Homebrew](https://brew.sh), затем выполните:

  ```bash
  brew update
  brew install php composer
  ```

- **Windows.** Самый простой путь — установить [Laravel Herd](https://herd.laravel.com) или официальные сборки PHP с сайта
  [windows.php.net](https://windows.php.net/download/). Herd включает PHP, Nginx и менеджер проектов, а также позволяет
  переключать версии PHP.

- **Linux.** Используйте менеджер пакетов вашего дистрибутива. Например, в Ubuntu:

  ```bash
  sudo apt update
  sudo apt install php-cli php-fpm php-mbstring php-xml php-zip php-curl composer unzip
  ```

### Использование Laravel Installer {#laravel-installer}

Laravel предоставляет глобальный установщик, который ускоряет создание проектов и автоматически генерирует ключ приложения:

```bash
composer global require laravel/installer
```

После установки убедитесь, что директория `~/.composer/vendor/bin` (или `~/Library/Composer/vendor/bin` на macOS, `%USERPROFILE%\AppData\Roaming\Composer\vendor\bin` на Windows) добавлена в переменную окружения `PATH`.

Создайте новое приложение командой:

```bash
laravel new example-app
```

Installer предложит выбрать стек фронтенда, набор аутентификации и запуск миграций. Если вы хотите использовать Git с первого
дня, добавьте флаг `--git`. Для быстрого старта без Node.js используйте `--no-interaction --no-breeze`.

### Создание через Composer {#via-composer}

Если вы не хотите устанавливать Laravel Installer, создайте проект напрямую через Composer:

```bash
composer create-project laravel/laravel example-app
```

Команда скачает актуальный шаблон приложения, установит зависимости и выполнит базовую настройку. Далее перейдите в каталог
проекта и запустите локальный сервер разработки:

```bash
cd example-app
php artisan serve
```

Сервер будет доступен по адресу <http://localhost:8000>.

### Создание через GitHub Codespaces {#codespaces}

Официальный репозиторий Laravel содержит готовый шаблон [GitHub Codespaces](https://github.com/codespaces), позволяющий
запустить Laravel в облачной среде разработки. Нажмите **Use this template → Open in Codespaces**, дождитесь инициализации и
следуйте подсказкам: приложение автоматически поднимется с помощью Laravel Sail.

## Начальная конфигурация {#initial-configuration}

### Переменные окружения {#environment-based-configuration}

В корне проекта находится файл `.env`, содержащий конфиденциальные настройки: ключ приложения, параметры базы данных,
провайдеры очередей, сервисы электронной почты и т. д. Этот файл не должен попадать под контроль версий. Для каждого окружения
создавайте собственный `.env` (например, `.env.local`, `.env.staging`). При развертывании используйте инструмент `php artisan
config:cache`, который собирает конфигурацию в единый файл.

### Конфигурация приложения {#application-configuration}

Каталог `config` содержит файлы с настройками фреймворка и пакетов. Проверьте и настройте следующие параметры:

- `config/app.php`: имя приложения (`name`), URL (`url`), часовой пояс (`timezone`), язык (`locale`).
- `config/database.php`: драйвер по умолчанию, параметры подключения.
- `config/cache.php`, `config/session.php`, `config/queue.php`: драйверы кеша, сессий и очередей.

Для неизменяемых значений используйте конфигурационные файлы, а не `.env`. Значения из `.env` подгружаются только до вызова
`config:cache`, поэтому не обращайтесь к функции `env()` в коде приложения.

### Базы данных и миграции {#databases-and-migrations}

По умолчанию приложение настроено на SQLite. Достаточно создать файл базы данных и запустить миграции:

```bash
touch database/database.sqlite
php artisan migrate
```

Для подключения к MySQL, PostgreSQL, SQL Server или другой СУБД укажите параметры `DB_CONNECTION`, `DB_HOST`, `DB_PORT`,
`DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` в `.env`. Воспользуйтесь командами `php artisan migrate`, `migrate:fresh`,
`db:seed` и `migrate --seed` для управления схемой и начальными данными.

## Локальная среда разработки {#local-development-environments}

### Laravel Herd {#laravel-herd}

[Laravel Herd](https://herd.laravel.com) — официальный нативный стек для macOS и Windows. Herd включает несколько версий PHP,
управление виртуальными хостами `.test`, поддержку Redis, MySQL и почтовых драйверов (в версии Herd Pro). Поместите проект в
каталог, который отслеживает Herd, и приложение автоматически станет доступно по адресу `https://имя-проекта.test`.

CLI Herd позволяет создавать проекты:

```bash
herd new example-app
herd link
```

### Laravel Sail {#laravel-sail}

[Sail](https://laravel.com/docs/sail) — облегчённая среда разработки на Docker. Sail поставляется по умолчанию в каждом
приложении и управляется скриптом `./vendor/bin/sail`.

```bash
./vendor/bin/sail up
```

Sail использует Docker Compose и обеспечивает сервисы MySQL, Redis, Meilisearch, MinIO, Mailpit. Вы можете настроить состав
служб в файле `docker-compose.yml` и переопределить переменные среды в `.env`.

### Сторонние решения {#other-local-environments}

Любая LEMP-/LAMP-среда, отвечающая требованиям к версиям PHP и расширениям, подходит для запуска Laravel. Популярные решения:

- [Laravel Valet](https://laravel.com/docs/valet) для macOS.
- [Homestead](https://laravel.com/docs/homestead) — виртуальная машина Vagrant с полной конфигурацией.
- Lando, DDEV, WSL2 + Nginx или Apache.

При настройке убедитесь, что Document Root указывает на каталог `public` вашего приложения.

## Поддержка IDE и инструменты {#ide-support}

Расширения для IDE ускоряют разработку: Larastan и PHPStan обеспечивают статический анализ, Laravel Pint — автоматическое
форматирование, Laravel Telescope — отладку запросов. Для PHPStorm и JetBrains существует плагин [Laravel Idea](https://plugins.jetbrains.com/plugin/13441-laravel-idea), для VS Code — расширения Laravel Artisan, Blade Snippets и Laravel Extra Intellisense.

## Laravel и ИИ {#laravel-and-ai}

Laravel активно интегрируется с инструментами искусственного интеллекта. Используйте [Laravel Pennant](https://laravel.com/docs/pennant)
для feature-флагов и A/B-тестов, [Laravel Prompt](https://laravel.com/docs/prompt) для работы с LLM в консоли и [Laravel Boost](https://laravel.com/docs/laravel-boost)
для упрощённого доступа к облачным моделям. Установка Boost выполняется командой:

```bash
composer require laravel/boost
```

После установки опубликуйте конфигурацию (`php artisan vendor:publish --tag=boost-config`) и настройте ключи API провайдеров.

## Следующие шаги {#next-steps}

### Laravel как full-stack фреймворк {#laravel-the-fullstack-framework}

Изучите разделы [Маршрутизация](./routing.md), [Структура приложения](./structure.md), [Шаблоны Blade](./blade-templates.md),
[ORM Eloquent](https://laravel.com/docs/eloquent) и [Frontend](./frontend.md). Обратите внимание на стартовые наборы [Breeze](https://laravel.com/docs/starter-kits#laravel-breeze)
и [Jetstream](https://jetstream.laravel.com), которые предоставляют готовые шаблоны аутентификации, профилей и двухфакторной
проверки.

### Laravel как API-бекенд {#laravel-the-api-backend}

Для создания REST или GraphQL API используйте [маршруты API](./routing.md#api-routes), ресурсы [Eloquent](https://laravel.com/docs/eloquent) и
пакеты [Laravel Sanctum](https://laravel.com/docs/sanctum) или [Passport](https://laravel.com/docs/passport) для аутентификации.
Документация также покрывает построение WebSocket-решений на базе [Laravel Reverb](https://laravel.com/docs/reverb) и очередей
для фоновых задач.

Готово! Теперь вы можете продолжить изучение Laravel и построение собственного приложения.
