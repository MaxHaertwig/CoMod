import 'package:flutter/foundation.dart';

enum UMLVisibility { public, package, protected, private }

extension UMLVisibilityExt on UMLVisibility {
  static UMLVisibility fromString(String string) =>
      UMLVisibility.values.firstWhere((value) => describeEnum(value) == string);

  String get symbol {
    switch (this) {
      case UMLVisibility.public:
        return '+';
      case UMLVisibility.package:
        return '~';
      case UMLVisibility.protected:
        return '#';
      case UMLVisibility.private:
        return '-';
    }
  }

  String get stringRepresentation => symbol + ' ' + describeEnum(this);

  String get xmlRepresentation => describeEnum(this);
}
