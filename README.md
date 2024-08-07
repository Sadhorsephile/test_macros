```dart

macro class DataClass implements СтадияМакроса, ДругаяСтадияМакроса {
  const DataClass();

  @override
  Future<void> реализацияСтадииМакроса(
    ClassDeclaration clazz, 
    БилдерСтадииМакроса builder,
    ) async {
      // Реализация
    }
  
  @override
  Future<void> реализацияДругойСтадииМакроса(
    ClassDeclaration clazz, 
    БилдерДругойСтадииМакроса builder,
    ) async {
      // Реализация
    }
}
```