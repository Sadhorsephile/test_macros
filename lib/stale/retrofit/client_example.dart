import 'package:dio/dio.dart';
import 'package:test_macros/stale/main.dart';
import 'package:test_macros/stale/retrofit/annotations.dart';
import 'package:test_macros/stale/retrofit/client_macro.dart';
import 'package:test_macros/stale/retrofit/test_entity.dart';
import 'package:json/json.dart';
import 'package:test_macros/stale/data_class.dart';

@RestClient()
class ClientExample {
  final Dio _dio;

  ClientExample(this._dio, [this.baseUrl]);

  @GET('some/path/{id}')
  external Future<TestEntity> getQuery(String id, String name);

  @POST('some/path/user')
  external Future<List<AnotherEntity>> updateQuery(
    @Header('Test') String id,
    @Body() String name,
  );

  @GET('/posts')
  external Future<List<TestResponse>> getPosts(@Query() String id);

  @GET('/posts')
  external Future<void> testPosts();
}

@JsonCodable()
@DataClass()
class TestEntity {
  final String id;
  final String name;
}

