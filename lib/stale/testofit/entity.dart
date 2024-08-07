import 'package:test_macros/stale/json/json.dart';

@JsonCodable()
class TestResponse {
  final String id;

  TestResponse(this.id);
}