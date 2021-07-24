import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:test/test.dart';

void main() {
  test('UMLOperation stringRepresentation', () {
    final operation1 =
        UMLOperation('study', UMLVisibility.public, UMLDataType.voidType(), [
      UMLOperationParameter('subject', UMLDataType.string()),
      UMLOperationParameter('hours', UMLDataType.integer())
    ]);
    expect(operation1.stringRepresentation,
        '+ study(subject: string, hours: integer): void');

    final operation2 =
        UMLOperation('eat', UMLVisibility.protected, UMLDataType.boolean());
    expect(operation2.stringRepresentation, '# eat(): boolean');
  });
}
