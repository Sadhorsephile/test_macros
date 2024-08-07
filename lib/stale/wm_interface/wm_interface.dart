import 'dart:async';

import 'package:macros/macros.dart';

macro class WmInterface implements ClassTypesMacro, ClassDeclarationsMacro {
  const WmInterface();
  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final fields = await builder.fieldsOf(clazz);
    final methods = await builder.methodsOf(clazz);

    final publicFields = fields.where((f) => !f.identifier.name.startsWith('_'));
    final publicMethods = methods.where((m) => !m.identifier.name.startsWith('_'));


    final superclass = clazz.superclass;

    if (superclass == null) {
      builder.report(Diagnostic(DiagnosticMessage('Class have no superclass'), Severity.error));
      return;
    }

    final superclassDeclaration = await builder.typeDeclarationOf(superclass.identifier);


    // builder.declareInLibrary(
    //   DeclarationCode.fromParts([
    //     '\n',
    //     'abstract class I${clazz.identifier.name} {\n',
    //     // publicFields.map((f) => '\t${f.type.code} get ${f.identifier.name};\n').join(),
    //     // publicMethods.map((m) {
    //     //   // final positionalParams = m.positionalParameters;
    //     //   // final namedParams = m.namedParameters;
    //     //   final returnType = m.returnType;
    //     //   return [returnType.code,' ',m.identifier.name,'();'];
    //     // }).expand((e) => e),
    //     '}\n',
    //   ]),
    // );
  }
  
  @override
  FutureOr<void> buildTypesForClass(ClassDeclaration clazz, ClassTypeBuilder builder) {
    final className = clazz.identifier.name;
    builder.declareType('I$className', DeclarationCode.fromString('abstract class I$className {}'));
  }
}

