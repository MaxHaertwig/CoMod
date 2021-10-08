class UMLRelationshipMultiplicity {
  int lower, upper;

  UMLRelationshipMultiplicity(this.lower, this.upper);

  UMLRelationshipMultiplicity.empty()
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

  String get xmlRepresentation => lower == upper || upper == -1
      ? componentString(lower)
      : lower == -1
          ? componentString(upper)
          : componentString(lower) + '..' + componentString(upper);
}
