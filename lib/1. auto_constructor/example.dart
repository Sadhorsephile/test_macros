import 'package:test_macros/1.%20auto_constructor/annotations.dart';
import 'package:test_macros/1.%20auto_constructor/auto_constructor.dart';

@AutoConstructor()
class AnotherComplicatedClass {
  final int a;

  @requiredField
  @NamedParam()
  final String b;

  @NamedParam(defaultValue: 3.14)
  final double c;

  @NamedParam()
  final bool? d;

  @requiredField
  @NamedParam()
  final bool? e;

  final List<int> f;
}

void main() async {
  AnotherComplicatedClass(
    1,
    [],
    b: 'a',
    c: 2,
    d: false,
    e: false,
  );
}
