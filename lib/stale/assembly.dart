import 'dart:async';

class Registry<T> {
  final FutureOr<T> Function() creator;

  Registry(this.creator);
}
