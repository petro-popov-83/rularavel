# Контекст

- [Введение](#введение)
    - [Как это работает](#как-это-работает)
- [Контекст захвата](#captureing-context)
    - [Стаки](#стаков)
- [Получение контекста](#retriving-context)
    - [Определение существования элемента](#determining-item-existence)
- [Удаление контекста](#removing-context)
- [Скрытый контекст](#hidden-context)
- [События](#события)
    - [Обезвоживание](#обезвоживание)
    - [Гидратированный](#гидратированный)

<a name="introduction"></a>
## Введение

«Контекстные» возможности Laravel позволяют вам собирать, извлекать и обмениваться информацией в запросах, заданиях и командах, выполняющихся в вашем приложении. Эта собранная информация также включается в журналы, записываемые вашим приложением, что дает вам более глубокое представление об истории выполнения окружающего кода, произошедшей до записи записи в журнале, и позволяет отслеживать потоки выполнения во всей распределенной системе.

<a name="как это работает"></a>
### Как это работает

Лучший способ понять контекстные возможности Laravel — увидеть его в действии, используя встроенные функции ведения журнала. Для начала вы можете [добавить информацию в контекст](#capturing-context), используя фасад `Context`. В этом примере мы будем использовать [промежуточное программное обеспечение](/docs/{{version}}/middleware) для добавления URL-адреса запроса и уникального идентификатора трассировки в контекст каждого входящего запроса:

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Context;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

class AddContext
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        Context::add('url', $request->url());
        Context::add('trace_id', Str::uuid()->toString());

        return $next($request);
    }
}
```

Информация, добавленная в контекст, автоматически добавляется в виде метаданных ко всем [записям журнала](/docs/{{version}}/logging), которые записываются на протяжении всего запроса. Добавление контекста в виде метаданных позволяет отличать информацию, передаваемую в отдельные записи журнала, от информации, передаваемой через «Контекст». Например, представьте, что мы пишем следующую запись в журнале:

```php
Log::info('User authenticated.', ['auth_id' => Auth::id()]);
```

Записанный журнал будет содержать `auth_id`, переданный в запись журнала, но он также будет содержать `url` и `trace_id` контекста в качестве метаданных:

```text
User authenticated. {"auth_id":27} {"url":"https://example.com/login","trace_id":"e04e1a11-e75c-4db3-b5b5-cfef4ef56697"}
```

Информация, добавленная в контекст, также становится доступной для заданий, отправленных в очередь. Например, представьте, что мы отправляем задание ProcessPodcast в очередь после добавления некоторой информации в контекст:

```php
// In our middleware...
Context::add('url', $request->url());
Context::add('trace_id', Str::uuid()->toString());

// In our controller...
ProcessPodcast::dispatch($podcast);
```

При отправке задания любая информация, хранящаяся в данный момент в контексте, фиксируется и передается заданию. Собранная информация затем возвращается в текущий контекст во время выполнения задания. Итак, если бы метод handle нашего задания заключался в записи в журнал:

```php
class ProcessPodcast implements ShouldQueue
{
    use Queueable;

    // ...

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        Log::info('Processing podcast.', [
            'podcast_id' => $this->podcast->id,
        ]);

        // ...
    }
}
```

Результирующая запись журнала будет содержать информацию, которая была добавлена ​​в контекст во время запроса, который первоначально отправил задание:

```text
Processing podcast. {"podcast_id":95} {"url":"https://example.com/login","trace_id":"e04e1a11-e75c-4db3-b5b5-cfef4ef56697"}
```

Хотя мы сосредоточились на встроенных функциях контекста Laravel, связанных с ведением журнала, следующая документация покажет, как контекст позволяет вам обмениваться информацией через границу HTTP-запроса/задания в очереди и даже как добавлять [данные скрытого контекста](#hidden-context), которые не записываются в записи журнала.

<a name="capturing-context"></a>
## Захват контекста

Вы можете хранить информацию в текущем контексте, используя метод `add` фасада `Context`:

```php
use Illuminate\Support\Facades\Context;

Context::add('key', 'value');
```

Чтобы добавить несколько элементов одновременно, вы можете передать ассоциативный массив методу add:

```php
Context::add([
    'first_key' => 'value',
    'second_key' => 'value',
]);
```

Метод add переопределит любое существующее значение, имеющее тот же ключ. Если вы хотите добавить информацию в контекст только в том случае, если ключ еще не существует, вы можете использовать метод addIf:

```php
Context::add('key', 'first');

Context::get('key');
// "first"

Context::addIf('key', 'second');

Context::get('key');
// "first"
```

Контекст также предоставляет удобные методы для увеличения или уменьшения данного ключа. Оба эти метода принимают по крайней мере один аргумент: ключ для отслеживания. Второй аргумент может быть предоставлен для указания величины, на которую следует увеличить или уменьшить ключ:

```php
Context::increment('records_added');
Context::increment('records_added', 5);

Context::decrement('records_added');
Context::decrement('records_added', 5);
```

<a name="conditional-context"></a>
#### Условный контекст

Метод «когда» можно использовать для добавления данных в контекст на основе заданного условия. Первое замыкание, предоставленное методу When, будет вызвано, если данное условие оценивается как true, а второе замыкание будет вызвано, если условие оценивается как false:

```php
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Context;

Context::when(
    Auth::user()->isAdmin(),
    fn ($context) => $context->add('permissions', Auth::user()->permissions),
    fn ($context) => $context->add('permissions', []),
);
```

<a name="scoped-context"></a>
#### Ограниченный контекст

Метод `scope` предоставляет возможность временно изменить контекст во время выполнения данного обратного вызова и восстановить контекст в исходное состояние, когда обратный вызов завершает выполнение. Кроме того, вы можете передать дополнительные данные, которые должны быть объединены в контекст (в качестве второго и третьего аргументов) во время выполнения замыкания.

```php
use Illuminate\Support\Facades\Context;
use Illuminate\Support\Facades\Log;

Context::add('trace_id', 'abc-999');
Context::addHidden('user_id', 123);

Context::scope(
    function () {
        Context::add('action', 'adding_friend');

        $userId = Context::getHidden('user_id');

        Log::debug("Adding user [{$userId}] to friends list.");
        // Adding user [987] to friends list.  {"trace_id":"abc-999","user_name":"taylor_otwell","action":"adding_friend"}
    },
    data: ['user_name' => 'taylor_otwell'],
    hidden: ['user_id' => 987],
);

Context::all();
// [
//     'trace_id' => 'abc-999',
// ]

Context::allHidden();
// [
//     'user_id' => 123,
// ]
```

> [!ПРЕДУПРЕЖДЕНИЕ]
> Если объект в контексте изменяется внутри замыкания области действия, эта мутация будет отражена за пределами области действия.

<a name="stacks"></a>
### Стеки

Контекст предлагает возможность создавать «стеки», которые представляют собой списки данных, хранящихся в том порядке, в котором они были добавлены. Вы можете добавить информацию в стек, вызвав метод push:

```php
use Illuminate\Support\Facades\Context;

Context::push('breadcrumbs', 'first_value');

Context::push('breadcrumbs', 'second_value', 'third_value');

Context::get('breadcrumbs');
// [
//     'first_value',
//     'second_value',
//     'third_value',
// ]
```

Стеки могут быть полезны для сбора исторической информации о запросе, например событий, происходящих в вашем приложении. Например, вы можете создать прослушиватель событий, который будет помещать в стек каждый раз при выполнении запроса, фиксируя SQL-запрос и его продолжительность в виде кортежа:

```php
use Illuminate\Support\Facades\Context;
use Illuminate\Support\Facades\DB;

// In AppServiceProvider.php...
DB::listen(function ($event) {
    Context::push('queries', [$event->time, $event->sql]);
});
```

Вы можете определить, находится ли значение в стеке, используя методы stackContains и hiddenStackContains:

```php
if (Context::stackContains('breadcrumbs', 'first_value')) {
    //
}

if (Context::hiddenStackContains('secrets', 'first_value')) {
    //
}
```

Методы stackContains и hiddenStackContains также принимают замыкание в качестве второго аргумента, что позволяет лучше контролировать операцию сравнения значений:

```php
use Illuminate\Support\Facades\Context;
use Illuminate\Support\Str;

return Context::stackContains('breadcrumbs', function ($value) {
    return Str::startsWith($value, 'query_');
});
```

<a name="retreaving-context"></a>
## Получение контекста

Вы можете получить информацию из контекста, используя метод get фасада `Context`:

```php
use Illuminate\Support\Facades\Context;

$value = Context::get('key');
```

Методы «only» и «Exception» могут использоваться для получения подмножества информации в контексте:

```php
$data = Context::only(['first_key', 'second_key']);

$data = Context::except(['first_key']);
```

Метод pull можно использовать для извлечения информации из контекста и немедленного удаления ее из контекста:

```php
$value = Context::pull('key');
```

Если контекстные данные хранятся в [стеке](#stacks), вы можете извлекать элементы из стека, используя метод pop:

```php
Context::push('breadcrumbs', 'first_value', 'second_value');

Context::pop('breadcrumbs');
// second_value

Context::get('breadcrumbs');
// ['first_value']
```

Методы `remember` и `rememberHidden` могут использоваться для извлечения информации из контекста, при этом для значения контекста устанавливается значение, возвращаемое данным замыканием, если запрошенная информация не существует:

```php
$permissions = Context::remember(
    'user-permissions',
    fn () => $user->permissions,
);
```

Если вы хотите получить всю информацию, хранящуюся в контексте, вы можете вызвать метод all:

```php
$data = Context::all();
```

<a name="определение-существования-элемента"></a>
### Определение существования элемента

Вы можете использовать методы has и Missing, чтобы определить, имеет ли контекст какое-либо значение, сохраненное для данного ключа:

```php
use Illuminate\Support\Facades\Context;

if (Context::has('key')) {
    // ...
}

if (Context::missing('key')) {
    // ...
}
```

Метод has вернет true независимо от сохраненного значения. Так, например, ключ со значением `null` будет считаться присутствующим:

```php
Context::add('key', null);

Context::has('key');
// true
```

<a name="removing-context"></a>
## Удаление контекста

Метод «забыть» можно использовать для удаления ключа и его значения из текущего контекста:

```php
use Illuminate\Support\Facades\Context;

Context::add(['first_key' => 1, 'second_key' => 2]);

Context::forget('first_key');

Context::all();

// ['second_key' => 2]
```

Вы можете забыть несколько ключей одновременно, предоставив массив методу «забыть»:

```php
Context::forget(['first_key', 'second_key']);
```

<a name="hidden-context"></a>
## Скрытый контекст

Контекст предлагает возможность хранить «скрытые» данные. Эта скрытая информация не добавляется в журналы и недоступна с помощью методов получения данных, описанных выше. Контекст предоставляет другой набор методов для взаимодействия со скрытой контекстной информацией:

```php
use Illuminate\Support\Facades\Context;

Context::addHidden('key', 'value');

Context::getHidden('key');
// 'value'

Context::get('key');
// null
```

«Скрытые» методы отражают функциональность нескрытых методов, описанных выше:

```php
Context::addHidden(/* ... */);
Context::addHiddenIf(/* ... */);
Context::pushHidden(/* ... */);
Context::getHidden(/* ... */);
Context::pullHidden(/* ... */);
Context::popHidden(/* ... */);
Context::onlyHidden(/* ... */);
Context::exceptHidden(/* ... */);
Context::allHidden(/* ... */);
Context::hasHidden(/* ... */);
Context::missingHidden(/* ... */);
Context::forgetHidden(/* ... */);
```

<a name="events"></a>
## События

Контекст отправляет два события, которые позволяют вам подключиться к процессу гидратации и обезвоживания контекста.

Чтобы проиллюстрировать, как можно использовать эти события, представьте, что в промежуточном программном обеспечении вашего приложения вы устанавливаете значение конфигурации app.locale на основе заголовка Accept-Language входящего HTTP-запроса. События контекста позволяют вам захватить это значение во время запроса и восстановить его в очереди, гарантируя, что отправляемые в очередь уведомления имеют правильное значение app.locale. Для достижения этой цели мы можем использовать события контекста и данные [hidden](#hidden-context), что будет показано в следующей документации.

<a name="обезвоживание"></a>
### обезвоживание

Всякий раз, когда задание отправляется в очередь, данные в контексте «обезвоживаются» и фиксируются вместе с полезной нагрузкой задания. Метод «Context::deгидратing» позволяет вам зарегистрировать замыкание, которое будет вызываться во время процесса обезвоживания. В рамках этого закрытия вы можете вносить изменения в данные, которые будут доступны для задания в очереди.

Обычно вам следует зарегистрировать «обезвоживающие» обратные вызовы в методе boot класса AppServiceProvider вашего приложения:

```php
use Illuminate\Log\Context\Repository;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Context;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Context::dehydrating(function (Repository $context) {
        $context->addHidden('locale', Config::get('app.locale'));
    });
}
```

> [!ПРИМЕЧАНИЕ]
> Вам не следует использовать фасад «Контекст» в обратном вызове «обезвоживание», так как это изменит контекст текущего процесса. Убедитесь, что вы вносите изменения только в репозиторий, переданный в обратный вызов.

<a name="гидратированный"></a>
### Гидратированный

Всякий раз, когда поставленное в очередь задание начинает выполняться в очереди, любой контекст, который был общим с заданием, будет «гидратирован» обратно в текущий контекст. Метод Context::гидрат позволяет вам зарегистрировать замыкание, которое будет вызываться во время процесса гидратации.

Обычно вам следует регистрировать «гидратированные» обратные вызовы в методе boot класса AppServiceProvider вашего приложения:

```php
use Illuminate\Log\Context\Repository;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Context;

/**
 * Bootstrap any application services.
 */
public function boot(): void
{
    Context::hydrated(function (Repository $context) {
        if ($context->hasHidden('locale')) {
            Config::set('app.locale', $context->getHidden('locale'));
        }
    });
}
```

> [!ПРИМЕЧАНИЕ]
> Вам не следует использовать фасад «Контекст» в обратном вызове «гидратированный» и вместо этого убедитесь, что вы вносите изменения только в репозиторий, переданный в обратный вызов.
