import 'dart:async';

import 'package:macros/macros.dart';

macro class ValueNotifierGetter implements FieldDeclarationsMacro {
  final Type? type;
  final String? name;

  const ValueNotifierGetter({
    this.type,
    this.name,
  });

  @override
  FutureOr<void> buildDeclarationsForField(FieldDeclaration field, MemberDeclarationBuilder builder) async {
    final nameOfGetter =  name ?? field.identifier.name.replaceFirst('_', '');

    final type = field.type;

    if (type is NamedTypeAnnotation) {
      if (type.identifier.name != 'ValueNotifier') {
        builder.report(Diagnostic(DiagnosticMessage('Field ${field.identifier.name} is not a ValueNotifier'), Severity.error));
        return;
      }

      final typeArg = type.typeArguments.firstOrNull;

      if (typeArg == null || typeArg is! NamedTypeAnnotation) {
        builder.report(Diagnostic(DiagnosticMessage('Field ${field.identifier.name} has no type argument'), Severity.error));
        return;
      }

      final valueListenableType = await builder.resolveIdentifier(Uri.parse('package:flutter/src/foundation/change_notifier.dart'), 'ValueListenable');

      

      builder.declareInType(
        DeclarationCode.fromParts([
          '  ', valueListenableType, '<${typeArg.identifier.name}> get $nameOfGetter => ', field.identifier.name, ';\n',
        ]),
      );
    }
  }
}