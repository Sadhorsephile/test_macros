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

    // ignore: deprecated_member_use
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
