import 'dart:async';

import 'package:collection/collection.dart';
import 'package:macros/macros.dart';
import 'package:test_macros/3.%20auto_dispose/annotations.dart';

macro class AutoDispose implements ClassDeclarationsMacro {
  
  final Map<String, String> disposeMethodNames;
  const AutoDispose([this.disposeMethodNames = const {}]);

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final allMethodNames = {
      disposableAnnotationName: disposeMethod,
      closableAnnotationName: closeMethod,
      cancelableAnnotationName: cancelMethod,
      ...disposeMethodNames,
    };

    final fields = await builder.fieldsOf(clazz);

    /// Ключ - имя поля, значение - имя метода для вызова.
    final disposables = <String, Object>{};

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

    final methods = await builder.methodsOf(clazz);

    final currentDisposeMethod = methods.firstWhereOrNull((element) => element.identifier.name == 'dispose');

    if (currentDisposeMethod != null) {
      final params = [
        ...currentDisposeMethod.namedParameters,
        ...currentDisposeMethod.positionalParameters,
      ];
      if (params.isNotEmpty) {
        builder.report(
          Diagnostic(
            DiagnosticMessage('dispose method should not have any parameters'),
            Severity.error,
          ),
        );
        return;
      }

      final returnType = currentDisposeMethod.returnType;

      if (returnType is! NamedTypeAnnotation || returnType.identifier.name != 'void') {
        builder.report(
          Diagnostic(
            DiagnosticMessage('dispose method should have void return type'),
            Severity.error,
          ),
        );
        return;
      }
    }

    final code = <Object>[
      '\t${currentDisposeMethod == null ? '' : 'augment'} void dispose() {\n',
      ...disposables.entries.map((e) {
        return ['\t\t${e.key}.', e.value, '();\n'];
      }).expand((e) => e),
      '\t}',
    ];

    builder.declareInType(DeclarationCode.fromParts(code));
  }
 
}
