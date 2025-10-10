# HTTP-ответы {#responses}

- [Введение](#introduction)
- [Базовые ответы](#creating-responses)
- [JSON-ответы](#json-responses)
- [Файлы и загрузки](#file-downloads)
- [Потоковые ответы](#streaming-responses)
- [Redirects](#redirects)
- [Ответы из представлений](#response-views)
- [Макросы и расширение](#response-macros)

## Введение {#introduction}

Laravel предоставляет различные способы формирования HTTP-ответов. Вы можете вернуть строки, массивы, JSON, загрузки файлов,
потоковые данные и представления.

## Базовые ответы {#creating-responses}

Верните строку или массив из маршрута или контроллера. Laravel автоматически преобразует массив в JSON.

```php
return 'Привет, мир';
return ['status' => 'ok'];
```

Используйте фасад `response()` для настройки заголовков и статуса:

```php
return response('Содержимое', 201)
    ->header('X-Custom', 'Value');
```

## JSON-ответы {#json-responses}

Метод `response()->json()` или хелпер `response()->noContent()` упрощают работу с API. Вы можете использовать `toArray()`
у моделей и коллекций.

```php
return response()->json(['user' => $user]);
```

Добавьте заголовок `->withHeaders(['X-RateLimit-Remaining' => 10])` при необходимости.

## Файлы и загрузки {#file-downloads}

Используйте `response()->download($path, $name)` или `Storage::download($path)`. Для отображения файла в браузере примените
`response()->file($path)`.

## Потоковые ответы {#streaming-responses}

```php
return response()->stream(function () {
    echo 'Часть 1';
    flush();
    echo 'Часть 2';
});
```

Для больших файлов используйте `streamDownload`, чтобы передавать содержимое по частям.

## Redirects {#redirects}

Метод `redirect()` и фасад `Redirect` упрощают перенаправления:

```php
return redirect('/home');
return redirect()->route('dashboard');
return redirect()->action([HomeController::class, 'index']);
```

Вы можете использовать `back()` и `intended()` для перенаправления на предыдущую страницу или запланированный URL.

## Ответы из представлений {#response-views}

Метод `view()` автоматически возвращает экземпляр `View` с HTTP-кодом 200. Чтобы изменить статус, используйте `response()->view('welcome', [], 202)`.

## Макросы и расширение {#response-macros}

Вы можете добавлять собственные методы к фасаду `Response` с помощью макросов в `App\Providers\AppServiceProvider`:

```php
Response::macro('caps', function (string $value) {
    return Response::make(strtoupper($value));
});
```
