import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:test_macros/2.%20listenable_getter/listenable_getter.dart';
import 'package:test_macros/3.%20auto_dispose/annotations.dart';
import 'package:test_macros/3.%20auto_dispose/auto_dispose.dart';

void main() async {
  runApp(MyApp());
}

@AutoDispose()
class MyApp extends StatelessWidget {
  @disposable
  final model = Model();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hello World'),
        ),
        body: ValueListenableBuilder<int>(
          valueListenable: model.counter,
          builder: (_, count, __) => Center(
            child: Text('Hello World: $count'),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            model._counter.value++;
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

@AutoDispose()
class Model {
  @disposable
  @ListenableGetter()
  final _counter = ValueNotifier<int>(0);
}
