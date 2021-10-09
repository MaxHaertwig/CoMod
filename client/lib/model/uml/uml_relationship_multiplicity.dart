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
      return UMLRelationshipMultiplicity(parseComponent(string), -1);
    }
    final components = string.split('..');
    return UMLRelationshipMultiplicity(
        parseComponent(components[0]), parseComponent(components[1]));
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
}
