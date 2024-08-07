
import 'dart:async';

import 'package:macros/macros.dart';

macro class DiScope implements ClassDeclarationsMacro, ClassDefinitionMacro {
  const DiScope();

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final fields = await builder.fieldsOf(clazz);

    for (final field in fields) {
      final fieldName = field.identifier.name;
      final fieldType = field.type;
      
      if (fieldType is! NamedTypeAnnotation) {
        builder.report(Diagnostic(DiagnosticMessage('$fieldName has no type'), Severity.error));
        continue;
      }

      final typeArg = fieldType.typeArguments.firstOrNull;

      if (typeArg == null) {
        builder.report(Diagnostic(DiagnosticMessage('$fieldName has no type argument'), Severity.error));
        continue;
      }

      final typeDecl = await builder.typeDeclarationOf((typeArg as NamedTypeAnnotation).identifier);

      
      
      builder.declareInType(
        DeclarationCode.fromParts(['late final ',typeArg.code, ' ${fieldName.replaceFirst('_', '')}',';\n']),
      );
    }
  }
  
  @override
  FutureOr<void> buildDefinitionForClass(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
    final fields = await builder.fieldsOf(clazz);

    final constructors = await builder.constructorsOf(clazz);

    if (constructors.isEmpty) {
      builder.report(Diagnostic(DiagnosticMessage('No constructors found'), Severity.error));
      return;
    }

    final constructor = constructors.first;

    final constructorBuilder = await builder.buildConstructor(constructor.identifier);

    for (final field in fields) {
      
    }

    constructorBuilder.augment(
      body: FunctionBodyCode.fromParts([
          '{\n',
          '\t\t\t;\n',
          '\t\t}\n',
        ]),
        );
  }
}