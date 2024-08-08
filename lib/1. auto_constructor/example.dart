import 'package:test_macros/1.%20auto_constructor/annotations.dart';
import 'package:test_macros/1.%20auto_constructor/auto_constructor.dart';

@AutoConstructor()
class SomeComplicatedClass {
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

void main() {
  final instance = SomeComplicatedClass(
    1,
    [1,2],
    b: 'b',
    e: false,
  );

  print(instance.a);
  print(instance.b);
  print(instance.c);
  print(instance.d);
  print(instance.e);
  print(instance.f);
}
