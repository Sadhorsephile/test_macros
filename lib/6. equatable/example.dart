import 'package:test_macros/6.%20equatable/macro.dart';


@EquatableMacro(stringify: true)
class SomeEntity {
  final String id;
  final String name;

  SomeEntity(this.id, this.name);
}