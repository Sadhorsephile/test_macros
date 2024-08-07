// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:macros/macros.dart';

/// Тип возвращаемого значения.
enum _ResponseType {
  /// Одна сущность. Например, запрос имеет вид Future<String>.
  single,
  /// Коллекция сущностей. Например, запрос имеет вид Future<List<String>>.
  list,
  /// Не ожидается ответ. Future<void>.
  empty,
}

/// Тип данных параметра для Multipart запроса.
enum _PartParamType {
  file,
  string,
  notString,
}

const _dartCoreUri = 'dart:core';

const _fileSignature = 'File';
const _stringSignature = 'String';
const _bodySignature = 'Body';
const _headerSignature = 'Header';
const _querySignature = 'Query';
const _partSignature = 'Part';
const _listSignature = 'List';
const _voidSignature = 'void';

const _bodyVarSignature = '_data';
const _queryVarSignature = 'queryParameters';
const _headerVarSignature = '_headers';
const _baseUrlVarSignature = 'baseUrl';


macro class ClientMacro implements ClassDeclarationsMacro {
  const ClientMacro();
  
  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) {
    builder.declareInLibrary(DeclarationCode.fromString("import 'package:dio/dio.dart';"));
  }

}

macro class GET implements  MethodDefinitionMacro {
  final String path;
  const GET(this.path);
  
  @override
  FutureOr<void> buildDefinitionForMethod(MethodDeclaration method, FunctionDefinitionBuilder builder) async {  
    return _buildMethod('GET', path, method, builder,);
  }
}

macro class POST implements MethodDefinitionMacro {
  final String path;
  const POST(this.path);
  
  @override
  FutureOr<void> buildDefinitionForMethod(MethodDeclaration method, FunctionDefinitionBuilder builder) async {  
    return _buildMethod('POST', path, method, builder,);
  }
}

macro class DELETE implements MethodDefinitionMacro {
  final String path;
  const DELETE(this.path);
  
  @override
  FutureOr<void> buildDefinitionForMethod(MethodDeclaration method, FunctionDefinitionBuilder builder) async {  
    return _buildMethod('DELETE', path, method, builder,);
  }
}

macro class PUT implements MethodDefinitionMacro {
  final String path;
  const PUT(this.path);
  
  @override
  FutureOr<void> buildDefinitionForMethod(MethodDeclaration method, FunctionDefinitionBuilder builder) async {  
    return _buildMethod('PUT', path, method, builder,);
  }
}

macro class Custom implements MethodDefinitionMacro {
  final String path;
  final String methodName;
  const Custom(this.path, {required this.methodName});
  
  @override
  FutureOr<void> buildDefinitionForMethod(MethodDeclaration method, FunctionDefinitionBuilder builder) async {  
    return _buildMethod(methodName, path, method, builder,);
  }
}

macro class MultiPart implements MethodDefinitionMacro {
  final String path;
  
  final String? queryParams;

  const MultiPart(this.path, {this.queryParams});
  
  @override
  FutureOr<void> buildDefinitionForMethod(MethodDeclaration method, FunctionDefinitionBuilder builder) async {  
    return _buildMethod('POST', path, method, builder, contentType: 'multipart/form-data');
  }
}



FutureOr<void> _buildMethod(String methodType, String path, MethodDeclaration method, FunctionDefinitionBuilder builder, {String? contentType}) async {  
    final type = method.returnType;

    /// Тип возвращаемого значения.
    TypeAnnotation? valueType;

    var responseType = _ResponseType.single;

    /// Собираем все используемые явно типы с их импортами.
    final stringType = await builder.resolveIdentifier(Uri.parse(_dartCoreUri), _stringSignature);
    final dynamicType = await builder.resolveIdentifier(Uri.parse(_dartCoreUri), 'dynamic');
    final mapType = await builder.resolveIdentifier(Uri.parse(_dartCoreUri), 'Map');
    final optionsType = await builder.resolveIdentifier(Uri.parse('package:dio/src/options.dart'), 'Options');
    final listType = await builder.resolveIdentifier(Uri.parse(_dartCoreUri), _listSignature);
    

    /// Шорткат для генерика <String, dynamic>.
    final stringDynamicMapType = ['<', stringType, ', ', dynamicType ,'>'];

    if (type is NamedTypeAnnotation) {
        final argType = type.typeArguments.firstOrNull;
        valueType = argType is NamedTypeAnnotation ? argType : null;
        if (argType is NamedTypeAnnotation) {
          responseType  = switch (argType.identifier.name) {
            _listSignature => _ResponseType.list,
            _voidSignature => _ResponseType.empty,
            _ => _ResponseType.single,
          };
        }

        if (valueType is NamedTypeAnnotation && responseType != _ResponseType.single) {
          final innerArgType = (valueType).typeArguments.firstOrNull;
          valueType = innerArgType is NamedTypeAnnotation ? innerArgType.code : valueType;
        }
    }

    /// Выбираем генерик для метода fetch:
    /// - если ответ одиночный, то Map<String, dynamic>;
    /// - если ответ список, то List<dynamic>;
    /// - если ответ не ожидается, то void.
    final fetchResolvedType = {
      _ResponseType.single: [mapType, ...stringDynamicMapType],
      _ResponseType.list: [listType, '<', dynamicType, '>',],
      _ResponseType.empty: [_voidSignature],
    };

    /// Все входные параметры.
    final fields = [...method.positionalParameters, ...method.namedParameters];
    
    /// Сюда собираем код метода.
    final parts = <Object>[
    'async {\n',
    '\t\tconst _extra = ', ...stringDynamicMapType,'{};\n',
    ..._buildQueryParams(fields, stringDynamicMapType),
    ..._buildHeader(fields, stringDynamicMapType),
    ...(await _buildBody(fields, stringDynamicMapType, builder)),
    '\t\t', responseType != _ResponseType.empty ? 'final _result  = ' : '',
    'await _dio.fetch<', 
    ...fetchResolvedType[responseType]!, '>(', optionsType,'(\n',
    "\t\t  method: '$methodType',\n",
    '\t\t  headers: $_headerVarSignature,\n',
    '\t\t  extra: _extra,\n',
    if (contentType != null) '\t\t\tcontentType: \'$contentType\',\n',
    '\t\t)\n',
    '\t\t.compose(\n',
    '\t\t\t_dio.options,\n',
    '\t\t\t"${_buildPath(fields, path)}",\n',
    '\t\t\tqueryParameters: $_queryVarSignature,\n',
    '\t\t\tdata: $_bodyVarSignature,\n',
    '\t\t)\n',
    '    .copyWith(baseUrl: $_baseUrlVarSignature ?? _dio.options.baseUrl));\n',
    
    ...(switch (responseType) {
      _ResponseType.single => ['\t\tfinal value = ',valueType!.code,'.fromJson(_result.data!);\n'],
      _ResponseType.list => ['\t\tfinal value = (_result.data! as ', listType, ').map((e) => ', valueType!.code, '.fromJson(e)).toList();\n'],
      _ResponseType.empty => [],
    }),
    if (responseType != _ResponseType.empty)'\t\treturn value;\n'
    ];
    
    parts.add('\t}');

    builder.augment(FunctionBodyCode.fromParts(parts));
  }

  bool _isBody(FormalParameterDeclaration field) {
    return field.metadata.any((e) => e.hasAnnotationOf(_bodySignature));
  }
  
  bool _isHeader(FormalParameterDeclaration field) {
    return field.metadata.any((e) => e.hasAnnotationOf(_headerSignature));
  }
  
  bool _isQuery(FormalParameterDeclaration field) {
    return field.metadata.any((e) => e.hasAnnotationOf(_querySignature));
  }
  
  bool _isPart(FormalParameterDeclaration field) {
    return field.metadata.any((e) => e.hasAnnotationOf(_partSignature));
  }


  extension AnnotationCheck on MetadataAnnotation {
    bool hasAnnotationOf(String classname) {
      final a = this;
      return a is ConstructorMetadataAnnotation && a.type.identifier.name == classname;
    }
  }

  Future<List<Object>> _buildBody(List<FormalParameterDeclaration> fields,  List<Object> stringDynamicMapType, FunctionDefinitionBuilder builder) async {
    /// Сюда пихаем код создания тела запроса.
    final bodyCreationCode = <Object>[];

    final bodyParams = fields.where(_isBody).toList();

    final partParams = fields.where(_isPart).toList();
    
    if (bodyParams.isNotEmpty && partParams.isEmpty) {
      /// Собираем body в формате:
      /// final _body = {
      ///  'id': id,
      /// 'name': name,
      /// };
      /// _data.addAll(_body);
      bodyCreationCode.addAll([
        '\t\tfinal $_bodyVarSignature = {\n',
        ...bodyParams.map((f) => "\t\t\t'${f.name}': ${f.name},\n"),
        '\t\t};\n',
      ]);
    }
    else if (partParams.isNotEmpty) {
      final formDataType = await builder.resolveIdentifier(Uri.parse('package:dio/src/form_data.dart'), 'FormData');
      final multipartFileType = await builder.resolveIdentifier(Uri.parse('package:dio/src/multipart_file.dart'), 'MultipartFile');
      final platformType = await builder.resolveIdentifier(Uri.parse('dart:io'), 'Platform');
      final mapEntryType = await builder.resolveIdentifier(Uri.parse(_dartCoreUri), 'MapEntry');
      bodyCreationCode.addAll([
        '\t\tfinal $_bodyVarSignature = ', formDataType, '();\n',
        ...partParams.map((part) {
          final type = part.type;
          final partParamType = type is NamedTypeAnnotation ? switch (type.identifier.name) {
            _stringSignature => _PartParamType.string,
            _fileSignature => _PartParamType.file,
            _ => _PartParamType.notString,
          } : _PartParamType.notString;

          switch (partParamType) {
            case _PartParamType.string:
              return [
                '\t\t$_bodyVarSignature.fields.add(',mapEntryType,'(\n',
                "\t\t\t'${part.name}',\n",
                '\t\t\t${part.name},\n',
                '\t\t));\n',
              ];
            case _PartParamType.file:
              return <Object>[
                '\t\t$_bodyVarSignature.files.add(',mapEntryType,'(\n',
                "\t\t\t'${part.name}',\n",
                '\t\t\t', multipartFileType, '.fromFileSync(${part.name}.path, filename: ${part.name}.path.split(', platformType ,'.pathSeparator).last),\n',
                '\t\t));\n',
              ];
            case _PartParamType.notString:
              return [
                '\t\t$_bodyVarSignature.fields.add(',mapEntryType,'(',
                "\t\t\t'${part.name}',",
                '\t\t\t${part.name}.toString(),',
                '\t\t));\n',
              ];
          }
        }).expand((e) => e),
      ]);
    }
    else {
      bodyCreationCode.addAll([
        '\t\tfinal $_bodyVarSignature = ', ...stringDynamicMapType, '{};\n',
      ]);
    }

    return bodyCreationCode;
  }

  List<Object> _buildQueryParams(List<FormalParameterDeclaration> fields, List<Object> stringDynamicMapType) {
    final queryParamsCreationCode = <Object>[];

    final queryParams = fields.where(_isQuery).toList();

    if (queryParams.isNotEmpty) {
      queryParamsCreationCode.addAll([
        '\t\tfinal $_queryVarSignature = ', ...stringDynamicMapType,'{\n',
        ...queryParams.map((e) => "\t\t\t'${e.name}': ${e.name},\n"),
        '\t\t};\n',
      ]);
    }
    else {
      queryParamsCreationCode.addAll([
        '\t\tfinal $_queryVarSignature = ', ...stringDynamicMapType,'{};\n',
      ]);
    }

    return queryParamsCreationCode;
  }

  List<Object> _buildHeader(List<FormalParameterDeclaration> fields, List<Object> stringDynamicMapType) {
   final headerParams = fields.where(_isHeader).toList();

    final headerParamsCreationCode = <Object>[];

    if (headerParams.isNotEmpty) {
      headerParamsCreationCode.addAll([
        '\t\tfinal $_headerVarSignature = ', ...stringDynamicMapType,'{\n',
        ...headerParams.map((e) {
          final meta = e.metadata.firstWhereOrNull((e) => e.hasAnnotationOf(_headerSignature)) as ConstructorMetadataAnnotation;
          final headerName = meta.positionalArguments.firstOrNull;
          
          return ['\t\t\t ', headerName!,": ${e.name},\n"];
        }).expand((e) => e),
        '\t\t};\n',
      ]);
    }
    else {
      headerParamsCreationCode.addAll([
        '\t\tfinal $_headerVarSignature = ', ...stringDynamicMapType,'{};\n',
      ]);
    }

    return headerParamsCreationCode;
  }

  String _buildPath(List<FormalParameterDeclaration> fields, String initialPath) {
    return initialPath.replaceAllMapped(RegExp(r'{(\w+)}'), (match) {
      final paramName = match.group(1);
      final param = fields.firstWhere((element) => element.identifier.name == paramName, orElse: () => throw ArgumentError('Parameter \'$paramName\' not found'));
      return '\${${param.identifier.name}}';
    });
  }


macro class RestClient implements ClassDeclarationsMacro {
  const RestClient();

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    final fields = await builder.fieldsOf(clazz);

    /// Ищем поле baseUrl и если его нет, то добавляем.
    final indexOfBaseUrl = fields.indexWhere((element) => element.identifier.name == _baseUrlVarSignature);
    if (indexOfBaseUrl == -1) {
      final stringType = await builder.resolveIdentifier(Uri.parse(_dartCoreUri), _stringSignature);
      builder.declareInType(DeclarationCode.fromParts(['\tfinal ', stringType, '? $_baseUrlVarSignature;']));
    }
    else {
      final baseUrlField = fields[indexOfBaseUrl];
      if (baseUrlField.type is! NamedTypeAnnotation) {
        throw ArgumentError('$_baseUrlVarSignature field must be of type $_stringSignature');
      }
      if ((baseUrlField.type as NamedTypeAnnotation).identifier.name != _stringSignature) {
        throw ArgumentError('$_baseUrlVarSignature field must be of type $_stringSignature');
      }
    }
  }
}