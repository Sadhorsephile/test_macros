import 'dart:async';

import 'package:macros/macros.dart';

macro class EquatableMacro implements ClassTypesMacro, ClassDeclarationsMacro {
  final bool stringify;
  const EquatableMacro({required this.stringify});
  
  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final fields = await builder.fieldsOf(clazz);
    final finalFields = fields.where((field) => field.hasFinal).toList();

    builder.declareInType(DeclarationCode.fromParts([
      '\t@override\n',
      '\tList<Object?> get props => [\n',
      for (final field in finalFields) '\t\t${field.identifier.name},\n',
      '\t];\n',
    ]));

    builder.declareInType(DeclarationCode.fromParts([
      '\t@override\n',
      '\tbool get stringify => $stringify;',
    ]));
  }

  @override
  FutureOr<void> buildTypesForClass(ClassDeclaration clazz, ClassTypeBuilder builder) async {
    // ignore: deprecated_member_use
    final identifier = await builder.resolveIdentifier(Uri.parse('package:equatable/src/equatable.dart'), 'Equatable');
    builder.appendInterfaces([NamedTypeAnnotationCode(name: identifier)]);
  }
}
