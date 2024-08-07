
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:test_macros/stale/main.dart';
import 'package:test_macros/stale/retrofit/annotations.dart';
import 'package:test_macros/stale/retrofit/client_macro.dart';

@RestClient()
class ClientExample {
  final Dio _dio;

  ClientExample(this._dio, [this.baseUrl]);

  @MultiPart('some/path')
  external Future<void> someRequest(
    @Part() String part1,
    @Part() File photo,
  );

  @POST('/posts/{userId}')
  external Future<void> updateProfile(
    @Header('Test') String testHeader,
    @Body() String name,
    @Body() String surname,
    String userId,
  );

  @DELETE('/posts/{id}')
  external Future<TestResponse> deletePost(
    @Header('Test') String id,
  );

  @GET('/posts')
  external Future<GenericResponse<List<double>>> getPosts2(
    @Query() int page,
    @Query() int limit,
  );
}