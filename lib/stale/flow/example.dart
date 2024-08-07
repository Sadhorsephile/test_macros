import 'package:flutter/material.dart';
import 'package:test_macros/stale/flow/di_entry.dart';

@DiEntry()
class SomeScreenFlowWithMacros extends StatelessWidget {
  final String id;

  ISomeScreenScope buildScope(BuildContext context) => SomeScreenScope(id);

  @override
  Widget build(BuildContext context) => const SomeScreen();
}

class SomeScreenFlow extends StatelessWidget {
  const SomeScreenFlow({
    required this.id,
    super.key,
  });
  
  final String id;

  Widget wrappedRoute(BuildContext context) {
    final scope = SomeScreenScope(id);

    return DiScope<ISomeScreenScope>(
      onFactory: () => scope,
      onDispose: (onDisposeScope) => onDisposeScope.dispose(),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SomeScreen();
  }
}

abstract class ISomeScreenScope {
  void dispose();
}

class SomeScreenScope implements ISomeScreenScope {
  final String id;

  @override
  void dispose() {}

  SomeScreenScope(this.id);
}

class DiScope<T> extends StatelessWidget {
  final VoidCallback onFactory;
  final ValueChanged<T> onDispose;
  final Widget child;
  const DiScope({
    super.key,
    required this.onFactory,
    required this.onDispose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class SomeScreen extends StatelessWidget {
  const SomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
