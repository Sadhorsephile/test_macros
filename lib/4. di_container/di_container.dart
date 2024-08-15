import 'dart:async';

import 'package:macros/macros.dart';

macro class DiContainer implements ClassDeclarationsMacro {
  const DiContainer();

  @override
  FutureOr<void> buildDeclarationsForClass(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
  ) async {
    builder.declareInLibrary(DeclarationCode.fromString('// ignore_for_file: unnecessary_import'));

    final initMethodParts = <Object>[
      'Future<void> init() async {\n',
    ];

    final fields = await builder.fieldsOf(clazz);

    final dependencyToConstructorParams = <String, List<String>>{};

    for (final field in fields) {
      final type = field.type;
      if (type is! NamedTypeAnnotation) continue;

      /// Отсекаем все поля, которые не являются Registry.
      if (type.identifier.name != 'Registry') continue;

      final generic = type.typeArguments.firstOrNull;

      if (generic is! NamedTypeAnnotation) continue;

      final typeDeclaration = await builder.typeDeclarationOf(generic.identifier);

      if (typeDeclaration is! ClassDeclaration) continue;

      final fields = await builder.fieldsOf(typeDeclaration);

      final constructorParams = fields.where((e) => !e.hasInitializer).toList();

      dependencyToConstructorParams[field.identifier.name.replaceFirst('_', '')] =
          constructorParams.map((e) => e.identifier.name.replaceFirst('_', '')).toList();

      final superClass = typeDeclaration.interfaces.firstOrNull;

      builder.declareInType(
        DeclarationCode.fromParts(
          [
            'late final ',
            superClass?.code ?? generic.code,
            ' ${field.identifier.name.replaceFirst('_', '')};',
          ],
        ),
      );
    }

    final sorted = _topologicalSort(
      dependencyToConstructorParams,
      builder,
    );

    for (final dep in sorted) {
      if (!dependencyToConstructorParams.keys.contains(dep)) continue;

      /// Получаем что-то вроде:
      /// ```
      /// someDependency = await _someDependency();
      /// ```
      initMethodParts.addAll([
        '\t\t$dep = await _$dep();\n',
      ]);
    }

    initMethodParts.add('\t}');

    builder.declareInType(DeclarationCode.fromParts(initMethodParts));
  }

  List<T> _topologicalSort<T>(
    Map<T, List<T>> graph,
    MemberDeclarationBuilder builder,
  ) {
    /// Обработанные вершины.
    final visited = <T>{};

    /// Вершины, в которых мы находимся на текущий момент.
    final current = <T>{};

    /// Вершины, записанные в топологическом порядке.
    final result = <T>[];

    /// Рекурсивная функция обхода графа.
    /// Возвращает [T], который образует цикл. Если цикла нет, возращает null.
    T? process(T node) {
      /// Если вершина уже обрабатывается, значит, мы нашли цикл.
      if (current.contains(node)) {
        return node;
      }

      /// Если вершина уже обработана, то пропускаем её.
      if (visited.contains(node)) {
        return null;
      }

      /// Добавляем вершину в текущие.
      current.add(node);

      /// Повторяем для всех соседей.
      for (final neighbor in graph[node] ?? []) {
        final result = process(neighbor);
        if (result != null) {
          return result;
        }
      }

      current.remove(node);
      visited.add(node);
      result.add(node);
      return null;
    }

    for (final node in graph.keys) {
      final cycleAffectingNode = process(node);

      /// Если обнаружен цикл, то выбрасываем исключение.
      if (cycleAffectingNode != null) {
        builder.report(
          Diagnostic(
            DiagnosticMessage(
              '''Cycle detected in the graph. '''
              '''$cycleAffectingNode requires ${graph[cycleAffectingNode]?.join(', ')}''',
            ),
            Severity.error,
          ),
        );
        throw Exception();
      }
    }
    return result;
  }
}
