import 'dart:async';

import 'package:test_macros/4.%20di_container/di_container.dart';

@DiContainer()
class AppScope {
  late final Registry<SomeDependency> _someDependency = Registry(() {
    return SomeDependency();
  });
  late final Registry<ThirdDependency> _thirdDependency = Registry(() {
    return ThirdDependency(someDependency, anotherDependency);
  });
  late final Registry<AnotherDependency> _anotherDependency = Registry(() {
    return AnotherDependency(someDependency);
  });
}

abstract class ISomeDependency {}

class SomeDependency implements ISomeDependency {
}

abstract class IAnotherDependency {}

class AnotherDependency implements IAnotherDependency {
  final ISomeDependency someDependency;

  AnotherDependency(this.someDependency);
}

abstract class IThirdDependency {}

class ThirdDependency implements IThirdDependency {
  final ISomeDependency someDependency;
  final IAnotherDependency anotherDependency;

  ThirdDependency(this.someDependency, this.anotherDependency);
}

class Registry<T> {
  final FutureOr<T> Function() create;

  Registry(this.create);

  FutureOr<T> call() => create();
}


Future<void> main() async {
  final appScope = AppScope();
  await appScope.init();
}
