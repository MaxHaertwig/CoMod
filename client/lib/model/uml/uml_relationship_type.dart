import 'package:client/extensions.dart';
import 'package:flutter/foundation.dart';

enum UMLRelationshipType {
  association,
  associationWithClass,
  aggregation,
  composition
}

extension UMLRelationshipTypeExt on UMLRelationshipType {
  static UMLRelationshipType fromString(String string) =>
      UMLRelationshipType.values
          .firstWhere((value) => describeEnum(value) == string);

  String get stringRepresentation =>
      this == UMLRelationshipType.associationWithClass
          ? 'Association with class'
          : describeEnum(this).capitalize();

  String get xmlRepresentation => describeEnum(this);
}
