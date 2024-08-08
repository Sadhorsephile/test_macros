class NamedParam<T> {
  final T? defaultValue;
  const NamedParam({this.defaultValue});
}

const requiredField = Required();

class Required {
  const Required();
}