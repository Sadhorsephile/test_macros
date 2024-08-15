import 'dart:async';

import 'package:test_macros/3.%20auto_dispose/annotations.dart';
import 'package:test_macros/3.%20auto_dispose/auto_dispose.dart';

@AutoDispose({'customDisposable': 'customDispose'})
class SomeModel {
  @disposable
  final CommonDep dep;
  @closable
  final StreamController<int> _controller = StreamController<int>();
  @cancelable
  late final StreamSubscription<int> _subscription;
  @customDisposable
  final CustomDep customDep;
  final CommonDep notForDisposeDep;

  SomeModel({required this.dep, required this.customDep, required this.notForDisposeDep}) {
    _subscription = _controller.stream.listen((event) {});
  }
}

class CommonDep {
  void dispose() {}
}

const customDisposable = CustomDispose();

class CustomDispose {
  const CustomDispose();
}

class CustomDep {
  void customDispose() {}
}

void main() {
  final model = SomeModel(
    dep: CommonDep(),
    customDep: CustomDep(),
    notForDisposeDep: CommonDep(),
  );

  model.dispose();
}
