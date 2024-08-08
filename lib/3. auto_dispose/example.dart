import 'dart:async';

import 'package:test_macros/3.%20auto_dispose/annotations.dart';
import 'package:test_macros/3.%20auto_dispose/auto_dispose.dart';

@AutoDispose('customDepDispose:customDispose')
class SomeModel {
  @disposable
  final CommonDep a;
  @closable
  final StreamController<int> b;
  @cancelable
  final StreamSubscription<int> c;
  @customDepDispose
  final CustomDep d;

  SomeModel({required this.a, required this.b, required this.c, required this.d});

  // void dispose() {
  //   print('original dispose');
  // }
}

const customDepDispose = Disposable('customDispose');

class CommonDep {
  void dispose() {}
}

class CustomDep {
  void customDispose() {
    print('CustomDep disposed');
  }
}

void main() {
  final model = SomeModel(
    a: CommonDep(),
    b: StreamController<int>(),
    c: Stream.periodic(const Duration(seconds: 1), (i) => i).listen((event) {}),
    d: CustomDep(),
  );

  // model.dispose();
}
