# Конфигурация {#configuration}

- [Введение](#introduction)
- [Доступ к конфигурации](#accessing-configuration-values)
- [Переменные окружения](#environment-configuration)
  - [Файл .env](#the-env-file)
  - [Конфигурация для разных окружений](#environment-specific-configuration)
- [Кэширование конфигурации](#configuration-caching)
- [Защита конфиденциальных данных](#protecting-sensitive-configuration)
- [Конфигурация времени выполнения](#runtime-configuration)

## Введение {#introduction}

Все файлы конфигурации Laravel находятся в каталоге `config`. Каждый файл возвращает массив настроек, который можно
легко читать и модифицировать. Файлы включают настройки базы данных, очередей, кеша, почты и многих других подсистем.

## Доступ к конфигурации {#accessing-configuration-values}

Используйте функцию `config()` для чтения и записи значений во время выполнения:

```php
$value = config('app.timezone');

config(['app.debug' => false]);
```

Вы также можете воспользоваться фасадом `Config`. Изменения, внесённые через `config()`, действуют только в текущем запросе.

## Переменные окружения {#environment-configuration}

### Файл .env {#the-env-file}

Laravel использует пакет [vlucas/phpdotenv](https://github.com/vlucas/phpdotenv) для загрузки переменных окружения из файла `.env`.
Значения считываются при каждом запросе до кэширования конфигурации. Не коммитьте `.env` в систему контроля версий.

### Конфигурация для разных окружений {#environment-specific-configuration}

Используйте переменную `APP_ENV`, чтобы отличать окружения (`local`, `staging`, `production`). Вы можете переопределять
значения в конфигурационных файлах, используя функцию `env()` только во время загрузки конфигурации:

```php
'log_level' => env('LOG_LEVEL', 'debug');
```

После выполнения `php artisan config:cache` значения окружения считываются из кэшированного файла. Поэтому не обращайтесь к
`env()` вне конфигурационных файлов.

## Кэширование конфигурации {#configuration-caching}

Для ускорения загрузки приложения используйте команду:

```bash
php artisan config:cache
```

Она создаёт файл `bootstrap/cache/config.php`. Чтобы очистить кэш, выполните `php artisan config:clear`.

## Защита конфиденциальных данных {#protecting-sensitive-configuration}

Никогда не храните пароли и ключи API в репозитории. Используйте переменные окружения или секреты оркестраторов (AWS Parameter
Store, Azure Key Vault, Laravel Vapor/Cloud). Для командной работы добавляйте пример файла `.env.example`.

## Конфигурация времени выполнения {#runtime-configuration}

Иногда полезно модифицировать конфигурацию во время выполнения. Например, для многосайтовости можно переключать подключение к
базе данных на основе запроса:

```php
config(['database.connections.tenant.database' => $tenant->database]);
```

Однако старайтесь ограничивать подобные изменения, чтобы избежать трудностей с отладкой и кэшированием.
