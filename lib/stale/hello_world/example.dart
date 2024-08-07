import 'dart:developer';
import 'package:test_macros/stale/hello_world/macro.dart';

@HelloWorldMacro()
class TargetClass {}

void main() {
  final a = TargetClass();
  a.helloWorld(); // 'Hello world'
}