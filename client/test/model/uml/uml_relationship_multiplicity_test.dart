import 'package:client/model/uml/uml_relationship_multiplicity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UMLRelationshipMultiplicity isEmpty', () {
    expect(UMLRelationshipMultiplicity.empty().isEmpty, true);
    expect(UMLRelationshipMultiplicity(1, 1).isEmpty, false);
  });

  test('UMLRelationshipMultiplicity isValid', () {
    expect(UMLRelationshipMultiplicity.empty().isValid, true);
    expect(UMLRelationshipMultiplicity(-1, -99).isValid, true);
    expect(UMLRelationshipMultiplicity(1, -1).isValid, true);
    expect(UMLRelationshipMultiplicity(1, 1).isValid, true);
    expect(UMLRelationshipMultiplicity(1, 2).isValid, true);
    expect(UMLRelationshipMultiplicity(-99, -1).isValid, false);
    expect(UMLRelationshipMultiplicity(2, 1).isValid, false);
  });

  test('UMLRelationshipMultiplicity xmlRepresentation', () {
    expect(UMLRelationshipMultiplicity.empty().xmlRepresentation, '');
    expect(UMLRelationshipMultiplicity(1, -1).xmlRepresentation, '1');
    expect(UMLRelationshipMultiplicity(-1, 1).xmlRepresentation, '1');
    expect(UMLRelationshipMultiplicity(1, 1).xmlRepresentation, '1');
    expect(UMLRelationshipMultiplicity(1, 2).xmlRepresentation, '1..2');
    expect(UMLRelationshipMultiplicity(1, -99).xmlRepresentation, '1..*');
    expect(UMLRelationshipMultiplicity(-99, -1).xmlRepresentation, '*');
    expect(UMLRelationshipMultiplicity(-99, -99).xmlRepresentation, '*');
  });
}
