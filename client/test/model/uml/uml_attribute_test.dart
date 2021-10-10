import 'package:client/model/uml/uml_attribute.dart';
import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:test/test.dart';

void main() {
  test('UMLAttribute stringRepresentation', () {
    final attribute = UMLAttribute(
      name: 'name',
      visibility: UMLVisibility.private,
      dataType: UMLDataType.string(),
    );
    expect(attribute.stringRepresentation(UMLModel()), '- name: string');
  });
}
