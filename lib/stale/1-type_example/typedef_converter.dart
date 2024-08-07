// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:macros/macros.dart';

macro class TypedefConverter implements ClassTypesMacro {
  final String converterLibUri;
  const TypedefConverter(this.converterLibUri);
  
  @override
  FutureOr<void> buildTypesForClass(ClassDeclaration clazz, ClassTypeBuilder builder) async {
    final classInterface = clazz.interfaces.firstOrNull;
    if (classInterface == null) {
      builder.report(
        Diagnostic(
          DiagnosticMessage('Class doesn\'t have any interfaces', target: clazz.asDiagnosticTarget), 
          Severity.error,
        ),
      );
      return;
    }

    final typeArgs = classInterface.typeArguments;

    if (typeArgs.length != 2) {
      builder.report(
        Diagnostic(
          DiagnosticMessage('Must have only 2 type arguments - input and output entities', target: classInterface.asDiagnosticTarget), 
          Severity.error,
        ),
      );
      return;
    }

    final inputType = typeArgs.first as NamedTypeAnnotation;
    final outputType = typeArgs.last as NamedTypeAnnotation;
    final converter = await builder.resolveIdentifier(Uri.parse(converterLibUri), classInterface.identifier.name);

    // if (inputType is! NamedTypeAnnotation || outputType is! NamedTypeAnnotation) {
    //   builder.report(
    //     Diagnostic(
    //       DiagnosticMessage('Cannot identify', target: classInterface.asDiagnosticTarget), 
    //       Severity.error,
    //     ),
    //   );
    //   return;
    // }

    builder.declareType(
      'I${clazz.identifier.name}', 
      DeclarationCode.fromParts(
        ['abstract class I${clazz.identifier.name} implements ', converter, '<',]
      ),
    );
  }
}