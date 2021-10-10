import 'package:quiver/core.dart';

class UMLRelationshipMultiplicity {
  final int lower, upper;

  const UMLRelationshipMultiplicity(this.lower, this.upper);

  const UMLRelationshipMultiplicity.empty()
      : lower = -1,
        upper = -1;

  static UMLRelationshipMultiplicity parse(String string) {
    if (string == '') {
      return UMLRelationshipMultiplicity.empty();
    }
    if (!string.contains('..')) {
      final component = parseComponent(string);
      return component == -99
          ? UMLRelationshipMultiplicity(-1, component)
          : UMLRelationshipMultiplicity(component, -1);
    }
    final components = string.split('..');
    final lower = parseComponent(components[0]);
    final upper = parseComponent(components[1]);
    return lower == -1 && upper != -1
        ? UMLRelationshipMultiplicity(upper, -1)
        : UMLRelationshipMultiplicity(lower, upper);
  }

  static int parseComponent(String component) {
    switch (component) {
      case '':
        return -1;
      case '*':
        return -99;
      default:
        return int.parse(component);
    }
  }

  static String componentString(int component) {
    switch (component) {
      case -1:
        return '';
      case -99:
        return '*';
      default:
        return '$component';
    }
  }

  bool get isEmpty => lower == -1 && upper == -1;

  bool get isNotEmpty => lower != -1 || upper != -1;

  bool get isValid =>
      lower != -99 && (lower <= upper || upper == -1 || upper == -99);

  String get xmlRepresentation => lower == upper || upper == -1
      ? componentString(lower)
      : lower == -1
          ? componentString(upper)
          : componentString(lower) + '..' + componentString(upper);

  @override
  int get hashCode => hash2(lower, upper);

  @override
  bool operator ==(other) =>
      other is UMLRelationshipMultiplicity &&
      lower == other.lower &&
      upper == other.upper;
}
