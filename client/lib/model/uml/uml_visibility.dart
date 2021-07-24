import 'package:flutter/foundation.dart';

enum UMLVisibility { public, package, protected, private }

extension UMLVisibilityExt on UMLVisibility {
  static UMLVisibility fromString(String string) {
    return UMLVisibility.values
        .firstWhere((value) => describeEnum(value) == string);
  }
}
