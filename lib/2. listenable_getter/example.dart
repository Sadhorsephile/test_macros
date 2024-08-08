import 'package:flutter/material.dart';
import 'package:test_macros/2.%20listenable_getter/listenable_getter.dart';

class WidgetModel {
  @ListenableGetter()
  final _counter = ValueNotifier<int>(0);
  @ListenableGetter(name: 'secondCounter')
  final _secondCounter = ValueNotifier(1);
}

void foo() {
  final a = WidgetModel();
  print(a.counter.value); // ValueListenable<int>
  print(a.secondCounter.value); // ValueListenable<int>
}