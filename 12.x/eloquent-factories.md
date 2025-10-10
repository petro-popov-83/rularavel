# Красноречиво: Фабрики

- [Введение](#введение)
- [Определение фабрик моделей](#defining-model-factories)
    - [Генерирующие фабрики](#генерирующие-фабрики)
    - [Состояния фабрики](#состояния фабрики)
    - [Фабричные обратные вызовы](#factory-callbacks)
- [Создание моделей с использованием фабрик](#creating-models-using-factories)
    - [Создание экземпляров моделей](#создание экземпляров-моделей)
    - [Сохраняющиеся модели](#persisting-models)
    - [Последовательности](#последовательности)
- [Фабричные отношения](#factory-relationships)
    - [Имеет много связей](#has-many-relationships)
    - [Принадлежит связям](#принадлежит-отношениям)
    - [Отношения многие-ко-многим](#многие-ко-многим-отношениям)
    - [Полиморфные отношения](#polymorphic-relationships)
    - [Определение связей внутри фабрик](#defining-relationships-in-factories)
    - [Переработка существующей модели для отношений](#переработка-существующей-модели-для-отношений)

<a name="introduction"></a>
## Введение

При тестировании приложения или заполнении базы данных вам может потребоваться вставить в базу данных несколько записей. Вместо того, чтобы вручную указывать значение каждого столбца, Laravel позволяет вам определить набор атрибутов по умолчанию для каждой из ваших [моделей Eloquent](/docs/{{version}}/eloquent), используя фабрики моделей.

Чтобы увидеть пример написания фабрики, взгляните на файл `database/factories/UserFactory.php` в вашем приложении. Эта фабрика включена во все новые приложения Laravel и содержит следующее определение фабрики:

```php
namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\User>
 */
class UserFactory extends Factory
{
    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'email_verified_at' => now(),
            'password' => static::$password ??= Hash::make('password'),
            'remember_token' => Str::random(10),
        ];
    }

    /**
     * Indicate that the model's email address should be unverified.
     */
    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }
}
```

Как вы можете видеть, в своей самой базовой форме фабрики — это классы, которые расширяют базовый класс фабрики Laravel и определяют метод определения. Метод `definition` возвращает набор значений атрибутов по умолчанию, который следует применять при создании модели с использованием фабрики.

Через помощник `fake` фабрики имеют доступ к PHP-библиотеке [Faker](https://github.com/FakerPHP/Faker), которая позволяет удобно генерировать различные виды случайных данных для тестирования и заполнения.

> [!ПРИМЕЧАНИЕ]
> Вы можете изменить локаль Faker вашего приложения, обновив параметр faker_locale в файле конфигурации config/app.php.

<a name="defining-model-factories"></a>
## Определение фабрик моделей

<a name="генерирующие-фабрики"></a>
### Генерирующие заводы

Чтобы создать фабрику, выполните `make:factory` [команда Artisan](/docs/{{version}}/artisan):

```shell
php artisan make:factory PostFactory
```

Новый фабричный класс будет помещен в вашу директорию `database/factories`.

<a name="factory-and-model-discovery-conventions"></a>
#### Соглашения об обнаружении моделей и фабрик

После того, как вы определили свои фабрики, вы можете использовать статический метод Factory, предоставляемый вашим моделям чертой Illuminate\Database\Eloquent\Factories\HasFactory`, чтобы создать экземпляр фабрики для этой модели.

Метод Factory типажа HasFactory будет использовать соглашения для определения подходящей фабрики для модели, которой назначен этот признак. В частности, метод будет искать фабрику в пространстве имен `Database\Factories`, имя класса которой соответствует имени модели и имеет суффикс `Factory`. Если эти соглашения не применимы к вашему конкретному приложению или фабрике, вы можете перезаписать метод newFactory в вашей модели, чтобы напрямую возвращать экземпляр соответствующей фабрики модели:

```php
use Database\Factories\Administration\FlightFactory;

/**
 * Create a new factory instance for the model.
 */
protected static function newFactory()
{
    return FlightFactory::new();
}
```

Затем определите свойство model на соответствующей фабрике:

```php
use App\Administration\Flight;
use Illuminate\Database\Eloquent\Factories\Factory;

class FlightFactory extends Factory
{
    /**
     * The name of the factory's corresponding model.
     *
     * @var class-string<\Illuminate\Database\Eloquent\Model>
     */
    protected $model = Flight::class;
}
```

<a name="factory-states"></a>
### Заводские состояния

Методы манипулирования состоянием позволяют вам определять дискретные модификации, которые можно применять к вашим фабрикам моделей в любой комбинации. Например, ваша фабрика `Database\Factories\UserFactory` может содержать `приостановленный` метод состояния, который изменяет одно из значений атрибута по умолчанию.

Методы преобразования состояния обычно вызывают метод `state`, предоставляемый базовым фабричным классом Laravel. Метод `state` принимает замыкание, которое получит массив необработанных атрибутов, определенных для фабрики, и должно вернуть массив атрибутов для изменения:

```php
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * Indicate that the user is suspended.
 */
public function suspended(): Factory
{
    return $this->state(function (array $attributes) {
        return [
            'account_status' => 'suspended',
        ];
    });
}
```

<a name="trashed-state"></a>
#### «Разрушенное» государство

Если ваша модель Eloquent может быть [обратимо удалена](/docs/{{version}}/eloquent#soft-deleting), вы можете вызвать встроенный метод состояния `trashed`, чтобы указать, что созданная модель уже должна быть "обратимо удалена". Вам не нужно вручную определять состояние «trashed», поскольку оно автоматически доступно всем фабрикам:

```php
use App\Models\User;

$user = User::factory()->trashed()->create();
```

<a name="factory-callbacks"></a>
### Заводские обратные вызовы

Обратные вызовы фабрики регистрируются с помощью методов afterMaking и afterCreating и позволяют выполнять дополнительные задачи после создания модели. Вам следует зарегистрировать эти обратные вызовы, определив метод configure в вашем фабричном классе. Этот метод будет автоматически вызываться Laravel при создании экземпляра фабрики:

```php
namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class UserFactory extends Factory
{
    /**
     * Configure the model factory.
     */
    public function configure(): static
    {
        return $this->afterMaking(function (User $user) {
            // ...
        })->afterCreating(function (User $user) {
            // ...
        });
    }

    // ...
}
```

Вы также можете зарегистрировать обратные вызовы фабрики в методах состояния для выполнения дополнительных задач, специфичных для данного состояния:

```php
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * Indicate that the user is suspended.
 */
public function suspended(): Factory
{
    return $this->state(function (array $attributes) {
        return [
            'account_status' => 'suspended',
        ];
    })->afterMaking(function (User $user) {
        // ...
    })->afterCreating(function (User $user) {
        // ...
    });
}
```

<a name="создание-моделей-использование-фабрик"></a>
## Создание моделей с использованием фабрик

<a name="instantiating-models"></a>
### Создание моделей

После того, как вы определили свои фабрики, вы можете использовать статический метод Factory, предоставляемый вашим моделям чертой Illuminate\Database\Eloquent\Factories\HasFactory`, чтобы создать экземпляр фабрики для этой модели. Давайте рассмотрим несколько примеров создания моделей. Сначала мы воспользуемся методом make для создания моделей без сохранения их в базе данных:

```php
use App\Models\User;

$user = User::factory()->make();
```

Вы можете создать коллекцию из множества моделей, используя метод count:

```php
$users = User::factory()->count(3)->make();
```

<a name="applying-states"></a>
#### Применение состояний

Вы также можете применить к моделям любое из ваших [состояний](#factory-states). Если вы хотите применить к моделям несколько преобразований состояния, вы можете просто вызвать методы преобразования состояния напрямую:

```php
$users = User::factory()->count(5)->suspended()->make();
```

<a name="overriding-attributes"></a>
#### Переопределение атрибутов

Если вы хотите переопределить некоторые значения ваших моделей по умолчанию, вы можете передать массив значений методу make. Будут заменены только указанные атрибуты, а для остальных атрибутов останутся значения по умолчанию, указанные фабрикой:

```php
$user = User::factory()->make([
    'name' => 'Abigail Otwell',
]);
```

Альтернативно, метод `state` может быть вызван непосредственно в экземпляре фабрики для выполнения встроенного преобразования состояния:

```php
$user = User::factory()->state([
    'name' => 'Abigail Otwell',
])->make();
```

> [!ПРИМЕЧАНИЕ]
> [Защита от массового назначения](/docs/{{version}}/eloquent#mass-assignment) автоматически отключается при создании моделей с использованием фабрик.

<a name="persisting-models"></a>
### Сохраняющиеся модели

Метод create создает экземпляры модели и сохраняет их в базе данных с помощью метода save в Eloquent:

```php
use App\Models\User;

// Create a single App\Models\User instance...
$user = User::factory()->create();

// Create three App\Models\User instances...
$users = User::factory()->count(3)->create();
```

Вы можете переопределить атрибуты модели фабрики по умолчанию, передав массив атрибутов методу create:

```php
$user = User::factory()->create([
    'name' => 'Abigail',
]);
```

<a name="sequences"></a>
### Последовательности

Иногда вам может потребоваться изменить значение данного атрибута модели для каждой созданной модели. Этого можно добиться, определив преобразование состояния как последовательность. Например, вы можете захотеть поменять значение столбца «admin» между «Y» и «N» для каждого созданного пользователя:

```php
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Sequence;

$users = User::factory()
    ->count(10)
    ->state(new Sequence(
        ['admin' => 'Y'],
        ['admin' => 'N'],
    ))
    ->create();
```

В этом примере пять пользователей будут созданы со значением `admin`, равным `Y`, и пять пользователей будут созданы со значением `admin`, равным `N`.

При необходимости вы можете включить замыкание в качестве значения последовательности. Замыкание будет вызываться каждый раз, когда последовательности потребуется новое значение:

```php
use Illuminate\Database\Eloquent\Factories\Sequence;

$users = User::factory()
    ->count(10)
    ->state(new Sequence(
        fn (Sequence $sequence) => ['role' => UserRoles::all()->random()],
    ))
    ->create();
```

Внутри замыкания последовательности вы можете получить доступ к свойству $index экземпляра последовательности, который вводится в замыкание. Свойство $index содержит количество итераций последовательности, произошедших на данный момент:

```php
$users = User::factory()
    ->count(10)
    ->state(new Sequence(
        fn (Sequence $sequence) => ['name' => 'Name '.$sequence->index],
    ))
    ->create();
```

Для удобства последовательности также можно применять с помощью метода `sequence`, который просто вызывает внутренний метод `state`. Метод `sequence` принимает замыкание или массивы упорядоченных атрибутов:

```php
$users = User::factory()
    ->count(2)
    ->sequence(
        ['name' => 'First User'],
        ['name' => 'Second User'],
    )
    ->create();
```

<a name="factory-relationships"></a>
## Заводские отношения

<a name="имеет-много-отношений"></a>
### Имеет множество отношений

Далее давайте рассмотрим построение отношений модели Eloquent с использованием свободных фабричных методов Laravel. Во-первых, предположим, что наше приложение имеет модели App\Models\User и модели App\Models\Post. Кроме того, давайте предположим, что модель User определяет связь hasMany с Post. Мы можем создать пользователя с тремя сообщениями, используя метод has, предоставляемый фабриками Laravel. Метод has принимает экземпляр фабрики:

```php
use App\Models\Post;
use App\Models\User;

$user = User::factory()
    ->has(Post::factory()->count(3))
    ->create();
```

По соглашению, при передаче модели Post в метод has, Laravel предполагает, что модель User должен иметь метод post, определяющий взаимосвязь. При необходимости вы можете явно указать имя связи, которой хотите манипулировать:

```php
$user = User::factory()
    ->has(Post::factory()->count(3), 'posts')
    ->create();
```

Конечно, вы можете выполнять манипуляции с состоянием связанных моделей. Кроме того, вы можете передать преобразование состояния на основе замыкания, если для изменения состояния требуется доступ к родительской модели:

```php
$user = User::factory()
    ->has(
        Post::factory()
            ->count(3)
            ->state(function (array $attributes, User $user) {
                return ['user_type' => $user->type];
            })
        )
    ->create();
```

<a name="has-many-relationships-using-magic-methods"></a>
#### Использование магических методов

Для удобства вы можете использовать магические фабричные методы Laravel для построения отношений. Например, в следующем примере будет использоваться соглашение, чтобы определить, что связанные модели должны создаваться с помощью метода отношений «posts» в модели «User»:

```php
$user = User::factory()
    ->hasPosts(3)
    ->create();
```

При использовании магических методов для создания фабричных отношений вы можете передать массив атрибутов для переопределения в связанных моделях:

```php
$user = User::factory()
    ->hasPosts(3, [
        'published' => false,
    ])
    ->create();
```

Вы можете обеспечить преобразование состояния на основе замыкания, если для изменения состояния требуется доступ к родительской модели:

```php
$user = User::factory()
    ->hasPosts(3, function (array $attributes, User $user) {
        return ['user_type' => $user->type];
    })
    ->create();
```

<a name="belongs-to-relationships"></a>
### Принадлежит отношениям

Теперь, когда мы изучили, как построить отношения «имеет много» с использованием фабрик, давайте рассмотрим обратную связь. Метод for можно использовать для определения родительской модели, которой принадлежат модели, созданные на заводе. Например, мы можем создать три экземпляра модели App\Models\Post, принадлежащие одному пользователю:

```php
use App\Models\Post;
use App\Models\User;

$posts = Post::factory()
    ->count(3)
    ->for(User::factory()->state([
        'name' => 'Jessica Archer',
    ]))
    ->create();
```

Если у вас уже есть экземпляр родительской модели, который должен быть связан с создаваемыми вами моделями, вы можете передать экземпляр модели методу for:

```php
$user = User::factory()->create();

$posts = Post::factory()
    ->count(3)
    ->for($user)
    ->create();
```

<a name="принадлежит-к-отношениям-с использованием-магических-методов"></a>
#### Использование магических методов

Для удобства вы можете использовать методы магической фабрики Laravel для определения отношений «принадлежит». Например, в следующем примере будет использоваться соглашение, чтобы определить, что три сообщения должны принадлежать отношению `user` в модели `Post`:

```php
$posts = Post::factory()
    ->count(3)
    ->forUser([
        'name' => 'Jessica Archer',
    ])
    ->create();
```

<a name="отношения "многие-ко-многим"></a>
### Отношения многие ко многим

Подобно [имеет много отношений](#has-many-relationships), отношения «многие ко многим» могут быть созданы с использованием метода `has`:

```php
use App\Models\Role;
use App\Models\User;

$user = User::factory()
    ->has(Role::factory()->count(3))
    ->create();
```

<a name="pivot-table-attributes"></a>
#### Атрибуты сводной таблицы

Если вам нужно определить атрибуты, которые должны быть установлены в сводной/промежуточной таблице, связывающей модели, вы можете использовать метод hasAttached. Этот метод принимает массив имен и значений атрибутов сводной таблицы в качестве второго аргумента:

```php
use App\Models\Role;
use App\Models\User;

$user = User::factory()
    ->hasAttached(
        Role::factory()->count(3),
        ['active' => true]
    )
    ->create();
```

Вы можете предоставить преобразование состояния на основе замыкания, если для изменения состояния требуется доступ к связанной модели:

```php
$user = User::factory()
    ->hasAttached(
        Role::factory()
            ->count(3)
            ->state(function (array $attributes, User $user) {
                return ['name' => $user->name.' Role'];
            }),
        ['active' => true]
    )
    ->create();
```

Если у вас уже есть экземпляры моделей, которые вы хотели бы присоединить к создаваемым вами моделям, вы можете передать экземпляры модели в метод hasAttached. В этом примере всем трем пользователям будут назначены одни и те же три роли:

```php
$roles = Role::factory()->count(3)->create();

$users = User::factory()
    ->count(3)
    ->hasAttached($roles, ['active' => true])
    ->create();
```

<a name="многие-ко-многим-отношениям-с использованием-магических-методов"></a>
#### Использование магических методов

Для удобства вы можете использовать магические фабричные методы отношений Laravel, чтобы определить отношения многие-ко-многим. Например, в следующем примере будет использоваться соглашение, чтобы определить, что связанные модели должны создаваться с помощью метода отношений «роли» в модели «Пользователь»:

```php
$user = User::factory()
    ->hasRoles(1, [
        'name' => 'Editor'
    ])
    ->create();
```

<a name="polymorphic-relationships"></a>
### Полиморфные отношения

[Полиморфные отношения](/docs/{{version}}/eloquent-relationships#polymorphic-relationships) также можно создавать с помощью фабрик. Полиморфные отношения «преобразовать множество» создаются так же, как типичные отношения «имеет много». Например, если модель App\Models\Post имеет связь morphMany с моделью App\Models\Comment:

```php
use App\Models\Post;

$post = Post::factory()->hasComments(3)->create();
```

<a name="morph-to-relationships"></a>
#### Преобразование в отношения

Магические методы нельзя использовать для создания отношений `morphTo`. Вместо этого необходимо использовать метод for напрямую и явно указать имя связи. Например, представьте, что модель Comment имеет метод commentable, который определяет связь morphTo. В этой ситуации мы можем создать три комментария, принадлежащих одному сообщению, напрямую используя метод for:

```php
$comments = Comment::factory()->count(3)->for(
    Post::factory(), 'commentable'
)->create();
```

<a name="polymorphic-many-to-many-relationships"></a>
#### Полиморфные отношения «многие ко многим»

Полиморфные отношения «многие ко многим» (`morphToMany`/`morphedByMany`) могут быть созданы так же, как и неполиморфные отношения «многие ко многим»:

```php
use App\Models\Tag;
use App\Models\Video;

$video = Video::factory()
    ->hasAttached(
        Tag::factory()->count(3),
        ['public' => true]
    )
    ->create();
```

Конечно, волшебный метод has также можно использовать для создания полиморфных отношений «многие ко многим»:

```php
$video = Video::factory()
    ->hasTags(3, ['public' => true])
    ->create();
```

<a name="defining-relationships-within-factories"></a>
### Определение отношений внутри фабрик

Чтобы определить связь внутри фабрики моделей, вы обычно назначаете новый экземпляр фабрики внешнему ключу связи. Обычно это делается для «обратных» отношений, таких как отношения «belongsTo» и «morphTo». Например, если вы хотите создать нового пользователя при создании публикации, вы можете сделать следующее:

```php
use App\Models\User;

/**
 * Define the model's default state.
 *
 * @return array<string, mixed>
 */
public function definition(): array
{
    return [
        'user_id' => User::factory(),
        'title' => fake()->title(),
        'content' => fake()->paragraph(),
    ];
}
```

Если столбцы отношения зависят от фабрики, которая их определяет, вы можете назначить замыкание атрибуту. Замыкание получит массив оцененных атрибутов фабрики:

```php
/**
 * Define the model's default state.
 *
 * @return array<string, mixed>
 */
public function definition(): array
{
    return [
        'user_id' => User::factory(),
        'user_type' => function (array $attributes) {
            return User::find($attributes['user_id'])->type;
        },
        'title' => fake()->title(),
        'content' => fake()->paragraph(),
    ];
}
```

<a name="recycling-an-existing-model-for-relationships"></a>
### Переработка существующей модели отношений

Если у вас есть модели, которые имеют общие отношения с другой моделью, вы можете использовать метод «recycle», чтобы гарантировать, что один экземпляр связанной модели будет переработан для всех отношений, созданных фабрикой.

Например, представьте, что у вас есть модели «Авиакомпания», «Рейс» и «Билет», в которых билет принадлежит авиакомпании и рейсу, а рейс также принадлежит авиакомпании. При создании билетов вам, вероятно, понадобится одна и та же авиакомпания и для билета, и для рейса, поэтому вы можете передать экземпляр авиакомпании в метод recycle:

```php
Ticket::factory()
    ->recycle(Airline::factory()->create())
    ->create();
```

Вы можете найти метод «recycle» особенно полезным, если у вас есть модели, принадлежащие общему пользователю или команде.

Метод recycle также принимает коллекцию существующих моделей. Когда коллекция передается методу recycle, случайная модель из коллекции будет выбрана, когда фабрике понадобится модель этого типа:

```php
Ticket::factory()
    ->recycle($airlines)
    ->create();
```
