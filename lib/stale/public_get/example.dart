import 'package:flutter/foundation.dart';
import 'package:test_macros/stale/public_get/public_get.dart';

class WidgetModel implements IWidgetModel {
  // @ValueNotifierGetter()
  final ValueNotifier<int> _counter = ValueNotifier(0);  

  @override
  ValueListenable<int> get counter => _counter;
}

abstract class IWidgetModel {
  ValueListenable<int> get counter;
}