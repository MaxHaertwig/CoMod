import 'package:client/model/uml/uml_type.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:test/test.dart';

void main() {
  test('UMLType hasInheritanceCycle', () {
    final umlModel = UMLModel();

    final type1 = UMLType();
    umlModel.addType(type1);
    expect(type1.hasInheritanceCycle(), false);

    final type2 = UMLType(extendsClass: type1.id);
    umlModel.addType(type2);
    type1.extendsClass = type2.id;
    [type1, type2].forEach((type) => expect(type.hasInheritanceCycle(), true));

    type1.extendsClass = '';
    final type3 = UMLType(extendsClass: type2.id);
    umlModel.addType(type3);
    [type1, type2, type3]
        .forEach((type) => expect(type.hasInheritanceCycle(), false));

    type1.extendsClass = type3.id;
    [type1, type2, type3]
        .forEach((type) => expect(type.hasInheritanceCycle(), true));
  });
}
