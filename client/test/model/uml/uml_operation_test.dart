import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:client/model/uml/uml_operation_parameter.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:test/test.dart';

void main() {
  test('UMLOperation stringRepresentation', () {
    final umlModel = UMLModel();
    final book = UMLType(name: 'Book');
    umlModel.addType(book);

    final operation1 = UMLOperation(
      name: 'study',
      visibility: UMLVisibility.public,
      returnType: UMLDataType.voidType(),
      parameters: [
        UMLOperationParameter(name: 'subject', type: UMLDataType.string()),
        UMLOperationParameter(name: 'book', type: UMLDataType.type(book.id))
      ],
    );
    expect(operation1.stringRepresentation(umlModel),
        '+ study(subject: string, book: Book): void');

    final operation2 = UMLOperation(
      name: 'eat',
      visibility: UMLVisibility.protected,
      returnType: UMLDataType.boolean(),
    );
    expect(operation2.stringRepresentation(umlModel), '# eat(): boolean');
  });
}
