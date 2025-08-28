# Наборы для быстрого старта {#starter-kits}

- [Введение](#introduction)
- [Создание приложения с использованием стартового набора](#creating-an-application-using-a-starter-kit)
- [Доступные стартовые наборы](#available-starter-kits)
  - [React](#react)
  - [Vue](#vue)
  - [Livewire](#livewire)
- [Настройка стартового набора](#starter-kit-customization)
  - [React](#react-customization)
  - [Vue](#vue-customization)
  - [Livewire](#livewire-customization)
- [Аутентификация с помощью WorkOS AuthKit](#workos-authkit-authentication)
- [Inertia SSR](#inertia-ssr)
- [Наборы, поддерживаемые сообществом](#community-maintained-starter-kits)
- [Часто задаваемые вопросы](#frequently-asked-questions)

## Введение {#introduction}

Чтобы помочь вам быстрее начать создание нового приложения Laravel, фреймворк предлагает готовые **стартовые наборы**. Эти наборы предоставляют заготовленные маршруты, контроллеры и шаблоны для регистрации и аутентификации пользователей вашего приложения. Их использование не является обязательным: вы всегда можете начать с чистой установки Laravel и построить всё самостоятельно.

## Создание приложения с использованием стартового набора {#creating-an-application-using-a-starter-kit}

Для создания нового приложения на базе одного из наборов сначала установите PHP и Laravel CLI (инсталлятор) через Composer:

```bash
composer global require laravel/installer
```

Затем выполните команду **`laravel new my-app`**, чтобы создать проект. Во время генерации инсталлятор спросит, какой стартовый набор вы хотите использовать. После создания перейдите в каталог приложения и установите фронтенд‑зависимости:

```bash
cd my-app
npm install && npm run build
composer run dev
```

После запуска сервера ваше приложение будет доступно по адресу `http://localhost:8000`.

## Доступные стартовые наборы {#available-starter-kits}

### React {#react}

Набор **React** создаёт современное приложение с фронтендом на React 19, использует Inertia для организации одностраничного приложения с классическими серверными маршрутами, TypeScript, Tailwind и библиотеку компонентов [shadcn/ui](https://ui.shadcn.com). Такой подход позволяет совместить мощь React с продуктивностью Laravel и быстрым компилятором Vite.

### Vue {#vue}

Набор **Vue** предоставляет стартовую точку для приложений на Vue 3 с использованием Composition API. Он также использует Inertia, TypeScript, Tailwind и компонентную библиотеку [shadcn-vue](https://www.shadcn-vue.com), что позволяет строить современный одностраничный интерфейс с классической серверной маршрутизацией.

### Livewire {#livewire}

Набор **Livewire** — это идеальное решение для команд, предпочитающих шаблоны Blade. Он использует Laravel Livewire 3, Tailwind и библиотеку компонентов Flux UI. Livewire позволяет создавать динамичные реактивные интерфейсы, используя только PHP, без необходимости внедрять полноценный JavaScript‑фреймворк.

## Настройка стартового набора {#starter-kit-customization}

Каждый стартовый набор полностью находится в вашем приложении, поэтому вы можете настроить его под себя.

### React {#react-customization}

Большая часть фронтенд‑кода для набора React находится в каталоге `resources/js`. В нём вы найдёте папки `components` (компоненты), `hooks`, `layouts`, `lib`, `pages` и `types`. Вы свободно можете изменять эти файлы, чтобы адаптировать внешний вид и поведение приложения.

Чтобы добавить дополнительные компоненты из библиотеки shadcn/ui, найдите нужный компонент на сайте и опубликуйте его с помощью `npx`:

```bash
npx shadcn@latest add switch
```

После этого компонент появится, например, в `resources/js/components/ui/switch.tsx`, и его можно импортировать в ваших файлах:

```tsx
import { Switch } from "@/components/ui/switch";
```

Набор React предлагает два основных варианта компоновки: **sidebar** (с сайдбаром) и **header** (с шапкой). По умолчанию используется вариант с сайдбаром. Чтобы переключиться на компоновку с шапкой, измените импорт в файле `resources/js/layouts/app-layout.tsx`:

```tsx
import AppLayoutTemplate from '@/layouts/app/app-header-layout';
```

Сайдбар имеет три варианта: стандартный, `inset` и `floating`. Выберите понравившийся вариант, изменяя свойство `variant` компонента `Sidebar` в `resources/js/components/app-sidebar.tsx`:

```tsx
<Sidebar collapsible="icon" variant="inset">
```

Страницы аутентификации (вход и регистрация) тоже имеют три варианта макета: `simple`, `card` и `split`. Чтобы выбрать вариант, измените импорт в файле `resources/js/layouts/auth-layout.tsx`:

```tsx
import AuthLayoutTemplate from '@/layouts/auth/auth-split-layout';
```

### Vue {#vue-customization}

Во Vue‑наборе основной код находится в каталоге `resources/js` с подпапками `components`, `composables`, `layouts`, `lib`, `pages` и `types`. Дополнительные компоненты из shadcn-vue можно публиковать аналогично:

```bash
npx shadcn-vue@latest add switch
```

Компонент будет создан в `resources/js/components/ui/Switch.vue`, после чего его можно импортировать и использовать в шаблонах:

```vue
<script setup lang="ts">
import { Switch } from '@/Components/ui/switch'
</script>

<template>
  <div>
    <Switch />
  </div>
</template>
```

Как и в наборе React, доступны две основные компоновки приложения — с сайдбаром и с шапкой. Переключить их можно, изменив импорт в `resources/js/layouts/AppLayout.vue`:

```vue
import AppLayout from '@/layouts/app/AppHeaderLayout.vue';
```

Варианты сайдбара (`sidebar`, `inset`, `floating`) и макета страниц аутентификации (`simple`, `card`, `split`) также выбираются с помощью соответствующих компонентов (`AppSidebar.vue` и `AuthLayout.vue`).

### Livewire {#livewire-customization}

Фронтенд‑часть Livewire‑набора находится в каталоге `resources/views`. В нём есть подкаталоги `components` (Livewire‑компоненты), `flux` (компоненты Flux), `livewire` (страницы), `partials` (Blade‑фрагменты), а также файлы `dashboard.blade.php` и `welcome.blade.php`. Бизнес‑логика для компонентов располагается в каталоге `app/Livewire`.

Набор Livewire также имеет два основных макета: с сайдбаром и с шапкой. Чтобы переключиться на макет с шапкой, отредактируйте файл `resources/views/components/layouts/app.blade.php`, подключив компонент `<x-layouts.app.header>` и пометив основной компонент Flux атрибутом `container`:

```blade
<x-layouts.app.header>
    <flux:main container>
        {{ $slot }}
    </flux:main>
</x-layouts.app.header>
```

Страницы аутентификации поддерживают варианты `simple`, `card` и `split`. Чтобы изменить макет аутентификации, редактируйте файл `resources/views/components/layouts/auth.blade.php` и подключайте соответствующий компонент, например `<x-layouts.auth.split>`.

## Аутентификация с помощью WorkOS AuthKit {#workos-authkit-authentication}

По умолчанию стартовые наборы используют встроенную систему аутентификации Laravel, предоставляющую функции входа, регистрации, сброса пароля и подтверждения электронной почты. Однако есть вариант с AuthKit, разработанный компанией WorkOS. Он поддерживает:

- социальную аутентификацию (Google, Microsoft, GitHub, Apple);
- аутентификацию с помощью Passkey;
- электронную почту («Magic Auth»);
- одноразовый вход (SSO).

Для использования WorkOS выберите эту опцию при создании проекта с помощью `laravel new`. После создания установите в файле `.env` переменные `WORKOS_CLIENT_ID`, `WORKOS_API_KEY` и `WORKOS_REDIRECT_URL`, полученные в панели управления WorkOS:

```
WORKOS_CLIENT_ID=your-client-id
WORKOS_API_KEY=your-api-key
WORKOS_REDIRECT_URL="${APP_URL}/authenticate"
```

Также настройте домашний URL приложения в панели WorkOS, чтобы пользователи возвращались на него после выхода. Мы рекомендуем отключить вход по email и паролю в настройках AuthKit, чтобы использовать только более безопасные методы (социальные сети, passkey, magic link, SSO). Не забудьте синхронизировать время сессии AuthKit с настройкой `session.lifetime` вашего приложения (обычно 2 часа).

## Inertia SSR {#inertia-ssr}

Стартовые наборы React и Vue совместимы с серверной отрисовкой Inertia. Чтобы собрать SSR‑совместимый бандл, выполните:

```bash
npm run build:ssr
```

Для локальной разработки доступна команда:

```bash
composer dev:ssr
```

Она собирает SSR‑совместимый бандл и запускает Laravel и Inertia SSR‑сервер, позволяя тестировать приложение с серверной отрисовкой.

## Наборы, поддерживаемые сообществом {#community-maintained-starter-kits}

При создании нового приложения через Laravel Installer вы можете указать любой сторонний набор, опубликованный на Packagist, с помощью флага `--using`:

```bash
laravel new my-app --using=vendor/package-starter-kit
```

Чтобы ваш собственный стартовый набор стал доступен другим, опубликуйте его на Packagist, добавьте необходимые переменные окружения в `.env.example` и перечислите команды, которые должны выполняться после установки, в массиве `post-create-project-cmd` файла `composer.json`.

## Часто задаваемые вопросы {#frequently-asked-questions}

**Как обновить стартовый набор?** Набор служит отправной точкой — после его создания весь код принадлежит вам. Обновлять сам стартовый набор не требуется; вы можете свободно развивать свой проект.

**Как включить подтверждение email?** Для включения проверки адреса электронной почты раскомментируйте импорт `MustVerifyEmail` в модели `App\\Models\\User.php` и убедитесь, что модель реализует интерфейс `MustVerifyEmail`.