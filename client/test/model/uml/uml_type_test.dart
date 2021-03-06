import 'package:client/model/uml/uml_type.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_type_type.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

void main() {
  test('UMLType inheritanceRelationTo', () {
    final tests = [
      Tuple3(UMLTypeType.abstractClass, UMLTypeType.abstractClass,
          InheritanceType.generalization),
      Tuple3(UMLTypeType.abstractClass, UMLTypeType.classType,
          InheritanceType.generalization),
      Tuple3(UMLTypeType.abstractClass, UMLTypeType.interface,
          InheritanceType.realization),
      Tuple3(UMLTypeType.classType, UMLTypeType.abstractClass,
          InheritanceType.generalization),
      Tuple3(UMLTypeType.classType, UMLTypeType.classType,
          InheritanceType.generalization),
      Tuple3(UMLTypeType.classType, UMLTypeType.interface,
          InheritanceType.realization),
      Tuple3(UMLTypeType.interface, UMLTypeType.abstractClass, null),
      Tuple3(UMLTypeType.interface, UMLTypeType.classType, null),
      Tuple3(UMLTypeType.interface, UMLTypeType.interface,
          InheritanceType.generalization),
    ];
    final umlModel = UMLModel();
    for (final test in tests) {
      final type = UMLType(type: test.item1);
      umlModel.addType(type);
      final supertype = UMLType(type: test.item2);
      umlModel.addType(supertype);
      type.addSupertype(supertype.id);
      expect(type.inheritanceRelationTo(supertype), test.item3);
    }
  });

  test('UMLType hasInheritanceCycle', () {
    final umlModel = UMLModel();

    final type1 = UMLType();
    umlModel.addType(type1);
    expect(type1.hasInheritanceCycle(), false);

    final type2 = UMLType();
    type2.addSupertype(type1.id);
    umlModel.addType(type2);
    type1.addSupertype(type2.id);
    [type1, type2].forEach((type) => expect(type.hasInheritanceCycle(), true));

    type1.removeSupertype(type2.id);
    final type3 = UMLType();
    type3.addSupertype(type2.id);
    umlModel.addType(type3);
    [type1, type2, type3]
        .forEach((type) => expect(type.hasInheritanceCycle(), false));

    type1.addSupertype(type3.id);
    [type1, type2, type3]
        .forEach((type) => expect(type.hasInheritanceCycle(), true));
  });

  test('UMLType supertypesLabel', () {
    final umlModel = UMLModel();

    final type = UMLType();
    umlModel.addType(type);
    expect(type.supertypesLabel, 'None');

    final superclass1 = UMLType(name: 'SC1');
    umlModel.addType(superclass1);
    type.addSupertype(superclass1.id);
    expect(type.supertypesLabel, 'Extends: SC1');

    final superclass2 = UMLType(name: 'SC2');
    umlModel.addType(superclass2);
    type.addSupertype(superclass2.id);

    final interface = UMLType(name: 'I', type: UMLTypeType.interface);
    umlModel.addType(interface);
    type.addSupertype(interface.id);

    expect(type.supertypesLabel, 'Extends: SC1, SC2\nImplements: I');

    // Interfaces can't extend classes
    type.type = UMLTypeType.interface;
    expect(type.supertypesLabel, 'Implements: I');

    type.type = UMLTypeType.abstractClass;
    type.removeSupertype(superclass1.id);
    type.removeSupertype(superclass2.id);

    expect(type.supertypesLabel, 'Implements: I');
  });
}
