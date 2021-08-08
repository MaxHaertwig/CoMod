import 'package:flutter/foundation.dart';

enum UMLVisibility { public, package, protected, private }

extension UMLVisibilityExt on UMLVisibility {
  static UMLVisibility fromString(String string) =>
      UMLVisibility.values.firstWhere((value) => describeEnum(value) == string);

  String get stringRepresentation {
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

  String get longStringRepresentation =>
      stringRepresentation + ' ' + describeEnum(this);

  String get xmlRepresentation => describeEnum(this);
}
