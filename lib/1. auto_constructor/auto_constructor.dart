import 'dart:async';

import 'package:collection/collection.dart';
import 'package:macros/macros.dart';

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
      '\t\t{\n',
      ...namedParams,
      '\t\t}',
      '\n\t);',
    ]);

    builder.declareInType(DeclarationCode.fromParts(code));
  }
}
