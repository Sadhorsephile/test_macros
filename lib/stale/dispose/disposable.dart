import 'dart:async';

import 'package:macros/macros.dart';

macro class Disposable implements ClassDeclarationsMacro {
  const Disposable();

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final fields = await builder.fieldsOf(clazz);
    final methods = await builder.methodsOf(clazz);
    final fieldsWithDisposeAnnotation = fields.where((f) => f.metadata.any((m) => m is ConstructorMetadataAnnotation && m.type.identifier.name == 'NeedToDispose'));
    final alreadyHasDisposeMethod = methods.any((m) => m.identifier.name == 'dispose');

    builder.declareInType(
      DeclarationCode.fromParts([
        '\n',
        '\t${alreadyHasDisposeMethod ? 'augment ' : ''}void dispose() {\n',
        fieldsWithDisposeAnnotation.map((f) {
          final type = f.type;

          if (type is! NamedTypeAnnotation) return '\t\t${f.identifier.name}.dispose();\n';

          final methodName = () {
            if (type.identifier.name.startsWith('StreamSubscription')) {
              return 'cancel';
            } else if (type.identifier.name.startsWith('StreamController')) {
              return 'close';
            }
            return 'dispose';
          }();

          return '\t\t${f.identifier.name}.$methodName();\n';
        }).join(),
        '\t}\n',
      ]),
    );
  }
}