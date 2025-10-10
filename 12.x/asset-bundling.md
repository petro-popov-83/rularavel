# Сборка ресурсов {#asset-bundling}

- [Введение](#introduction)
- [Vite по умолчанию](#vite)
  - [Установка зависимостей](#installing-dependencies)
  - [Запуск dev-сервера](#running-dev-server)
  - [Компиляция для продакшена](#building-for-production)
  - [Горячая перезагрузка](#hot-module-replacement)
- [Использование ресурсов в Blade](#using-vite-in-blade)
- [Встраивание статических ассетов](#static-assets)
- [TypeScript и JSX](#typescript-and-jsx)
- [CSS и PostCSS](#css-and-postcss)
- [Sass / Less / Stylus](#sass-less-stylus)
- [Env и конфигурация Vite](#vite-configuration)
- [Серверные рендеры Inertia / Vue / React](#inertia-ssr)
- [Альтернативные сборщики](#alternative-bundlers)

## Введение {#introduction}

Начиная с Laravel 9, Vite — стандартный инструмент для компиляции JavaScript и CSS. Он обеспечивает мгновенный запуск dev-сервера,
модульную горячую перезагрузку и оптимизированные сборки. Laravel предоставляет удобные хелперы для интеграции Vite с Blade,
Inertia и Livewire.

## Vite по умолчанию {#vite}

### Установка зависимостей {#installing-dependencies}

После установки нового приложения выполните:

```bash
npm install
```

или используйте Bun / Yarn. Пакет `laravel-vite-plugin` поставляется из коробки и конфигурирует импорт ресурсов.

### Запуск dev-сервера {#running-dev-server}

```bash
npm run dev
```

Команда запускает Vite в режиме разработки. Laravel автоматически определяет активный сервер и вставляет необходимые теги в
представления при использовании директивы `@vite`.

### Компиляция для продакшена {#building-for-production}

```bash
npm run build
```

Создаёт минифицированные файлы в `public/build` и манифест `manifest.json`. Laravel использует манифест для генерации ссылок на
хешированные ресурсы.

### Горячая перезагрузка {#hot-module-replacement}

В режиме разработки Vite подключает веб-сокет, который автоматически обновляет страницу при изменении файлов. Нет необходимости
перезапускать сервер.

## Использование ресурсов в Blade {#using-vite-in-blade}

Подключайте входные точки с помощью директивы:

```blade
@vite(['resources/css/app.css', 'resources/js/app.js'])
```

Если вы используете Inertia, директива `@viteReactRefresh` или `@vite` автоматически добавляется шаблонами `app.blade.php`
поставляемых стартовых наборов.

Метод `Vite::useBuildDirectory('static')` позволяет изменить директорию вывода. Для тестирования вы можете принудительно включить
компилированные ассеты, вызвав `Vite::useHotFile(false)`.

## Встраивание статических ассетов {#static-assets}

Используйте хелпер `Vite::asset('resources/images/logo.svg')`, чтобы получить хешированный URL. Для импортов внутри JavaScript
можно использовать синтаксис `new URL('./logo.png', import.meta.url)`.

## TypeScript и JSX {#typescript-and-jsx}

Vite автоматически компилирует TypeScript, JSX и TSX. Переименуйте файлы на `.ts` или `.tsx` и импортируйте их из `app.js`. Для
улучшения DX установите типы `@types/node` и настройте `tsconfig.json`.

## CSS и PostCSS {#css-and-postcss}

Laravel поставляется с PostCSS. Файл `postcss.config.js` по умолчанию включает `autoprefixer` и может быть расширен Tailwind CSS
или другими плагинами. Импортируйте CSS непосредственно в `app.js` или используйте файл `app.css`.

## Sass / Less / Stylus {#sass-less-stylus}

Установите соответствующий препроцессор:

```bash
npm install --save-dev sass
```

Затем импортируйте `.scss` в `resources/js/app.js` или укажите его как отдельную точку входа в `vite.config.js`.

## Env и конфигурация Vite {#vite-configuration}

Файл `vite.config.js` уже содержит плагин `laravel`. Вы можете расширить конфигурацию — например, определить алиасы:

```js
export default defineConfig({
    plugins: [laravel({ input: ['resources/js/app.js'], refresh: true })],
    resolve: { alias: { '@': '/resources/js' } },
});
```

Переменные окружения `.env` с префиксом `VITE_` доступны в клиентском коде как `import.meta.env.VITE_SOME_KEY`.

## Серверные рендеры Inertia / Vue / React {#inertia-ssr}

Если вы используете SSR, настройте `laravel-vite-plugin` с опцией `ssr: 'resources/js/ssr.js'` и запустите `npm run build &&
npm run build:ssr`. Laravel автоматически определит серверный бандл при рендере.

## Альтернативные сборщики {#alternative-bundlers}

Вы можете использовать другие сборщики (Mix, Webpack, Rollup, esbuild). Однако Vite остаётся рекомендованным инструментом.
Если вы переключаетесь на другой стек, убедитесь, что корректно генерируете хешированные ассеты и обновляете Blade-директивы
для вставки ресурсов.
