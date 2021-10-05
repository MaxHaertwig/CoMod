import 'package:flutter/foundation.dart';

enum UMLTypeType { classType, abstractClass, interface }

extension UMLTypeTypeExt on UMLTypeType {
  static UMLTypeType fromString(String string) => string == 'class'
      ? UMLTypeType.classType
      : UMLTypeType.values.firstWhere((value) => describeEnum(value) == string);

  String get stringRepresentation {
    switch (this) {
      case UMLTypeType.abstractClass:
        return 'Abstract Class';
      case UMLTypeType.classType:
        return 'Class';
      case UMLTypeType.interface:
        return 'Interface';
    }
  }

  String get xmlRepresentation =>
      this == UMLTypeType.classType ? 'class' : describeEnum(this);
}
