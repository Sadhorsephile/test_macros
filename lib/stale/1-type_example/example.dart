// class ExampleConverter<






import 'package:test_macros/stale/1-type_example/converter.dart';
import 'package:test_macros/stale/1-type_example/entities.dart';
import 'package:test_macros/stale/1-type_example/typedef_converter.dart';


// typedef IExampleConverter = void;

@TypedefConverter('package:test_macros/stale/1-type_example/converter.dart')
final class ExampleConverter implements Converter<InputEntity, OutputEntity> {
  @override
  OutputEntity convert(InputEntity input) {
    return OutputEntity(id: input.id.toString());
  }
}
