// import 'dart:async';

// import 'package:macros/macros.dart';

// macro class DiAssembly implements ClassDeclarationsMacro, ClassDefinitionMacro {
//   const DiAssembly();

//   @override
//   FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
//     final fields = await builder.fieldsOf(clazz);
//     final fieldsString = fields.map((f) => f.identifier.name).join(', ');
  
//     final name = (await builder.typeDeclarationOf(clazz.identifier)).identifier.name;
//     builder.declareInLibrary(
//       DeclarationCode.fromString("import 'package:test_macros/stale/assembly.dart';")
//     );
//     builder.declareInType(
//       DeclarationCode.fromParts([
//          '$name() {',
//          '[$fieldsString].forEach((field) => field.runtimeType);',
//          '}',
//        ],
//       ),
//     );

//     for (final field in fields) {
//       final fieldName = field.identifier.name;
      
//       builder.declareInType(
//         DeclarationCode.fromParts(['  dynamic get ${fieldName.replaceFirst('_', '')} => $fieldName.get;']),
//       );
//     }

//   }
  
//   @override
//   FutureOr<void> buildDefinitionForClass(ClassDeclaration clazz, TypeDefinitionBuilder builder) async {
//     final fields = await builder.fieldsOf(clazz);

//     for (final field in fields) {
//       final fieldName = field.identifier.name;
      
//       final a = await builder.buildField(field.identifier);
      
//       var type = field.type;

//       var typeStringified = '';

//        if (type is OmittedTypeAnnotation) {
//         type = await builder.inferType(type);
//       }

//       if (type is NamedTypeAnnotation) {
//         typeStringified = type.identifier.name;
//         final argType = type.typeArguments.first;
//         final argTypeStringified = argType is NamedTypeAnnotation ? argType.identifier.name : null;
//         typeStringified = argTypeStringified ?? '';
//       }
      
//       a.augment(
//         getter: DeclarationCode.fromParts([
//           '$typeStringified get ${fieldName.replaceFirst('_', '')} => $fieldName.get;',
//         ]),
//       );
//     }
//   }
// }