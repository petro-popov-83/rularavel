# Шаблоны Blade {#blade-templates}

- [Введение](#introduction)
- [Создание шаблонов](#basic-usage)
  - [Переменные](#displaying-data)
  - [Команды управления](#control-structures)
  - [Комментарии](#blade-comments)
  - [Вставка PHP](#php)
- [Компоненты](#components)
  - [Анонимные компоненты](#anonymous-components)
  - [Классовые компоненты](#class-based-components)
  - [Слоты](#component-slots)
  - [Dynamic Components](#dynamic-components)
- [Секции и макеты](#extending-layouts)
- [Включения и стек](#including-subviews)
- [Коллекции и циклы](#loops)
- [Шаблоны для ошибок и уведомлений](#form-input)
- [Предварительная компиляция](#rendering-views)
- [Blade и фронтенд-стек](#blade-and-frontend)

## Введение {#introduction}

Blade — простой, но мощный шаблонизатор, поставляемый с Laravel. Он не ограничивает использование plain PHP и предоставляет
удобный синтаксис для условных конструкций, циклов, компонентов и макетов.

## Создание шаблонов {#basic-usage}

Шаблоны находятся в `resources/views`. Расширение `.blade.php` сообщает Laravel, что файл следует обработать Blade-движком.
Чтобы вернуть представление, используйте `view('welcome')` или `return view('profile', ['user' => $user]);`.

### Переменные {#displaying-data}

Используйте двойные фигурные скобки для экранированного вывода:

```blade
<h1>{{ $user->name }}</h1>
```

Если необходимо вывести HTML, используйте `{!! !!}`. Убедитесь, что данные безопасны для вставки.

### Команды управления {#control-structures}

Blade включает директивы `@if`, `@elseif`, `@else`, `@isset`, `@empty`, `@auth`, `@guest`, `@production`, `@env`.

```blade
@isset($records)
    @foreach ($records as $record)
        {{ $record }}
    @endforeach
@else
    <p>Нет записей.</p>
@endisset
```

Директивы `@switch`, `@case`, `@break`, `@default` позволяют создавать switch-блоки. Для сокращённых условий используйте `@unless`
и `@hasSection`.

### Комментарии {#blade-comments}

Комментарии Blade не попадают в итоговый HTML: `{{-- Комментарий --}}`.

### Вставка PHP {#php}

Используйте директиву `@php` или `@endphp` для небольших блоков. Для длинных участков кода предпочтительнее вынести логику в
контроллеры или View Models.

## Компоненты {#components}

Компоненты позволяют инкапсулировать UI. Создайте компонент командой:

```bash
php artisan make:component Alert
```

Это создаст класс и шаблон `resources/views/components/alert.blade.php`.

### Анонимные компоненты {#anonymous-components}

Вы можете создавать компоненты без класса, разместив шаблон в `resources/views/components/alert.blade.php` и используя `x-alert`:

```blade
<x-alert type="error" :message="$message" />
```

Атрибуты доступны внутри компонента как переменные. Все оставшиеся атрибуты доступны через `$attributes`.

### Классовые компоненты {#class-based-components}

Классовый компонент позволяет описывать бизнес-логику в PHP-классе:

```php
class Alert extends Component
{
    public function __construct(public string $type = 'info')
    {
    }

    public function render(): View
    {
        return view('components.alert');
    }
}
```

### Слоты {#component-slots}

Используйте `{{ $slot }}` для рендера содержимого компонента. Дополнительные именованные слоты объявляются директивой `@slot`.

```blade
<x-layout>
    <x-slot:title>
        Панель управления
    </x-slot:title>

    <p>Добро пожаловать!</p>
</x-layout>
```

### Dynamic Components {#dynamic-components}

Директива `<x-dynamic-component :component="$component" />` позволяет выбирать компонент во время выполнения.

## Секции и макеты {#extending-layouts}

Создайте базовый макет `resources/views/layouts/app.blade.php` и используйте `@extends` и `@section`:

```blade
@extends('layouts.app')

@section('title', 'Главная')

@section('content')
    <h1>Добро пожаловать</h1>
@endsection
```

Директива `@yield` позволяет определить место вывода секции. Используйте `@push` и `@stack` для работы со стеком скриптов и стилей.

## Включения и стек {#including-subviews}

Используйте `@include` для вставки подшаблонов и `@includeWhen`, `@includeUnless`, `@includeFirst` для условного подключения.
`@each` рендерит коллекцию частичных шаблонов.

## Коллекции и циклы {#loops}

Директивы `@foreach`, `@for`, `@while`, `@forelse` обеспечивают знакомый синтаксис. Внутри цикла переменная `$loop` предоставляет
информацию о текущей итерации (`$loop->first`, `$loop->last`, `$loop->iteration`).

## Шаблоны для ошибок и уведомлений {#form-input}

Blade-помощники `@error('field')` и `@csrf` упрощают валидацию форм. Директивы `@method('PUT')`, `@method('DELETE')` используются
для эмуляции HTTP-методов. Используйте компонент `x-input-error` из стартовых наборов или создайте собственные.

## Предварительная компиляция {#rendering-views}

Laravel кэширует скомпилированные шаблоны в `storage/framework/views`. Для ускорения деплоя используйте `php artisan view:cache`
и `view:clear` для очистки.

## Blade и фронтенд-стек {#blade-and-frontend}

Blade отлично работает вместе с Alpine.js, Livewire, Inertia и другими инструментами. Вы можете смешивать директивы Blade с
атрибутами `x-data`, `wire:model` и `@click`, создавая реактивные интерфейсы без необходимости писать полный SPA.
