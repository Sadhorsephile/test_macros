
import 'dart:async';

import 'package:test_macros/stale/dispose/annotation.dart';
import 'package:test_macros/stale/dispose/disposable.dart';

@Disposable()
class SomeModel {
  @NeedToDispose()
  final SomeDep someDep;
  @NeedToDispose()
  final AnotherDep anotherDep;
  @NeedToDispose()
  late final StreamSubscription<int> _streamSubscription;
  @NeedToDispose()
  final StreamController<int> _streamController = StreamController<int>();

  SomeModel(this.someDep, this.anotherDep);
}


class SomeDep {
  void dispose() {
    print('SomeDep disposed');
  }
}

class AnotherDep {
  final SomeDep someDep;

  AnotherDep(this.someDep);

  void dispose() {
    print('AnotherDep disposed');
  }
}