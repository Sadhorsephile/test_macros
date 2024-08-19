# Ещё одна статья про макросы

Про макросы в Dart написано уже немало статей, но в этой статье будет минимум теории и максимум практики и рассуждений. Мы вместе пройдём путём разработчика, который только начал изучать макросы и будем:
- придумывать разные способы упростить себе жизнь с помощью макросов;
- формировать гипотезы (описывать то, что хотим получить);
- писать код и проверять гипотезы;
- радоваться результатам или разбираться, что пошло не так.

## Знакомство с макросами

Макросы - это проявление метапрограммирования в языке Dart. Подробнее о них можно прочитать в одной из статей:
- [Макросы на Dart: первые ощущения от использования и лайфхаки на будущее](https://habr.com/ru/articles/829560/);
- [Пишем собственный макрос на Dart 3.5 вместо старого генератора кода](https://habr.com/ru/articles/821911/).

Здесь же мы слегка "пробежимся" по основным моментам, которые нам понадобятся в дальнейшем.

### Действующие лица

#### Макрос

- Непосредственно то, что пишет разработчик;
- С точки зрения Dart является классом;
- Должен иметь константный конструктор (как и любой класс, который может быть использован в качестве аннотации);
- Имеет доступ к информации о цели;
- Генерирует код на основании этой информации.

#### Цель

- То, к чему применяется макрос;
- Может быть классом, методом, полем, top-level переменной, top-level функцией, библиотекой, конструктором, миксином,  расширением, перечислением, полем перечисления, type alias'ом;
- Может быть целью нескольких макросов сразу.

#### Сгенерированный код

- Появляется в режиме редактирования кода по мере изменения кода макроса/цели;
- readonly;
- форматирование кода - прерогатива разработчика, поэтому обычно на него без слёз не взглянешь.

### Устройство макроса

Как уже было сказано, макрос это класс. Помимо этого:
- этот класс должен иметь ключевое слово `macro` в объявлении;
- реализовывать один (или несколько) из интерфейсов макросов. Каждый из интерфейсов определяет, к какой цели и в какой фазе макрос будет применён.

### Фазы макросов

#### Фаза определения типов

- Выполняется первой;
- Только в этой фазе доступно объявление новых типов (классов, typedef, перечислений и т.д.);
- Практически не имеет доступа к уже имеющимся типам;
- По сути, на этом её полномочия всё.

#### Фаза объявления

- Выполняется после фазы типов;
- В этой фазе можно объявлять новые поля, методы (но не классы и прочие типы);
- Имеет доступ к уже объявленным типам - но только если они указаны явно;
- Самая, на мой взгляд, полезная и свободная фаза - можно писать практически любой код - как в класс, так и в файл.

#### Фаза определения

- Выполняется последней;
- В этой фазе можно дополнять (`augment`) уже объявленные поля, методы, конструкторы;
- Можно узнать типы полей, методов и т.д., даже если они не указаны явно.

### Как выбрать интерфейс макроса?

- Выбираем цель;
- Определяем, что мы хотим сделать с этой целью (то есть, выбираем фазу);
- Путём несложной комбинации получаем название интерфейса (за исключением части `Macro` в конце);
- <img src="https://sun9-2.userapi.com/impg/xyDQ2aX3qeLmzhm-Budn80Ks8B37S7ePxBpWjQ/h0QP3whetqY.jpg?size=1462x814&quality=96&sign=cf0ece8e8247e6537a8787392792a736&type=album" height="300">;
- список доступных интерфейсов можно найти в репозитории с пакетом `macros` (пока что он находится [тут](https://github.com/dart-lang/sdk/blob/main/pkg/_macros/lib/src/api/macros.dart)).

<details><summary>Табличка интерфейсов</summary>

| Цель/Фаза | Фаза определения типов | Фаза объявления | Фаза определения |
| --- | --- | --- | --- |
| Библиотека | `LibraryTypesMacro` | `LibraryDeclarationsMacro` | `LibraryDefinitionMacro` |
| Класс | `ClassTypesMacro` | `ClassDeclarationsMacro` | `ClassDefinitionMacro` |
| Метод | `MethodTypesMacro` | `MethodDeclarationsMacro` | `MethodDefinitionMacro` |
| Функция | `FunctionTypesMacro` | `FunctionDeclarationsMacro` | `FunctionDefinitionMacro` |
| Поле | `FieldTypesMacro` | `FieldDeclarationsMacro` | `FieldDefinitionMacro` |
| Переменная | `VariableTypesMacro` | `VariableDeclarationsMacro` | `VariableDefinitionMacro` |
| Перечисление | `EnumTypesMacro` | `EnumDeclarationsMacro` | `EnumDefinitionMacro` |
| Значение перечисления | `EnumValueTypesMacro` | `EnumValueDeclarationsMacro` | `EnumValueDefinitionMacro` |
| Миксин | `MixinTypesMacro` | `MixinDeclarationsMacro` | `MixinDefinitionMacro` |
| Расширение | `ExtensionTypesMacro` | `ExtensionDeclarationsMacro` | `ExtensionDefinitionMacro` |
| Расширение типа | `ExtensionTypeTypesMacro` | `ExtensionTypeDeclarationsMacro` | `ExtensionTypeDefinitionMacro` |
| Конструктор | `ConstructorTypesMacro` | `ConstructorDeclarationsMacro` | `ConstructorDefinitionMacro` |
| Type Alias | `TypeAliasTypesMacro` | `TypeAliasDeclarationsMacro` | - |
</details>

</br>

> [!NOTE]
>
> Вы можете выбрать несколько интерфейсов для одного макроса - таким образом, вы сможете применить макрос к разным целям в разные фазы. 
>
> При применении макроса к цели будет выполнен только тот код, который относится к цели. Например, если макрос реализует интерфейсы `FieldDefinitionMacro` и `ClassDeclarationsMacro` и применён к классу, то будет выполнен только код фазы объявления по отношению к классу. 

## Рубрика "Эксперименты"

Да начнётся практика! Но сперва определим то, как она будет проходить.

Каждый пункт этого раздела будет основываться на ответах на следующие вопросы:
- Зачем? (обоснование полезности);
- Как это должно выглядеть? (ожидаемый результат в виде кода);
- Как это реализовать? (реализация);
- Работает ли это? Если нет, то почему? (разбор особенностей/ограничений).

### Авто-конструктор

#### Зачем?

Будем честны - даже с помощью IDE создание конструктора класса с большим количеством полей - это не самый лучший способ тратить время. Да и довольно утомительно бывает дополнять уже существующий конструктор новыми полями. Кроме того, конструктор для класса с большим количеством полей может занимать много строк кода, что не всегда положительно сказывается на читаемости.

#### Как это должно выглядеть?

> [!NOTE]
> Для простоты предлагаю опустить кейсы с `super`-конструкторами и с приватными именованными полями - нам и так будет, чем заняться.

Поля класса могут инициализироваться:
- позиционными параметрами конструктора;
- именованными параметрами конструктора;
- константными значениями по умолчанию;
- как обязательные;
- как необязательные;
- не в конструкторе вовсе.

Надо предусмотреть все эти случаи. Для этого мы можем использовать аннотирование полей класса:

```dart
@AutoConstructor()
class SomeComplicatedClass {
  final int a;

  @NamedParam()
  final String b;

  @NamedParam(defaultValue: 3.14)
  final double c;

  @NamedParam(isRequired: false)
  final bool? d;

  @NamedParam(isRequired: true)
  final bool? e;

  final List<int> f;
}
```

```dart
augment class SomeComplicatedClass {
  SomeComplicatedClass(this.a, this.f, {required this.b, this.c = 3.14, this.d, required this.e});
}
```

#### Как это реализовать?

Начнём с самого простого - в отдельном файле создадим класс `NamedParam` для аннотирования полей класса:

```dart
class NamedParam {
  final bool isRequired;
  final Object? defaultValue;
  const NamedParam({this.defaultValue, this.isRequired = true});
}
```

Теперь создадим макрос, который будет делать всю работу за нас. Заодно порассуждаем, какая фаза макроса нам подходит:
- Мы не собираемся определять новые типы, поэтому фаза типов нам точно не подходит;
- Фаза объявления позволяет нам писать код внутри класса, а также оперировать полями класса, что нам и нужно;
- Фаза определения позволяет дополнять конструктор класса, но не даёт возможность писать конструктор с нуля (то есть, конструктор уже должен присутсвовать в классе) - не наш вариант.

Таким образом, мы выбираем фазу объявления. Создадим макрос `AutoConstructor`, получим список полей и начнём складывать код конструктора и параметры:

```dart
import 'dart:async';

import 'package:macros/macros.dart';

macro class AutoConstructor implements ClassDeclarationsMacro {
  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final fields = await builder.fieldsOf(clazz);

    /// Сюда мы будем собирать код.
    /// Начнём с объявления конструктора.
    /// Например:
    /// ClassName(
    ///
    final code = <Object>[
      '\t${clazz.identifier.name}(\n',
    ];

    /// Список всех позиционных параметров.
    final positionalParams = <Object>[];

    /// Список всех именнованных параметров.
    final namedParams = <Object>[];
  }
}
```

Следующая задача, которую нам нужно решить - это научиться определять, есть ли у поля аннотация `NamedParam` и если есть - какие у неё параметры. Для этого мы просто пройдёмся по всем аннотациям поля и найдём нужную нам:

```dart
    for (final field in fields) {
      /// Список всех аннотаций поля.
      final annotationsOfField = field.metadata;
      /// Достаём аннотацию NamedParam (если она есть).
      final namedParam = annotationsOfField.firstWhereOrNull(
        (element) => element is ConstructorMetadataAnnotation && element.type.identifier.name == 'NamedParam',
      ) as ConstructorMetadataAnnotation?;
    }
```

> [!NOTE]
> Небольшое пояснение к коду выше - аннотации в Dart могут быть двух типов:
> - константное значение (например, `@immutable` или `@override`);
> - вызов конструктора (например, `@Deprecated('Use another method')`).
> 
> Так как `NamedParam` относится ко второму типу, мы ищем аннотацию, которая является вызовом конструктора и имеет имя `NamedParam`. Иначе нам бы потребовался не `ConstructorMetadataAnnotation`, а `IdentifierMetadataAnnotation`.

У аннотации есть два именованных параметра - `defaultValue` и `isRequired`. Давайте их достанем:

```dart
      if (namedParam != null) {
        final defaultValue = namedParam.namedArguments['defaultValue'];
        
        final isRequired = namedParam.namedArguments['isRequired'];
      ...
      }
```
И вот тут начинаются проблемы - мы не можем узнать значение `isRequired` (то есть, сделать что-то вроде `if (isRequired) {`), так как API макросов не даёт прямой доступ к значению поля, а предоставляет только объект типа `ExpressionCode`, который представляет собой код выражения (который будет подставлен в конечный код уже на этапе его формирования). 

> [!NOTE]
>
> **Что такое код?**
> 
> В рамках макросов мы можем строить код из трёх типов объектов:
> - `String` - обычная строка. Эта строка просто добавляется в код как есть;
> - `Identifier` - ссылка на именованное объявление (название переменной или поля, его/её типа и т.д.);
> - `Code` - сущность, которая представляет собой набор Dart-кода. В свою очередь, состоит из частей, которые также могут быть одним из этих трёх типов. Имеет множество подклассов для различных конструкций языка (например, `DeclarationCode`, `TypeAnnotationCode`, `ExpressionCode` и многие другие). Подклассы в свою очередь использует сериализатор для корректной генерации различных конструкций.
> 
> В случае с `Identifier` и `Code` **мы не можем получить значение, которое попадёт в итоговый код** - это своего рода метаданные о коде, а не сам код.



Но мы не сдадимся так просто - давайте создадим отдельную аннотацию для обязательных полей - `requiredField`. Эта аннотация может быть не классом, а констатным значением:

```dart
  const requiredField = Required();

  class Required {
    const Required();
  }
```

Отредактируем наш исходный класс:

```dart
@AutoConstructor()
class SomeComplicatedClass {
  final int a;

  @requiredField
  @NamedParam()
  final String b;

  @NamedParam(defaultValue: 3.14)
  final double c;

  @NamedParam()
  final bool? d;

  @requiredField
  @NamedParam()
  final bool? e;

  final List<int> f;
}
```

Теперь найдём эту аннотацию у поля:

```dart
      if (namedParam != null) {
        final defaultValue = namedParam.namedArguments['defaultValue'];
        
        final isRequired = annotationsOfField.any(
          (element) => element is IdentifierMetadataAnnotation && element.identifier.name == 'requiredField',
        );
      ...
      }
```

Теперь сформируем код с инициализацией именованных параметров.

Что должно получиться:
```dart
    required this.b,
    this.c = 3.14,
    this.d,
    this.e,
```

Как мы это сделаем:
```dart
        namedParams.addAll(
          
          [
            '\t\t',
            if (isRequired && defaultValue == null) ...[
              'required ',
            ],
            'this.${field.identifier.name}',
            if (defaultValue != null) ...[
              ' = ',
              defaultValue,
            ],
            ',\n',
          ],
        );
```

Теперь займёмся позиционными параметрами - тут всё проще, нам нужно просто добавить их в список:

```dart
       if (namedParam != null) {
        ...
      } else {
        positionalParams.add('\t\tthis.${field.identifier.name},\n');
      }
```

Соберём все воедино и добавим код в класс:

```dart
  {
    ...
    code.addAll([
      ...positionalParams,
      if (namedParams.isNotEmpty)
      ...['\t\t{\n',
      ...namedParams,
      '\t\t}',],
      '\n\t);',
    ]);

    builder.declareInType(DeclarationCode.fromParts(code));
  }
```

#### Результат

Применим макрос к классу `SomeComplicatedClass`:

```dart
@AutoConstructor()
class SomeComplicatedClass {
  final int a;

  @requiredField
  @NamedParam()
  final String b;

  @NamedParam(defaultValue: 3.14)
  final double c;

  @NamedParam()
  final bool? d;

  @requiredField
  @NamedParam()
  final bool? e;

  final List<int> f;
}
```

И получим следующий результат:

```dart
augment library 'package:test_macros/1.%20auto_constructor/example.dart';

augment class SomeComplicatedClass {
	SomeComplicatedClass(
		this.a,
		this.f,
		{
		required this.b,
		this.c = 3.14,
		this.d,
		this.e,
		}
	);
}
```

Приведу полный код макроса:

```dart

macro class AutoConstructor implements ClassDeclarationsMacro {
  const AutoConstructor();

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final fields = await builder.fieldsOf(clazz);

    /// Сюда мы будем собирать код.
    final code = <Object>[
      '\t${clazz.identifier.name}(\n',
    ];

    /// Список всех позиционных параметров.
    final positionalParams = <Object>[];

    /// Список всех именнованных параметров.
    final namedParams = <Object>[];

    for (final field in fields) {
      /// Список всех аннотаций поля.
      final annotationsOfField = field.metadata;

      /// Достаём аннотацию NamedParam (если она есть).
      final namedParam = annotationsOfField.firstWhereOrNull(
        (element) => element is ConstructorMetadataAnnotation && element.type.identifier.name == 'NamedParam',
      ) as ConstructorMetadataAnnotation?;

      if (namedParam != null) {
        final defaultValue = namedParam.namedArguments['defaultValue'];

        final isRequired = annotationsOfField.any(
          (element) => element is IdentifierMetadataAnnotation && element.identifier.name == 'requiredField',
        );

        namedParams.addAll(
          [
            '\t\t',
            if (isRequired && defaultValue == null) ...[
              'required ',
            ],
            'this.${field.identifier.name}',
            if (defaultValue != null) ...[
              ' = ',
              defaultValue,
            ],
            ',\n',
          ],
        );
      } else {
        positionalParams.add('\t\tthis.${field.identifier.name},\n');
      }
    }

    code.addAll([
      ...positionalParams,
      if (namedParams.isNotEmpty)
      ...['\t\t{\n',
      ...namedParams,
      '\t\t}',],
      '\n\t);',
    ]);

    builder.declareInType(DeclarationCode.fromParts(code));
  }
}
```

Мы почти достигли результата, которого хотели, но при этом столкнулись с ограничением API макросов - мы не можем оперировать значениями `ExpressionCode`. В некоторых случаях (в таких, как наших) мы можем обойти это ограничение окольными путями, но иногда это может быть стать препятствием. 

Кроме того, есть ещё пара моментов, которые немного портят нам малину:
- в `NamedParam` можно передать значение по умолчанию любого типа (то есть, отличного от поля, которому присваевается значение). Однако это не является большой проблемой, так как анализатор предупредит нас о неправильном типе;
- в самом макросе мы используем строковое название классов аннотаций и их параметров, что может привести к ошибкам, если эти названия изменятся. Это проблема макросов в целом, но это решается путём хранения аннотаций и макроса в одной библиотеке.

Но есть проблема **посерьёзнее** - проект с этим макросом не запускается, выдавая ошибку отсутствия конструктора у класса. При этом ошибок анализатора нет - сгенерированный код выглядит корректно. Немного поигравшись с исходным классом, я обнаружил, что он работает в таком виде:
  
  ```dart
@AutoConstructor()
class SomeComplicatedClass {
  final int a;

  final String b;

  final double c;

  final bool? d;

  final bool? e;

  final List<int> f;
}
```

Вероятно, вы уже заметили, что я полностью убрал аннотации. Судя по всему, на момент запуска проекта аннотации не обрабатываются и класс не имеет конструктора, что приводит к ошибке. F. ~~Флешка с доказательствами уже в Гааге~~ [Issue на GitHub](https://github.com/dart-lang/sdk/issues/56410) уже создана, но пока что мы не можем ничего сделать.

Делаем важный вывод - анализатору мы доверять больше (или пока что) не можем.


### Публичные Listenable-геттеры

#### Зачем?

Актуально для тех, кому надоело из раза в раз писать что-то такое:
```dart
    final _counter = ValueNotifier<int>(0);
    ValueListenable<int> get counter => _counter;
```

или

```dart
    final counterNotifier = ValueNotifier<int>(0);
    ValueListenable<int> get counter => counterNotifier;
```

#### Как это должно выглядеть?

```dart
    @ListenableGetter()
    final _counter = ValueNotifier<int>(0);

    @ListenableGetter(name: 'secondCounter')
    final _counterNotifier = ValueNotifier<int>(0);
```

<img src="https://sun6-20.userapi.com/impg/mPCW9aLJF_0Ezj8Pl2M8XB5OJF-AGPc6j0COag/EwkHsoHJz6g.jpg?size=1200x798&quality=96&sign=e0d138e6d5be3e09b1618a23cba7e409&type=album" height="300">

#### Как это реализовать?

Для начала выберем фазу макроса:
- мы не планируем создавать новый тип, поэтому фаза типов нам не подходит;
- фаза объявления позволяет нам добавлять код внутри класса - то, что нам нужно;
- фаза определения позволяет лишь дополнять уже имеющиеся объявления, а не создавать новые. 

Создадим макрос `ListenableGetter`. В качестве интерфейса макроса берём `FieldDeclarationsMacro`, так как целью макроса будет именно поле класса:

```dart
import 'dart:async';

import 'package:macros/macros.dart';

macro class ListenableGetter implements FieldDeclarationsMacro {
  final String? name;
  const ListenableGetter({this.name});

  @override
  FutureOr<void> buildDeclarationsForField(FieldDeclaration field, MemberDeclarationBuilder builder) async {
    ///
  }
}
``` 

Для начала добавим проверку, что поле имеет вид `ValueNotifier`:
```dart
 @override
  FutureOr<void> buildDeclarationsForField(FieldDeclaration field, MemberDeclarationBuilder builder) async {
    final fieldType = field.type;
    if (fieldType is! NamedTypeAnnotation) {
      builder.report(
        Diagnostic(
          DiagnosticMessage('Field doesn\'t have type'),
          Severity.error,
        ),
      );
      return;
    }

    if (fieldType.identifier.name != 'ValueNotifier') {
      builder.report(
        Diagnostic(
          DiagnosticMessage('Field type is not ValueNotifier'),
          Severity.error,
        ),
      );
      return;
    }
  }
```

Применяем макрос к классу и получаем ошибку - 'Field doesn't have type'. Это происходит из-за того, что тип поля не указан явно. При этом в фазе объявления мы не можем получить доступ к типу поля напрямую, если оно не указано явно. И тут нам на помощь приходит фаза определения, у которой таких ограничений уже нет.

Таким образом, наш новый план таков:
- определяем геттер для поля в фазе объявления как `external` - его реализацию мы добавим в фазе определения;
- в фазе определения добавляем реализацию геттера.

В итоге получаем:
```dart
import 'dart:async';

import 'package:macros/macros.dart';

macro class ListenableGetter implements FieldDefinitionMacro, FieldDeclarationsMacro {
  final String? name;
  const ListenableGetter({this.name});

  String _resolveName(FieldDeclaration field) => name ?? field.identifier.name.replaceFirst('_', '');

  @override
  FutureOr<void> buildDeclarationsForField(FieldDeclaration field, MemberDeclarationBuilder builder) async {
    builder.declareInType(DeclarationCode.fromParts([
      '\texternal get ',
      _resolveName(field),
      ';',
    ]));
  }

  @override
  FutureOr<void> buildDefinitionForField(FieldDeclaration field, VariableDefinitionBuilder builder) async {
    var fieldType =
        field.type is OmittedTypeAnnotation ? await builder.inferType(field.type as OmittedTypeAnnotation) : field.type;
    if (fieldType is! NamedTypeAnnotation) {
      builder.report(
        Diagnostic(
          DiagnosticMessage('Field doesn\'t have type'),
          Severity.error,
        ),
      );
      return;
    }

    if (fieldType.identifier.name != 'ValueNotifier') {
      builder.report(
        Diagnostic(
          DiagnosticMessage('Field type is not ValueNotifier'),
          Severity.error,
        ),
      );
      return;
    }

    final type = await builder.resolveIdentifier(
        Uri.parse('package:flutter/src/foundation/change_notifier.dart'), 'ValueListenable');

    builder.augment(
      getter: DeclarationCode.fromParts([
        type,
        '<',
        fieldType.typeArguments.first.code,
        '> get ',
        _resolveName(field),
        ' => ',
        field.identifier.name,
        ';',
      ]),
    );
  }
}
```
#### Результат

Применим макрос к классу `WidgetModel`:
```dart
class WidgetModel {
  @ListenableGetter()
  final _counter = ValueNotifier<int>(0);
  @ListenableGetter(name: 'secondCounter')
  final _secondCounter = ValueNotifier(0);
}

void foo() {
  final a = WidgetModel();
  a.counter; // ValueListenable<int>
  a.secondCounter; // ValueListenable<int>
}
```

И получим следующий результат:
```dart
augment library 'package:test_macros/2.%20listenable_getter/example.dart';

import 'package:flutter/src/foundation/change_notifier.dart' as prefix0;
import 'dart:core' as prefix1;

augment class WidgetModel {
  external get counter;
  external get secondCounter;
  augment prefix0.ValueListenable<prefix1.int> get counter => _counter;
  augment prefix0.ValueListenable<prefix1.int> get secondCounter => _secondCounter;
}
```

Эксперимент удался - мы получили то, что хотели. При этом нам пришлось использовать две фазы макросов, но благодаря этому нам не нужно явно указывать тип поля.


### Авто-dispose

#### Зачем?

Гораздо удобнее "повесить" аннотацию на поле, которое нужно "выключить" при удалении объекта, чем делать это вручную, спускаясь в метод `dispose`.

#### Как это должно выглядеть?

Определим сущности, к которым мы хотим применить макрос - это сущности, имеющие:
- метод `dispose`;
- метод `close` (например, `StreamController`);
- метод `cancel` (например, `StreamSubscription`).
- альтернативный метод "выключения".

Что будет, если мы применим макрос к полю, которое не имеет метода `dispose`/`close`/`cancel`? По-хорошему мы должны добавить проверку на наличие метода `dispose` у поля, но даже если нам это не удастся - это не страшно, так как анализатор Dart всё равно предупредит нас о том, что метода `dispose` у поля нет.

```dart
@AutoDispose()
class SomeModel {
  @disposable
  final ValueNotifier<int> a;
  @closable
  final StreamController<int> b;
  @cancelable
  final StreamSubscription<int> c;
  @Disposable('customDispose')
  final CustomDep d;

  SomeModel({required this.a, required this.b, required this.c, required this.d});
}

class CustomDep {
  void customDispose() {}
}
```

```dart
augment library 'package:test_macros/3.%20auto_dispose/example.dart';

augment class SomeModel {
	void dispose() {
		a.dispose();
		b.close();
		c.cancel();
		d.customDispose();
	}
}
```

#### Как это реализовать?

Сперва самое простое - создадим аннотации `disposable`, `cancelable`, `closable` и `Disposable`:

```dart
const disposeMethod = 'dispose';
const closeMethod = 'close';
const cancelMethod = 'cancel';

const disposableAnnotationName = 'disposable';
const closableAnnotationName = 'closable';
const cancelableAnnotationName = 'cancelable';
const customDisposableAnnotationName = 'Disposable';
const customDisposableFieldName = 'disposeMethodName';


const disposable = Disposable(disposeMethod);
const closable = Disposable(closeMethod);
const cancelable = Disposable(cancelMethod);

class Disposable {
  final String disposeMethodName;
  const Disposable(this.disposeMethodName);
}
```

Пришло время создавать макрос. Как и в предыдущих случаях, выберем фазу макроса:
- фаза типов нам не подходит, так как мы не собираемся создавать новые типы;
- фаза объявления позволяет нам добавлять код внутри класса - мы именно это и хотим;
- фаза определения словно бы нам не нужна, так как всё необходимое мы можем сделать в фазе объявления.

```dart
import 'dart:async';

import 'package:macros/macros.dart';

macro class AutoDispose implements ClassDeclarationsMacro {
  const AutoDispose();

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final fields = await builder.fieldsOf(clazz);
  }
}
```

Соберём словарь, где ключом будет имя поля, а значением - имя метода, который надо вызвать:

```dart
    final fields = await builder.fieldsOf(clazz);

    /// Ключ - имя поля, значение - имя метода для вызова.
    final disposables = <String, Object>{};

    for (final field in fields) {
      Object? methodName;

      final annotations = field.metadata;

      /// Ищем аннотацию Disposable с кастомным именем метода.
      final customDispose = annotations.whereType<ConstructorMetadataAnnotation>().firstWhereOrNull(
            (element) => element.type.identifier.name == customDisposableAnnotationName,
          );

      if (customDispose != null) {
        methodName = customDispose.namedArguments[customDisposableFieldName];
      } else {
        /// Если аннотация не найдена, ищем стандартные аннотации.
        /// 
        /// - отсеиваем константные аннотации;
        /// - ищем аннотации, которые содержат нужные нам идентификаторы.
        /// - сопоставляем идентификаторы с методами.
        methodName = switch ((annotations.whereType<IdentifierMetadataAnnotation>().firstWhereOrNull(
              (element) => [
                disposableAnnotationName,
                closableAnnotationName,
                cancelableAnnotationName,
              ].contains(element.identifier.name),
            ))?.identifier.name) {
          disposableAnnotationName => disposeMethod,
          closableAnnotationName => closeMethod,
          cancelableAnnotationName => cancelMethod,
          _ => null,
        };
      }

      if (methodName != null) {
        disposables[field.identifier.name] = methodName;
      }
    }
```

Дело за малым - собираем код метода `dispose` и добавляем его в класс:

```dart
    final code = <Object>[
      '\tvoid dispose() {\n',
      ...disposables.entries.map((e) {
        return ['\t\t${e.key}.', e.value, '();\n'];
      }).expand((e) => e),
      '\t}\n',
    ];

    builder.declareInType(DeclarationCode.fromParts(code));
```

Казалось бы, победа - но вот мы заходим посмотреть сгенерированный код и видим такую картину:
```dart
augment library 'package:test_macros/3.%20auto_dispose/example.dart';

augment class SomeModel {
	void dispose() {
		a.dispose();
		b.close();
		c.cancel();
		d.'customDispose'();
	}
}
```

Снова мы получили нож в спину от `ExpressionCode` - мы можем получить только код выражения, но не его значение. А так как код выражения содержит значение строки (с кавычками), то мы не можем его использовать в качестве имени метода. 

Попробуем поискать обходные пути. Мы могли бы попробовать дать возможность пользователям реализовывать собственные аннотации - однако макрос должен откуда-то знать названия новых аннотаций, чтобы он принимал их во внимание во время генерации метода `dispose`. Кроме того, он также должен знать названия методов, которые нужно вызвать.

Таким образом, единственный вариант, пришедший мне в голову (простите меня за это, если сможете) - передавать в макрос словарь, где ключ это название аннотации, а значение - название метода:

```dart
@AutoDispose(
  disposeMethodNames: {
    'customDepDispose': 'customDispose',
  },
)
class SomeModel {
  @disposable
  final ValueNotifier<int> a;
  @closable
  final StreamController<int> b;
  @cancelable
  final StreamSubscription<int> c;
  @customDepDispose
  final CustomDep d;

  SomeModel({required this.a, required this.b, required this.c, required this.d});
}

const customDepDispose = Disposable('customDispose');

class CustomDep {
  void customDispose() {}
}
```

Это выглядит ужасно, но ничего лучше я придумать не смог. 

Внесём изменения в макрос - сперва соберём словарь всех возможных аннотаций и методов:

```dart
macro class AutoDispose implements ClassDeclarationsMacro {
  final Map<String, String> disposeMethodNames;
  const AutoDispose({
    this.disposeMethodNames = const {},
  });

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final allMethodNames = {
      disposableAnnotationName: disposeMethod,
      closableAnnotationName: closeMethod,
      cancelableAnnotationName: cancelMethod,
      ...disposeMethodNames,
    };
    ...
  }
}
```

Поиск кастомного метода нам больше не нужен, как и switch - теперь это будет поиск по ключу в словаре:
```dart
    for (final field in fields) {
      Object? methodName;

      final annotations = field.metadata;

      final annotationName = ((annotations.whereType<IdentifierMetadataAnnotation>().firstWhereOrNull(
            (element) => allMethodNames.keys.contains(element.identifier.name),
          ))?.identifier.name);

      methodName = allMethodNames[annotationName];

      if (methodName != null) {
        disposables[field.identifier.name] = methodName;
      }
    }
```

Остальной код остаётся без изменений. Проверяем сгенерированный код и, наконец-то, видим заветное:
```dart
augment library 'package:test_macros/3.%20auto_dispose/example.dart';

augment class SomeModel {
	void dispose() {
		a.dispose();
		b.close();
		c.cancel();
		d.customDispose();
	}
}
```
Пробуем запустить проект и в очередной раз получаем нож в спину:
```sh
Error: This macro application didn't apply correctly due to an unhandled map entry.
```

Несмотря на то, что наш входной параметр [отвечает](https://github.com/dart-lang/language/blob/main/working/macros/feature-specification.md#macro-arguments) требованиям спецификации (является словарём с примитивными типами данных), [макрос не может его обработать](https://github.com/dart-lang/sdk/issues/56458). Можно передавать параметры в виде строки (например, 'customDepDispose: customDispose'), но это неудобно и нечитаемо.

Помимо этого, у нашего примера есть ещё одна проблема - он не поддерживает вызов метода базового (не `augment`) класса. Согласно [официальным примерам](https://github.com/dart-lang/language/blob/5527a8f2825f1b9fa69d7efce9ba6102bfa7aa14/working/macros/example/lib/auto_dispose.dart#L69), можно вызывать метод `augmented()` внутри `augment` метода, однако на практике я получил ошибку, что такого метода не существует. 

#### Результат

Мы получили макрос, который будет работать с предустановленными сущностями, но для работы с кастомными требуется дополнительная настройка, которая из-за текущих ограничений макросов может быть огранизована только через костыли. При этом мы немного вернули веру в пользу аннотаций после их провала в первом эксперименте. 

### DI контейнер

#### Зачем?

Зачастую типичный DI-контейнер в условиях Flutter-приложения выглядит как-то так:
```dart
class AppScope implements IAppScope {
  late final SomeDep _someDep;
  late final AnotherDep _anotherDep;
  late final ThirdDep _thirdDep;

  ISomeDep get someDep => _someDep;
  IAnotherDep get anotherDep => _anotherDep;
  IThirdDep get thirdDep => _thirdDep;

  AppScope(String someId) {
    _someDep = SomeDep(someId);
  }

  Future<void> init() async {
    _anotherDep = await AnotherDep.create();
    _thirdDep = ThirdDep(_someDep);
  }
}

abstract interface class IAppScope {
  ISomeDep get someDep;
  IAnotherDep get anotherDep;
  IThirdDep get thirdDep;
}
```

Было бы весьма привлекательно вместо этого иметь контейнер, который:
 - позволяет указывать зависимости прямо в инициализаторе;
 - поддерживает асинхронную инициализацию;
 - имеет защиту от циклических зависимостей;
 - выглядит при этом лаконично.

#### Как это должно выглядеть?

Как-то так:
```dart
@DiContainer()
class AppScope {
  late final Registry<SomeDependency> _someDependency = Registry(() {
    return SomeDependency();
  });
  late final Registry<AnotherDependency> _anotherDependency = Registry(() {
    return AnotherDependency(someDependency);
  });
  late final Registry<ThirdDependency> _thirdDependency = Registry(() {
    return ThirdDependency(someDependency, anotherDependency);
  });
}
```

```dart
augment class AppScope {
  late final ISomeDependency someDependency;
  late final IAnotherDependency anotherDependency;
  late final IThirdDependency thirdDependency;

  Future<void> init() async {
    someDependency = await _someDependency();
    anotherDependency = await _anotherDependency();
    thirdDependency = await _thirdDependency();
  }
}
```

#### Как это реализовать?

Разобьём задачу на подзадачи:
- выбор фазы и создание аннотации;
- создание класса `Registry`;
- создание метода `init`;
- построение порядка инициализации;
- создание `late final` полей.

##### Выбор фазы и создание аннотации

Выберем фазу объявления, так как нам нужно добавить код внутри класса. Создадим аннотацию `DiContainer`:

```dart
macro class DiContainer implements ClassDeclarationsMacro {
  const DiContainer();
  @override
  FutureOr<void> buildDeclarationsForClass(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
  ) async {}
}
```

##### Создание класса `Registry`

Создадим класс `Registry`:
```dart
class Registry<T> {
  final FutureOr<T> Function() create;

  Registry(this.create);

  FutureOr<T> call() => create();
}
```

##### Создание метода `init`

Тут всё просто - используем старый-добрый `builder.declareInType`:
```dart
@override
  FutureOr<void> buildDeclarationsForClass(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
  ) async {
    final initMethodParts = <Object>[
      'Future<void> init() async {\n',
    ];

    initMethodParts.add('}');

    builder.declareInType(DeclarationCode.fromParts(initMethodParts));
  }
```

##### Построение порядка инициализации

А вот здесь начинается самое интересное и сложное. Нам нужно определить порядок инициализации полей. Для этого нам нужно:
- собрать список зависимостей для каждого поля;
- определить порядок инициализации таким образом, чтобы зависимости инициализировались раньше зависимых от них полей.

В первую очередь соберём словарь, где ключом будет название поля с зависимостью, а значением - список параметров, которые требуются для её инициализации. Условно говоря, для нашего примера словарь будет таким:
```dart
{
  someDependency: [],
  anotherDependency: [someDependency],
  thirdDependency: [someDependency, anotherDependency],
}
```

Сделаем это таким образом:
```dart

    final dependencyToConstructorParams = <String, List<String>>{};

    for (final field in fields) {
      final type = field.type;
      if (type is! NamedTypeAnnotation) continue;
      /// Отсекаем все поля, которые не являются Registry.
      if (type.identifier.name != 'Registry') continue;

      final generic = type.typeArguments.firstOrNull;

      if (generic is! NamedTypeAnnotation) continue;

      final typeDeclaration = await builder.typeDeclarationOf(generic.identifier);

      if (typeDeclaration is! ClassDeclaration) continue;

      final fields = await builder.fieldsOf(typeDeclaration);

      final constructorParams = fields.where((e) => !e.hasInitializer).toList();

      dependencyToConstructorParams[field.identifier.name.replaceFirst('_', '')] = constructorParams.map((e) => e.identifier.name.replaceFirst('_', '')).toList();
    }
```

Теперь нам нужно определить порядок инициализации. Для этого мы будем использовать топологическую сортировку. Граф у нас уже есть, осталось реализовать сам алгоритм:

```dart
  List<T> _topologicalSort<T>(
    Map<T, List<T>> graph,
    MemberDeclarationBuilder builder,
  ) {
    /// Обработанные вершины.
    final visited = <T>{};

    /// Вершины, в которых мы находимся на текущий момент.
    final current = <T>{};

    /// Вершины, записанные в топологическом порядке.
    final result = <T>[];

    /// Рекурсивная функция обхода графа.
    /// Возвращает [T], который образует цикл. Если цикла нет, возращает null.
    T? process(T node) {
      /// Если вершина уже обрабатывается, значит, мы нашли цикл.
      if (current.contains(node)) {
        return node;
      }

      /// Если вершина уже обработана, то пропускаем её.
      if (visited.contains(node)) {
        return null;
      }

      /// Добавляем вершину в текущие.
      current.add(node);

      /// Повторяем для всех соседей.
      for (final neighbor in graph[node] ?? []) {
        final result = process(neighbor);
        if (result != null) {
          return result;
        }
      }

      current.remove(node);
      visited.add(node);
      result.add(node);
      return null;
    }

    for (final node in graph.keys) {
      final cycleAffectingNode = process(node);

      /// Если обнаружен цикл, то выбрасываем исключение.
      if (cycleAffectingNode != null) {
        builder.report(
          Diagnostic(
            DiagnosticMessage(
             '''Cycle detected in the graph. '''
             '''$cycleAffectingNode requires ${graph[cycleAffectingNode]?.join(', ')}''',
            ),
            Severity.error,
          ),
        );
        throw Exception();
      }
    }
    return result;
  }
```

Теперь, когда у нас есть порядок вызовов, можем дособрать функцию `init`:

```dart
  @override
  FutureOr<void> buildDeclarationsForClass(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
  ) async {
    ...
    final sorted = _topologicalSort(
      dependencyToConstructorParams,
      builder,
    );

    for (final dep in sorted) {
      if (!dependencyToConstructorParams.keys.contains(dep)) continue;
        /// Получаем что-то вроде:
        /// ```
        /// someDependency = await _someDependency();
        /// ```
        initMethodParts.addAll([
          '\t\t$dep = await _$dep();\n',
        ]);
    }

    initMethodParts.add('}');

    builder.declareInType(DeclarationCode.fromParts(initMethodParts));
  }
```

##### Создание late final полей

Наконец, создаём late final поля. К сожалению, `Registry` использует джинерик конкретного типа, из-за чего нам недоступен напрямую интерфейс класса, за которым мы хотим скрыть реализацию. Поэтому мы берём первый из доступных интерфейсов (если он вообще есть):
```diff
  for (final field in fields) {
      ...
      dependencyToConstructorParams[field.identifier.name.replaceFirst('_', '')] =
          constructorParams.map((e) => e.identifier.name.replaceFirst('_', '')).toList();

++    final superClass = typeDeclaration.interfaces.firstOrNull;
++
++    builder.declareInType(
++      DeclarationCode.fromParts(
++        [
++          'late final ',
++          superClass?.code ?? generic.code,
++          ' ${field.identifier.name.replaceFirst('_', '')};',
++        ],
++      ),
++    );
++  }
```

#### Результат

Применим макрос к классу `AppScope`:
```dart
@DiContainer()
class AppScope {
  late final Registry<SomeDependency> _someDependency = Registry(() {
    return SomeDependency();
  });
  late final Registry<AnotherDependency> _anotherDependency = Registry(() {
    return AnotherDependency(someDependency);
  });
  late final Registry<ThirdDependency> _thirdDependency = Registry(() {
    return ThirdDependency(someDependency, anotherDependency);
  });


  AppScope();
}
```

и получим:
```dart
augment library 'package:test_macros/5.%20di_container/example.dart';

import 'package:test_macros/5.%20di_container/example.dart' as prefix0;

import 'dart:core';
import 'dart:async';
augment class AppScope {
late final prefix0.ISomeDependency someDependency;
late final prefix0.IAnotherDependency anotherDependency;
late final prefix0.IThirdDependency thirdDependency;
Future<void> init() async {
		someDependency = await _someDependency();
		anotherDependency = await _anotherDependency();
		thirdDependency = await _thirdDependency();
	}
}
```

Попробуем добавить `IAnotherDependency` как параметр для зависмости `SomeDependency`:
```dart
@DiContainer()
class AppScope {
  late final Registry<SomeDependency> _someDependency = Registry(() {
    return SomeDependency(anotherDependency);
  });
  ...
}
```

И получим ошибку: 

<img src="https://sun9-29.userapi.com/impg/uzzQRx2veEHJ_1pI8iEx8GrQ87RKbEWS5y4fdA/6Oxhr-WpOCk.jpg?size=1316x122&quality=96&sign=fc248f86e5e03275cce2406da4dc993a&type=album" width="500"/>

#### Результат

Эта реализация имеет очень много "тонких" мест - например, мы завязаны на том, что пользователь должен задавать инициализаторы строго приватными. Также мы не можем задавать имена публичных полей (даже с использованием аннотаций, так как переданные в них параметры будут доступны нам только как `ExpressionCode`). Также мы не можем в явном виде указывать интерфейс, под которым хотели бы видеть публичное поле (в теории, можно добавить второй джинерик к `Registry`, однако это лишает нас лаконичности). Однако, несмотря на это, мы получили работающий прототип DI-контейнера, который можно доработать и улучшить. 

### Retrofit на макросах

#### Зачем?

Классическая версия retrofit для Dart работает с помощью build_runner. Звучит как потенциальная цель для переноса на макросы.

#### Как это должно выглядеть?

```dart
@RestClient()
class Client {
  Client(
    this.dio, {
    this.baseUrl,
  });

  @GET('/posts/{id}')
  external Future<UserInfoDto> getUserInfo(int id);

  @GET('/convert')
  external Future<SomeEntity> convert(@Query() String from, @Query() String to);
}
```

```dart
augment class Client {
  final Dio dio;
  final String? baseUrl;

  augment Future<PostEntity> getUserInfo(int id) async {
		final queryParameters = <String, dynamic>{};
		final _result  = await dio.fetch<Map<String, dynamic>>(Options(
		  method: 'GET',
		)
		.compose(
			dio.options,
			"/posts/${id}",
			queryParameters: queryParameters,
		)
    .copyWith(baseUrl: baseUrl ?? dio.options.baseUrl));
		final value = PostEntity.fromJson(_result.data!);
		return value;
	}

  augment Future<PostEntity> convert(String from, String to) async {
		final queryParameters = <String, dynamic>{
			'from': from,
			'to': to,
		};
		final _result  = await dio.fetch<Map<String, dynamic>>(Options(
		  method: 'GET',
		)
		.compose(
			dio.options,
			"/convert",
			queryParameters: queryParameters,
		)
    .copyWith(baseUrl: baseUrl ?? dio.options.baseUrl));
		final value = PostEntity.fromJson(_result.data!);
		return value;
	}
}
```

Пока что мы ограничимся только GET-запросами, query- и path-параметрами.

#### Как это реализовать?

По классике - начнём с создания аннотаций:

```dart
const query = Query();

class Query {
  const Query();
}
```

На сей раз у нас будет два макроса:
- `RestClient` для класса;
- `GET` для методов.

Наиболее подходящая фаза макроса для клиента - фаза объявления: нам нужно добавить два поля в класс.

Создадим макрос, а также запишем название полей класса в константы:

```dart
import 'dart:async';

import 'package:macros/macros.dart';

const baseUrlVarSignature = 'baseUrl';
const dioVarSignature = 'dio';

macro class RestClient implements ClassDeclarationsMacro {
  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    /// Добавим импорт Dio.
    builder.declareInLibrary(DeclarationCode.fromString('import \'package:dio/dio.dart\';'));
  }
}
```

Получим список полей, убедимся, что поля, которые мы собираемся создать, отсутствуют и если так - то создадим их:

```dart
    final fields = await builder.fieldsOf(clazz);

    builder.declareInLibrary(DeclarationCode.fromString('import \'package:dio/dio.dart\';'));

    /// Проверяем, имеет ли класс поле baseUrl.
    final indexOfBaseUrl = fields.indexWhere((element) => element.identifier.name == baseUrlVarSignature);
    if (indexOfBaseUrl == -1) {
      final stringType = await builder.resolveIdentifier(Uri.parse('dart:core'), 'String');
      builder.declareInType(DeclarationCode.fromParts(['\tfinal ', stringType, '? $baseUrlVarSignature;']));
    } else {
      builder.report(
        Diagnostic(
          DiagnosticMessage('$baseUrlVarSignature is already defined.'),
          Severity.error,
        ),
      );
      return;
    }

    final indexOfDio = fields.indexWhere((element) => element.identifier.name == dioVarSignature);
    if (indexOfDio == -1) {
      builder.declareInType(DeclarationCode.fromString('\tfinal Dio $dioVarSignature;'));
    } else {
      builder.report(
        Diagnostic(
          DiagnosticMessage('$dioVarSignature is already defined.'),
          Severity.error,
        ),
      );
      return;
    }
```

Теперь займёмся методом. Для макроса `GET` мы выберем фазу определения, так как нам нужно написать реализацию уже объявленного метода. Однако стоит также добавить фазу объявления, чтобы мы могли добавить импорты - их наличие упростит нам жизнь и избавит от необходимости импортировать кучу типов вручную.

```dart
macro class GET implements MethodDeclarationsMacro, MethodDefinitionMacro {
  final String path;

  const GET(this.path);


  @override
  FutureOr<void> buildDeclarationsForMethod(MethodDeclaration method, MemberDeclarationBuilder builder) async {
    builder.declareInLibrary(DeclarationCode.fromString('import \'dart:core\';'));
  }

  @override
  FutureOr<void> buildDefinitionForMethod(MethodDeclaration method, FunctionDefinitionBuilder builder) async {
    
  }
}
```

Перед нами стоит несколько задач:
- определить возвращаемый тип значения для того, чтобы реализовать парсинг;
- собрать query-параметры;
- подставить параметры в path, если они есть;
- собрать это всё воедино.

Нам нужно определить возвращаемый тип. Предполагается, что мы применим к нему метод `fromJson`, чтобы спарсить ответ сервера. Однако стоит также учесть кейсы, когда мы пытаемся получить коллекцию (`List`) или не получаем никакого значения (`void`).
Заведём enum для типов возвращаемых значений:
```dart
/// Общий тип, который возвращает метод:
/// - коллекция
/// - одно значение
/// - ничего
enum ReturnType { collection, single, none }
```

Теперь можно определять возвращаемый тип (то есть, достать джинерик из `Future` либо `Future<List>`):

```dart
  @override
  FutureOr<void> buildDefinitionForMethod(MethodDeclaration method, FunctionDefinitionBuilder builder) async {
  /// Здесь у нас будет что-то вроде `Future<UserInfoDto>`.
    var type = method.returnType;

    /// Сюда запишем тип возвращаемого значения.
    NamedTypeAnnotation? valueType;
    late ReturnType returnType;

    /// На случай, если тип возвращаемого значения опущен при объявлении метода, попробуем его получить.
    if (type is OmittedTypeAnnotation) {
      type = await builder.inferType(type);
    }

    if (type is NamedTypeAnnotation) {
      /// Проверяем, что тип возвращаемого значения - Future.
      if (type.identifier.name != 'Future') {
        builder.report(
          Diagnostic(
            DiagnosticMessage('The return type of the method must be a Future.'),
            Severity.error,
          ),
        );
        return;
      }

      /// Получаем джинерик типа. У Future он всегда один.
      final argType = type.typeArguments.firstOrNull;

      valueType = argType is NamedTypeAnnotation ? argType : null;

      switch (valueType?.identifier.name) {
        case 'List':
          returnType = ReturnType.collection;
          valueType = valueType?.typeArguments.firstOrNull as NamedTypeAnnotation?;
        case 'void':
          returnType = ReturnType.none;
        default:
          returnType = ReturnType.single;
      }
    } else {
      builder.report(
        Diagnostic(
          DiagnosticMessage('Cannot determine the return type of the method.'),
          Severity.error,
        ),
      );
      return;
    }

    if (valueType == null) {
      builder.report(
        Diagnostic(
          DiagnosticMessage('Cannot determine the return type of the method.'),
          Severity.error,
        ),
      );
      return;
    }
  }
```

Теперь соберём query-параметры в словарь вида:
```dart
final _queryParameters = <String, dynamic>{  
  'from': from,
  'to': to,
};
```

Для этого соберём все поля (именованные и позиционные) и возьмём те из них, у которых есть аннотация `@query`:

```dart
    /// Сюда будем собирать код для создания query параметров.
    final queryParamsCreationCode = <Object>[];

    final fields = [
      ...method.positionalParameters,
      ...method.namedParameters,
    ];

    /// Собираем query параметры.
    final queryParams = fields.where((e) => e.metadata.any((e) => e is IdentifierMetadataAnnotation && e.identifier.name == 'query')).toList();
```

Добавим также к числу наших констант название переменной для query-параметров:
```diff

    const baseUrlVarSignature = 'baseUrl';
    const dioVarSignature = 'dio';
++  const queryVarSignature = '_queryParameters';
```

Теперь, если у нас есть query-параметры, добавим их в словарь:
```dart
    queryParamsCreationCode.addAll([
      '\t\tfinal $queryVarSignature = <String, dynamic>{\n',
      ...queryParams.map((e) => "\t\t\t'${e.name}': ${e.name},\n"),
      '\t\t};\n',
    ]);
```

Займёмся путём запроса - подставим в него path-параметры.

Например, если у нас путь `/posts/{id}`, то мы должны получить строку `'/posts/$id'`. 

```dart
    final substitutedPath = path.replaceAllMapped(RegExp(r'{(\w+)}'), (match) {
      final paramName = match.group(1);
      final param = fields.firstWhere((element) => element.identifier.name == paramName, orElse: () => throw ArgumentError('Parameter \'$paramName\' not found'));
      return '\${${param.identifier.name}}';
    });
```

Пришло время собрать запрос в кучу. При этом не стоит забывать, что мы можем получить не только одиночное значение, но и коллекцию или ничего - это важно учесть при использовании метода `fetch`, а также при парсинге ответа:
```dart
    builder.augment(FunctionBodyCode.fromParts([
      'async {\n',
      ...queryParamsCreationCode,
      '\t\tfinal _result  = await $dioVarSignature.fetch<',
      switch (returnType) {
        ReturnType.none => 'void',
        ReturnType.single => 'Map<String, dynamic>',
        ReturnType.collection => 'List<dynamic>',  
      },'>(\n',
      '\t\t\tOptions(\n',
		  '\t\t\t\tmethod: "GET",\n',
		  '\t\t\t)\n',
		  '\t\t.compose(\n',
		  '\t\t\t	$dioVarSignature.options,\n',
		  '\t\t\t	"$substitutedPath",\n',
		  '\t\t\t	queryParameters: $queryVarSignature,\n',
		  '\t\t)\n',
      '\t\t.copyWith(baseUrl: $baseUrlVarSignature ?? $dioVarSignature.options.baseUrl));\n',
		  ...switch (returnType) {
        ReturnType.none => [''],
        ReturnType.single => ['\t\tfinal value = ', valueType.code, '.fromJson(_result.data!);\n'],
        ReturnType.collection => [
          '\t\tfinal value = (_result.data as List).map((e) => ', valueType.code, '.fromJson(e)).toList();\n',
          ],
      },
      if (returnType != ReturnType.none) '\t\treturn value;\n',
      '\t}',
    ]));
```

Для проверки результата предлагаю воспользоваться https://jsonplaceholder.typicode.com/ - бесплатным API для тестирования HTTP-запросов.

```dart
// ignore_for_file: avoid_print

@DisableDuplicateImportCheck()
library example;

import 'package:test_macros/5.%20retrofit/annotations.dart';
import 'package:test_macros/5.%20retrofit/client_macro.dart';
import 'package:dio/dio.dart';

@RestClient()
class Client {
  Client(this.dio, {this.baseUrl});

  @GET('/posts/{id}')
  external Future<PostEntity> getPostById(int id);

  @GET('/posts')
  external Future<List<PostEntity>> getPostsByUserId(@query int user_id);
}

class PostEntity {
  final int? userId;
  final int? id;
  final String? title;
  final String? body;

  PostEntity({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  factory PostEntity.fromJson(Map<String, dynamic> json) {
    return PostEntity(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'body': body,
    };
  }
}

Future<void> main() async {
  final dio = Dio()..interceptors.add(LogInterceptor(logPrint: print));
  final client = Client(dio, baseUrl: 'https://jsonplaceholder.typicode.com');

  const idOfExistingPost = 1;

  final post = await client.getPostById(idOfExistingPost);
  
  final userId = post.userId;

  if (userId != null) {
    final posts = await client.getPostsByUserId(userId);
    print(posts);
  }
}
```

Запускаем и видим следующее:
```
  Error: 'String' isn't a type.
  Error: 'int' isn't a type.
  Error: 'dynamic' isn't a type.
  ...
```

Это ещё одна обнаруженная в ходе написания статьи [проблема макросов](https://github.com/dart-lang/sdk/issues/56478) - из-за того, что в одном файле есть одинаковые импорты - с префиксом и без - проект не может запуститься:
```dart
import "dart:core";
import "dart:core" as prefix01;
```

Так что нам придётся всего-лишь переписать почти весь код макроса, чтобы использовать только типы с префиксами. Получать эти типы мы будем с помощью метода `resolveIdentifier`, который принимает uri библиотеки и название типа, а также отмечен как `deprecated` ещё до релиза:

```dart
  @override
  FutureOr<void> buildDefinitionForMethod(MethodDeclaration method, FunctionDefinitionBuilder builder) async {
    const stringTypeName = 'String';
    const dynamicTypeName = 'dynamic';
    const mapTypeName = 'Map';
    const optionsTypeName = 'Options';
    const listTypeName = 'List';

    final stringType = await builder.resolveIdentifier(Uri.parse('dart:core'), stringTypeName);
    final dynamicType = await builder.resolveIdentifier(Uri.parse('dart:core'), dynamicTypeName);
    final mapType = await builder.resolveIdentifier(Uri.parse('dart:core'), mapTypeName);
    final optionsType = await builder.resolveIdentifier(Uri.parse('package:dio/src/options.dart'), optionsTypeName);
    final listType = await builder.resolveIdentifier(Uri.parse('dart:core'), listTypeName);

    /// Шорткат для `<String, dynamic>`.
    final stringDynamicMapType = ['<', stringType, ', ', dynamicType, '>'];
    ...
  }
```

Теперь нам следует заменить все вхождения `String`, `dynamic`, `Map`, `Options` и `List` на полученные нами "разрешённые" типы:
```diff
    queryParamsCreationCode.addAll([
--    '\t\tfinal $queryVarSignature = <String, dynamic>{\n',
++    '\t\tfinal $queryVarSignature = ', ...stringDynamicMapType, '{\n',
      ...queryParams.map((e) => "\t\t\t'${e.name}': ${e.name},\n"),
      '\t\t};\n',
    ]);
```

И в таком духе во всех остальных местах ('_dio.fetch<Map<String, dynamic>>', 'Options' и т.д.).

Теперь можно полюбоваться на результат.

#### Результат

Применим макрос к классу `Client`:

```dart
@RestClient()
class Client {
  Client(this.dio, {this.baseUrl});

  // @GET('/posts/{id}')
  external Future<UserInfoDto> getUserInfo(int id);

  @GET('/convert')
  external Future<SomeEntity> convert(@query String from, @query String to);
}
```

и получим следующий сгенерированный код:

```dart
augment library 'package:test_macros/4.%20retrofit/example.dart';

import 'dart:async' as prefix0;
import 'package:test_macros/4.%20retrofit/example.dart' as prefix1;
import 'dart:core' as prefix2;

import 'dart:core';
import 'dart:core';
import 'package:dio/dio.dart';
// ignore_for_file: duplicate_import
augment class Client {
	final String? baseUrl;
	final Dio dio;
  augment prefix0.Future<prefix1.UserInfoDto> getUserInfo(prefix2.int id, ) async {
		final _queryParameters = <String, dynamic>{
		};
		final _result  = await dio.fetch<Map<String, dynamic>>(
			Options(
				method: "GET",
			)
		.compose(
				dio.options,
				"/posts/${id}",
				queryParameters: _queryParameters,
		)
		.copyWith(baseUrl: baseUrl ?? dio.options.baseUrl));
		final value = prefix1.UserInfoDto.fromJson(_result.data!);
		return value;
	}
  augment prefix0.Future<prefix1.SomeEntity> convert(prefix2.String from, prefix2.String to, ) async {
		final _queryParameters = <String, dynamic>{
			'from': from,
			'to': to,
		};
		final _result  = await dio.fetch<Map<String, dynamic>>(
			Options(
				method: "GET",
			)
		.compose(
				dio.options,
				"/convert",
				queryParameters: _queryParameters,
		)
		.copyWith(baseUrl: baseUrl ?? dio.options.baseUrl));
		final value = prefix1.SomeEntity.fromJson(_result.data!);
		return value;
	}
}
```
На самом деле, это лишь вершина айсберга - с полной версией так называемого macrofit вы можете ознакомиться на [pub.dev](https://pub.dev/packages/macrofit). Этот пакет в настоящее время находится в стадии разработки, но уже сейчас с его помощью можно делать GET, POST, PUT и DELETE запросы, а также работать с query-, path- и part-параметрами, задавать заголовки и тело запроса.

Что же касается нашего маленького примера - как по мне, макросы идеально подходят для таких задач, как генерация сетевых запросов. А уж если объединить это с `@JsonCodable` и `@DataClass`, то мы получаем полностью автоматизированный процесс создания сетевых запросов - всё, что от нас требуется это написать каркас класса и добавить аннотации.

# Выводы

Несмотря на все свои возможности, макросы не позволяют генерировать код столь же свободно, как это позволяет [code_builder](https://pub.dev/packages/code_builder) и имеют свои ограничения, некоторые из которых мы обсудили в этой статье.

Но даже с учётом этого макросы это гигантский шаг вперёд для Dart. Их появление коренным образом изменит подход к написанию кода, позволяя автоматизировать многие рутинные задачи. При этом они таят в себе опасность - код, обильно сдобренный макросами, будет сложно читать, возможность различных сайд-эффектов, причина которых будет неочевидна, существенно возрастёт. Однако, если использовать этот инструмент с умом, то его польза значительно превысит возможные недостатки.

При этом у меня сформировалось стойкое ощущение, что макросы ещё слишком сыры и нестабильны для релиза в начале 2025 года. Хочется верить, что я ошибаюсь.

Со всеми примерами из этой статьи можно ознакомиться в [репозитории](https://www.youtube.com/watch?v=dQw4w9WgXcQ).
