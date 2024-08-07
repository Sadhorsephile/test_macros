import 'package:dio/dio.dart';
import 'package:json/json.dart';
import 'package:test_macros/stale/data_class.dart';
import 'package:test_macros/stale/retrofit/client_example.dart';


void main() async {
  final dio = Dio();
  final client = ClientExample(dio, 'https://jsonplaceholder.typicode.com');
  final response = await client.getPosts('2');
  print(response);
}



@JsonCodable()
@DataClass()
class TestResponse {
  final int userId;
  final int id;
  final String title;
  final String body;
}


class GenericResponse<T> {
  final int userId;
  final int id;
  final String title;
  final T body;

  GenericResponse({required this.userId, required this.id, required this.title, required this.body});

  factory GenericResponse.fromJson(Map<String, dynamic> json) {
    return GenericResponse(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'] as T,
    );
  }
}

