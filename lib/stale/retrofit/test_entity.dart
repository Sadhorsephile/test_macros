import 'package:json/json.dart';
import 'package:test_macros/stale/data_class.dart';

@JsonCodable()
@DataClass()
class AnotherEntity {
  final String id;
  final String name;
}

@JsonCodable()
@DataClass()
class TestEntity {
  final String id;
  final String name;
}