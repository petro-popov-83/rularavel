# Фронтенд {#frontend}

- [Введение](#introduction)
- [Алпайн, Livewire и Inertia](#full-stack-frameworks)
- [Фронтенд с React / Vue](#spa)
- [Tailwind CSS и UI-пакеты](#tailwind)
- [Inertia.js](#inertia)
- [Livewire](#livewire)
- [Alpine.js](#alpine)
- [Стартовые наборы](#starter-kits)
- [Vite и ассеты](#vite)

## Введение {#introduction}

Laravel — full-stack фреймворк: он одинаково хорошо подходит для SPA, SSR и традиционных серверных приложений. Фреймворк
предоставляет инструменты для управления маршрутизацией, состоянием, аутентификацией и фронтенд-ассетами.

## Алпайн, Livewire и Inertia {#full-stack-frameworks}

Laravel предлагает несколько способов создания реактивных интерфейсов без полной SPA:

- **Livewire** — серверно-рендеримый UI с двухсторонним связыванием данных.
- **Inertia.js** — мост между Laravel и компонентами Vue/React/Svelte.
- **Alpine.js** — лёгкий JavaScript-фреймворк, сочетающийся с Blade.

## Фронтенд с React / Vue {#spa}

Если вы создаёте SPA, используйте Laravel как API-бекенд и Inertia или традиционный REST. Laravel Sanctum обеспечивает
легковесную аутентификацию для SPAs и мобильных приложений. Для SSR интегрируйте Node-сервер или используйте Inertia SSR.

## Tailwind CSS и UI-пакеты {#tailwind}

Большинство стартовых наборов Laravel основаны на Tailwind CSS. Установите Tailwind командой `npm install -D tailwindcss`
и запустите `npx tailwindcss init`. Используйте компоненты от Laravel Breeze, Jetstream, Filament или сторонних библиотек.

## Inertia.js {#inertia}

Inertia позволяет использовать Vue или React без создания отдельного API. Страницы описываются компонентами, а маршруты
определяются в Laravel. Используйте адаптеры `@inertiajs/vue3` или `@inertiajs/react`, а также серверный рендер `@inertiajs/server`.

## Livewire {#livewire}

Livewire создаёт реактивные компоненты без написания JavaScript. Компоненты обрабатывают события на сервере, а Livewire
автоматически синхронизирует состояние через AJAX. Установите пакет `composer require livewire/livewire` и используйте теги
`<livewire:component-name />` в Blade.

## Alpine.js {#alpine}

Alpine добавляет интерактивность с минимальным JavaScript. Подключите `alpinejs` и используйте атрибуты `x-data`, `x-bind`,
`x-on`. Alpine хорошо работает вместе с Livewire и Inertia для небольших взаимодействий.

## Стартовые наборы {#starter-kits}

Laravel предоставляет Breeze (Blade/Livewire/Inertia) и Jetstream. Они включают готовую аутентификацию, сброс пароля, профили
и двухфакторную проверку. Вы можете быстро начать разработку, а затем кастомизировать компоненты.

## Vite и ассеты {#vite}

Сборка фронтенд-ресурсов выполняется через Vite. Подключайте входные точки директивой `@vite` и используйте `npm run dev`
или `npm run build` для разработки и продакшена.
