import 'dart:async';

import 'package:test_macros/stale/di_assembly.dart';

@DiScope()
class AppScope {
  late final Registry<ISomeDependency> _someDependency = Registry(() {
    return SomeDependency();
  });
  late final Registry<IAnotherDependency> _anotherDependency = Registry(() {
    return AnotherDependency(someDependency);
  });

  external AppScope();
}

abstract interface class ISomeDependency {}

class SomeDependency implements ISomeDependency {}

abstract interface class IAnotherDependency {}

class AnotherDependency implements IAnotherDependency {
  final ISomeDependency _someDependency;

  AnotherDependency(this._someDependency);
}

class Registry<T> {
  final FutureOr<T> Function() creator;
  final Future<void> Function(T)? dispose;

  Registry(
    this.creator, {
    this.dispose,
  });
}
