import 'package:client/model/uml/uml_attribute.dart';
import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:test/test.dart';

void main() {
  test('UMLAttribute stringRepresentation', () {
    final attribute =
        UMLAttribute('name', UMLVisibility.private, UMLDataType.string());
    expect(attribute.stringRepresentation, '- name: string');
  });
}
