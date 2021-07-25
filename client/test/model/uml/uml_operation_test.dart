import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:test/test.dart';

void main() {
  test('UMLOperation stringRepresentation', () {
    final operation1 = UMLOperation('study',
        visibility: UMLVisibility.public,
        returnType: UMLDataType.voidType(),
        parameters: [
          UMLOperationParameter('subject', type: UMLDataType.string()),
          UMLOperationParameter('hours', type: UMLDataType.integer())
        ]);
    expect(operation1.stringRepresentation,
        '+ study(subject: string, hours: integer): void');

    final operation2 = UMLOperation('eat',
        visibility: UMLVisibility.protected, returnType: UMLDataType.boolean());
    expect(operation2.stringRepresentation, '# eat(): boolean');
  });
}
