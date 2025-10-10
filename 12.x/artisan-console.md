# Консоль Artisan {#artisan-console}

- [Введение](#introduction)
- [Запуск команд](#running-commands)
  - [Глобальные опции](#global-options)
  - [Псевдонимы](#command-aliases)
- [Создание команд](#writing-commands)
  - [Структура команды](#command-structure)
  - [Аргументы и параметры](#command-arguments)
  - [Валидация ввода](#command-input-validation)
  - [Вопросы и подтверждения](#command-interaction)
  - [Прогресс-бары и вывод](#progress-bar)
  - [Фоновые задачи](#background-tasks)
- [Планировщик задач](#task-scheduling)
- [Тестирование команд](#testing-commands)

## Введение {#introduction}

Artisan — мощный интерфейс командной строки Laravel. Он предоставляет команды для разработки, тестирования, деплоя и
обслуживания приложения. Все команды зарегистрированы в `app/Console/Kernel.php` и доступны через `php artisan`.

## Запуск команд {#running-commands}

Выполните `php artisan list`, чтобы просмотреть все команды. Для получения справки используйте `php artisan help <команда>`.
Команды поддерживают короткую и длинную форму опций, а также передачу аргументов:

```bash
php artisan make:model Post --migration
php artisan migrate --step
```

### Глобальные опции {#global-options}

- `--env=production` — указать файл окружения.
- `--ansi` / `--no-ansi` — включить или отключить раскраску вывода.
- `-q` / `--quiet` — скрыть вывод.
- `-n` / `--no-interaction` — отключить интерактивные подсказки.

### Псевдонимы {#command-aliases}

Некоторые команды имеют короткие псевдонимы. Например, `php artisan tinker` можно запустить как `php artisan ti`. Вы можете
определять собственные псевдонимы в `protected $commands` консольного ядра.

## Создание команд {#writing-commands}

Создайте класс команды командой `make:command`:

```bash
php artisan make:command ImportReports
```

Команда будет создана в `app/Console/Commands`. Вы можете указать пространство имён с поддиректориями. Для одноразового
выполнения создайте closure-команду в `routes/console.php`.

### Структура команды {#command-structure}

Каждая команда определяет свойства `$signature` и `$description` и реализует метод `handle`. Пример:

```php
class ImportReports extends Command
{
    protected $signature = 'reports:import {path : Путь к CSV-файлу} {--queue}';
    protected $description = 'Импорт аналитических отчётов';

    public function handle(): int
    {
        // ...
        return self::SUCCESS;
    }
}
```

Верните одну из констант `Command::SUCCESS`, `FAILURE` или `INVALID`. Вы можете вызывать другие команды из `handle` с помощью
`$this->call()` и `$this->callSilent()`.

### Аргументы и параметры {#command-arguments}

Определите аргументы и опции в свойстве `$signature`:

- `{user}` — обязательный аргумент.
- `{user?}` — необязательный аргумент.
- `{user*}` — массив аргументов.
- `{--queue}` — булева опция.
- `{--connection=redis}` — опция со значением.
- `{--timeout=60 : Количество секунд}` — опция со справкой.

Для более сложной конфигурации используйте свойство `$inputs` или метод `addArgument` в методе `configure()`.

### Валидация ввода {#command-input-validation}

Используйте метод `validate` фасада `Validator` или встроенные методы для проверки аргументов. Вы можете завершить выполнение
с ошибкой, вызвав `$this->error()` и вернув `Command::FAILURE`.

### Вопросы и подтверждения {#command-interaction}

Методы `ask`, `secret`, `confirm`, `anticipate`, `choice` позволяют взаимодействовать с пользователем. Для автоматизированных
процессов используйте опцию `--no-interaction`, чтобы избежать вопросов.

### Прогресс-бары и вывод {#progress-bar}

Artisan содержит удобные методы для форматирования вывода: `info`, `warn`, `error`, `table`, `components->twoColumnDetail()`.
Прогресс-бары создаются методом `$this->withProgressBar($items, $callback)` или `$this->output->progressStart()`.

### Фоновые задачи {#background-tasks}

Если выполнение команды занимает много времени, рассмотрите очередь заданий. Внутри команды вы можете диспатчить задания через
`Bus::dispatch()` или `Process::run()` для запуска внешних процессов.

## Планировщик задач {#task-scheduling}

Планировщик Laravel позволяет описывать расписание команд в методе `schedule` класса `App\Console\Kernel`.

```php
protected function schedule(Schedule $schedule): void
{
    $schedule->command('reports:import')->dailyAt('02:00');
    $schedule->call(fn () => Log::info('Heartbeat'))->everyTenMinutes();
}
```

Используйте методы `hourly`, `weeklyOn`, `timezone`, `onOneServer`, `withoutOverlapping`, `runInBackground` и события для
гибкой настройки. На сервере планировщик запускается одной задачей cron:

```cron
* * * * * cd /path-to-project && php artisan schedule:run >> /dev/null 2>&1
```

## Тестирование команд {#testing-commands}

Laravel предоставляет хелперы для тестирования команд:

```php
public function test_import_command(): void
{
    Queue::fake();

    $this->artisan('reports:import storage/reports.csv')
        ->expectsOutput('Импорт завершён')
        ->assertExitCode(Command::SUCCESS);
}
```

Методы `expectsQuestion`, `expectsChoice`, `expectsTable` помогают проверять интерактивные команды.
