import 'dart:async';

import 'package:macros/macros.dart';

macro class ConverterMacro implements ClassDeclarationsMacro {
  const ConverterMacro();
  
  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    builder.declareInType(DeclarationCode.fromParts(
      [
        'augment int get a => 5;'
      ]
    ));
  }
  
}