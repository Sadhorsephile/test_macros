import 'dart:async';

import 'package:macros/macros.dart';

macro class HelloWorldMacro implements ClassDeclarationsMacro {
  const HelloWorldMacro();

  @override
  FutureOr<void> buildDeclarationsForClass(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
  ) async {
    final logFunction = await builder.resolveIdentifier(Uri.parse('dart:developer'), 'log');
    builder.declareInType(
      DeclarationCode.fromParts(
        [
          '\tvoid helloWorld() {\n',
          '\t\t',logFunction,'("hello world");\n',
          '\t}',
        ],
      ),
    );
  }
}
