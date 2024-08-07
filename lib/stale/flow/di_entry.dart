// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:macros/macros.dart';

macro class DiEntry implements ClassDeclarationsMacro {
  const DiEntry();

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final methods = await builder.methodsOf(clazz);

    final fields = await builder.fieldsOf(clazz);

    /// create constructor
    builder.declareInType(
      DeclarationCode.fromParts([
        '\t\t', clazz.identifier.name, '({\n',
        fields.map((f) => '\t\t\trequired this.${f.identifier.name},\n').join(),
        '\t\t});\n',
      ]),
    );

    final createScopeMethod = methods.firstWhereOrNull((m) => m.identifier.name == 'buildScope');

    if (createScopeMethod == null) {
      builder.report(Diagnostic(DiagnosticMessage('No buildScope method found'), Severity.error));
      return;
    }

    builder.declareInLibrary(DeclarationCode.fromString("import 'package:flutter/material.dart';"));

    builder.declareInType(
      DeclarationCode.fromParts([
        '\n',
        '\t\tWidget wrappedRoute(BuildContext context) {\n',
        '\t\t\t\tfinal scope = ', createScopeMethod.identifier.name, '(context);\n',
        '\t\t\t\treturn DiScope<', createScopeMethod.returnType.code, '>(\n',
        '\t\t\t\t\tonFactory: () => scope,\n',
        '\t\t\t\t\tonDispose: (onDisposeScope) => onDisposeScope.dispose(),\n',
        '\t\t\t\t\tchild: this,\n',
        '\t\t\t\t);\n',
        '\t\t}\n'
      ])
    );
  }
}