// ignore_for_file: avoid_print

import 'package:test_macros/stale/data_class.dart';

@DataClass()
class User {
  final String id;
  final int? age;
  final String name;
  final String username;
}

void main() {
  final user = User(id: 'id', name: 'Name', username: 'username');
  print('${user.id} ${user.name} ${user.username}');
  print(user.hashCode);
  print(user.copyWith(id: 'new_id'));
}
