import 'package:flutter/foundation.dart';

enum UMLTypeType { classType, abstractClass, interface }

extension UMLTypeTypeExt on UMLTypeType {
  static UMLTypeType fromString(String string) => string == 'class'
      ? UMLTypeType.classType
      : UMLTypeType.values.firstWhere((value) => describeEnum(value) == string);

  String get xmlRepresentation =>
      this == UMLTypeType.classType ? 'class' : describeEnum(this);
}
