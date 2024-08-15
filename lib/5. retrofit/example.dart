// ignore_for_file: avoid_print

@DisableDuplicateImportCheck()
library example;

import 'package:test_macros/5.%20retrofit/annotations.dart';
import 'package:test_macros/5.%20retrofit/client_macro.dart';
import 'package:dio/dio.dart';

@RestClient()
class Client {
  Client(this.dio, {this.baseUrl});

  @GET('/posts/{id}')
  external Future<PostEntity> getPostById(int id);

  @GET('/posts')
  // ignore: non_constant_identifier_names
  external Future<List<PostEntity>> getPostsByUserId(@query int user_id);
}

class PostEntity {
  final int? userId;
  final int? id;
  final String? title;
  final String? body;

  PostEntity({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  factory PostEntity.fromJson(Map<String, dynamic> json) {
    return PostEntity(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'body': body,
    };
  }
}

Future<void> main() async {
  final dio = Dio()..interceptors.add(LogInterceptor(logPrint: print));
  final client = Client(dio, baseUrl: 'https://jsonplaceholder.typicode.com');

  const idOfExistingPost = 1;

  final post = await client.getPostById(idOfExistingPost);
  
  final userId = post.userId;

  if (userId != null) {
    final posts = await client.getPostsByUserId(userId);
    print(posts);
  }
}