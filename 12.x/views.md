# Представления {#views}

- [Введение](#introduction)
- [Возврат представлений](#creating-views)
- [Передача данных](#passing-data-to-views)
- [Секция `with`](#sharing-data-with-all-views)
- [View Composers](#view-composers)
- [View Models](#view-models)
- [Кэширование представлений](#optimizing-views)

## Введение {#introduction}

Представления отделяют визуальное представление от логики. Laravel использует Blade-шаблоны, хранящиеся в `resources/views`.

## Возврат представлений {#creating-views}

Используйте хелпер `view()`:

```php
return view('welcome');
```

Вы можете возвращать представления из маршрутов, контроллеров, задач и событий.

## Передача данных {#passing-data-to-views}

Передайте массив данных вторым аргументом:

```php
return view('profile', ['user' => $user]);
```

Используйте метод `with` для цепочек: `return view('dashboard')->with('stats', $stats);`.

## Секция `with` {#sharing-data-with-all-views}

Фасад `View::share()` позволяет делиться данными со всеми представлениями, например, названием приложения или конфигурацией меню.

## View Composers {#view-composers}

Компоненты, которые выполняются при рендере конкретных представлений. Зарегистрируйте их в `App\Providers\ViewServiceProvider`:

```php
View::composer('profile', function ($view) {
    $view->with('sidebar', SidebarService::make());
});
```

## View Models {#view-models}

View Models инкапсулируют подготовку данных. Создайте класс, реализующий `Illuminate\View\Viewable`, и верните его из контроллера.

## Кэширование представлений {#optimizing-views}

Команда `php artisan view:cache` компилирует Blade-файлы заранее. Очистите кэш с помощью `php artisan view:clear`.
