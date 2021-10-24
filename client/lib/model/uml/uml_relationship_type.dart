import 'package:client/extensions.dart';
import 'package:flutter/foundation.dart';

enum UMLRelationshipType {
  association,
  aggregation,
  composition,
  associationWithClass,
  qualifiedAssociation
}

extension UMLRelationshipTypeExt on UMLRelationshipType {
  static UMLRelationshipType fromString(String string) =>
      UMLRelationshipType.values
          .firstWhere((value) => describeEnum(value) == string);

  String get stringRepresentation {
    switch (this) {
      case UMLRelationshipType.associationWithClass:
        return 'Association with class';
      case UMLRelationshipType.qualifiedAssociation:
        return 'Qualified association';
      default:
        return describeEnum(this).capitalize();
    }
  }

  String get xmlRepresentation => describeEnum(this);
}
