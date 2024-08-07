import 'dart:async';

import 'package:macros/macros.dart';

macro class GET implements FunctionDefinitionMacro {
  final String path;
  const GET(this.path);

  @override
  FutureOr<void> buildDefinitionForFunction(
    FunctionDeclaration function,
    FunctionDefinitionBuilder builder,
  ) async {
    final returnType = function.returnType;

    if (returnType is! NamedTypeAnnotation) {
      builder.report(
        Diagnostic(
          DiagnosticMessage('Функция должна иметь возвращаемый тип'),
          Severity.error,
        ),
      );
      return;
    }

    if (returnType.identifier.name != 'Future') {
      builder.report(
        Diagnostic(
          DiagnosticMessage('Функция должна являться Future'),
          Severity.error,
        ),
      );
      return;
    }

    final typeArg = returnType.typeArguments.firstOrNull;

    if (typeArg == null) {
      builder.report(
        Diagnostic(
          DiagnosticMessage('У функции должен быть generic'),
          Severity.error,
        ),
      );
      return;
    }

    final params = [
      ...function.namedParameters,
      ...function.positionalParameters,
    ];

    final queryParamsCode = [
      '\t\tfinal _queryParams = {\n',
      ...params.map((p) =>'\t\t\t"${p.name}" : ${p.name},\n'),
      '\t\t};\n',
    ];



    builder.augment(
      FunctionBodyCode.fromParts(
        [
          'async {\n',
          ...queryParamsCode,
          '\t\tfinal response = await dio.get(\n',
          "'\t\t\t\${baseUrl}$path',\n",
          '\t\t\tqueryParameters: _queryParams,\n',
          '\t\t);\n',
          '\t\treturn ', typeArg.code ,'.fromJson(response.data!);\n',
          '\t}',
        ],
      ),
    );
  }
}
