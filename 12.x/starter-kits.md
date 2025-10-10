# Стартовые наборы {#starter-kits}

- [Введение](#introduction)
- [Laravel Breeze](#laravel-breeze)
- [Breeze + Livewire / Inertia / Next.js](#breeze-stacks)
- [Laravel Jetstream](#laravel-jetstream)
- [Laravel UI](#laravel-ui)
- [Сторонние наборы](#community-kits)

## Введение {#introduction}

Стартовые наборы предоставляют готовую аутентификацию и базовую структуру фронтенда. Они позволяют быстрее начать проект, а
затем кастомизировать код под свои задачи.

## Laravel Breeze {#laravel-breeze}

Breeze — минималистичный набор с аутентификацией, регистрацией, сбросом пароля и подтверждением email. Установите его:

```bash
composer require laravel/breeze --dev
php artisan breeze:install
npm install
npm run dev
```

Breeze поддерживает Blade, Livewire, Inertia (Vue/React) и API-режим.

## Breeze + Livewire / Inertia / Next.js {#breeze-stacks}

`php artisan breeze:install livewire` устанавливает Livewire-компоненты. Команда `... inertia --vue` или `--react` добавляет
Inertia. Также доступен стек `next`, создающий интеграцию с Next.js.

## Laravel Jetstream {#laravel-jetstream}

Jetstream — более продвинутый набор с профилями пользователя, двухфакторной аутентификацией, управлением командами и API-токенами
через Laravel Sanctum. Jetstream поддерживает Livewire и Inertia. Установка:

```bash
composer require laravel/jetstream
php artisan jetstream:install livewire
npm install && npm run build
```

## Laravel UI {#laravel-ui}

Пакет `laravel/ui` предоставляет устаревшие scaffolding-шаблоны на Bootstrap или Vue. Используйте его для проектов, которым
нужна совместимость со старым фронтендом.

## Сторонние наборы {#community-kits}

Сообщество предлагает готовые шаблоны: [Laravel Filament](https://filamentphp.com), [Wave](https://devdojo.com/wave), [TallStackUI](https://tallstack.dev).
Выберите набор, который соответствует требованиям проекта и стеку (Blade, TALL, Inertia).
