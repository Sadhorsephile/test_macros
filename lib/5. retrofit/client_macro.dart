// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:macros/macros.dart';

const baseUrlVarSignature = 'baseUrl';
const dioVarSignature = 'dio';
const queryVarSignature = '_queryParameters';

macro class DisableDuplicateImportCheck implements LibraryDeclarationsMacro {
  const DisableDuplicateImportCheck();
  @override
  FutureOr<void> buildDeclarationsForLibrary(Library library, DeclarationBuilder builder) {
    builder.declareInLibrary(DeclarationCode.fromString('// ignore_for_file: duplicate_import'));
  }
}

macro class RestClient implements ClassDeclarationsMacro {
  const RestClient();

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final fields = await builder.fieldsOf(clazz);

    builder.declareInLibrary(DeclarationCode.fromString('import \'package:dio/dio.dart\';'));
    builder.declareInLibrary(DeclarationCode.fromString('import \'dart:core\';'));

    /// Check if the class has a baseUrl field.
    final indexOfBaseUrl = fields.indexWhere((element) => element.identifier.name == baseUrlVarSignature);
    if (indexOfBaseUrl == -1) {
      builder.declareInType(DeclarationCode.fromParts(['\tfinal String? $baseUrlVarSignature;']));
    } else {
      builder.report(
        Diagnostic(
          DiagnosticMessage('$baseUrlVarSignature is already defined.'),
          Severity.error,
        ),
      );
      return;
    }

    /// Check if the class has a Dio field.
    final indexOfDio = fields.indexWhere((element) => element.identifier.name == dioVarSignature);
    if (indexOfDio == -1) {
      builder.declareInType(DeclarationCode.fromString('\tfinal Dio $dioVarSignature;'));
    } else {
      builder.report(
        Diagnostic(
          DiagnosticMessage('$dioVarSignature is already defined.'),
          Severity.error,
        ),
      );
      return;
    }
  }
}

/// Общий тип, который возвращает метод:
/// - коллекция
/// - одно значение
/// - ничего
enum ReturnType { collection, single, none }

macro class GET implements MethodDefinitionMacro {
  final String path;

  const GET(this.path);


  @override
  FutureOr<void> buildDefinitionForMethod(MethodDeclaration method, FunctionDefinitionBuilder builder) async {
    const stringTypeName = 'String';
    const dynamicTypeName = 'dynamic';
    const mapTypeName = 'Map';
    const optionsTypeName = 'Options';
    const listTypeName = 'List';

    final stringType = await builder.resolveIdentifier(Uri.parse('dart:core'), stringTypeName);
    final dynamicType = await builder.resolveIdentifier(Uri.parse('dart:core'), dynamicTypeName);
    final mapType = await builder.resolveIdentifier(Uri.parse('dart:core'), mapTypeName);
    final optionsType = await builder.resolveIdentifier(Uri.parse('package:dio/src/options.dart'), optionsTypeName);
    final listType = await builder.resolveIdentifier(Uri.parse('dart:core'), listTypeName);

    /// Шорткат для `<String, dynamic>`.
    final stringDynamicMapType = ['<', stringType, ', ', dynamicType, '>'];

    /// Здесь у нас будет что-то вроде `Future<UserInfoDto>`.
    var type = method.returnType;

    /// Сюда запишем тип возвращаемого значения.
    NamedTypeAnnotation? valueType;
    late ReturnType returnType;

    /// На случай, если тип возвращаемого значения опущен при объявлении метода, попробуем его получить.
    if (type is OmittedTypeAnnotation) {
      type = await builder.inferType(type);
    }

    if (type is NamedTypeAnnotation) {
      /// Проверяем, что тип возвращаемого значения - Future.
      if (type.identifier.name != 'Future') {
        builder.report(
          Diagnostic(
            DiagnosticMessage('The return type of the method must be a Future.'),
            Severity.error,
          ),
        );
        return;
      }

      /// Получаем джинерик типа. У Future он всегда один.
      final argType = type.typeArguments.firstOrNull;

      valueType = argType is NamedTypeAnnotation ? argType : null;

      switch (valueType?.identifier.name) {
        case 'List':
          returnType = ReturnType.collection;
          valueType = valueType?.typeArguments.firstOrNull as NamedTypeAnnotation?;
        case 'void':
          returnType = ReturnType.none;
        default:
          returnType = ReturnType.single;
      }
    } else {
      builder.report(
        Diagnostic(
          DiagnosticMessage('Cannot determine the return type of the method.'),
          Severity.error,
        ),
      );
      return;
    }

    if (valueType == null) {
      builder.report(
        Diagnostic(
          DiagnosticMessage('Cannot determine the return type of the method.'),
          Severity.error,
        ),
      );
      return;
    }

    /// Сюда будем собирать код для создания query параметров.
    final queryParamsCreationCode = <Object>[];

    final fields = [
      ...method.positionalParameters,
      ...method.namedParameters,
    ];

    /// Собираем query параметры.
    final queryParams = fields
        .where((e) => e.metadata.any((e) => e is IdentifierMetadataAnnotation && e.identifier.name == 'query'))
        .toList();

    queryParamsCreationCode.addAll([
      '\t\tfinal $queryVarSignature = ', ...stringDynamicMapType, '{\n',
      ...queryParams.map((e) => "\t\t\t'${e.name}': ${e.name},\n"),
      '\t\t};\n',
    ]);

    final substitutedPath = path.replaceAllMapped(RegExp(r'{(\w+)}'), (match) {
      final paramName = match.group(1);
      final param = fields.firstWhere((element) => element.identifier.name == paramName,
          orElse: () => throw ArgumentError('Parameter \'$paramName\' not found'));
      return '\${${param.identifier.name}}';
    });

    builder.augment(FunctionBodyCode.fromParts([
      'async {\n',
      ...queryParamsCreationCode,
      '\t\tfinal _result  = await $dioVarSignature.fetch<', 
      ...switch (returnType) {
        ReturnType.none => ['void'],
        ReturnType.single => [mapType, ...stringDynamicMapType],
        ReturnType.collection => [listType, '<', dynamicType, '>'],
      },
      '>(\n',
      '\t\t\t', optionsType,'(\n',
      '\t\t\t\tmethod: "GET",\n',
      '\t\t\t)\n',
      '\t\t.compose(\n',
      '\t\t\t	$dioVarSignature.options,\n',
      '\t\t\t	"$substitutedPath",\n',
      '\t\t\t	queryParameters: $queryVarSignature,\n',
      '\t\t)\n',
      '\t\t.copyWith(baseUrl: $baseUrlVarSignature ?? $dioVarSignature.options.baseUrl));\n',
      ...switch (returnType) {
        ReturnType.none => [
            '\t\tfinal value = ',
            valueType.code,
            '.fromJson(_result.data!);\n',
            '\t\treturn value;\n',
            '\t}',
          ],
        ReturnType.single => [
            '\t\tfinal value = ',
            valueType.code,
            '.fromJson(_result.data!);\n',
            '\t\treturn value;\n',
            '\t}',
          ],
        ReturnType.collection => [
            '\t\tfinal value = (_result.data as ', listType, ').map((e) => ',
            valueType.code,
            '.fromJson(e)).toList();\n',
            '\t\treturn value;\n',
            '\t}',
          ],
      }
    ]));
  }
}
