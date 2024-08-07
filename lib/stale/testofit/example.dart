import 'package:dio/dio.dart';
import 'package:test_macros/stale/testofit/entity.dart';
import 'package:test_macros/stale/testofit/testofit.dart';

class Client {
  final Dio dio;
  final String baseUrl;

  Client({required this.dio, required this.baseUrl});

   @GET('some/path')
   external Future<TestResponse> query(int limit, int offset);
}