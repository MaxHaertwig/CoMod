import 'package:client/model/uml/uml_attribute.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:test/test.dart';

void main() {
  test('UMLClass hasInheritanceCycle', () {
    final umlModel = UMLModel();

    final class1 = UMLClass();
    umlModel.addClass(class1);
    expect(class1.hasInheritanceCycle(), false);

    final class2 = UMLClass(extendsClass: class1.id);
    umlModel.addClass(class2);
    class1.extendsClass = class2.id;
    [class1, class2].forEach((cls) => expect(cls.hasInheritanceCycle(), true));

    class1.extendsClass = '';
    final class3 = UMLClass(extendsClass: class2.id);
    umlModel.addClass(class3);
    [class1, class2, class3]
        .forEach((cls) => expect(cls.hasInheritanceCycle(), false));

    class1.extendsClass = class3.id;
    [class1, class2, class3]
        .forEach((cls) => expect(cls.hasInheritanceCycle(), true));
  });
}
