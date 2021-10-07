class UMLRelationshipMultiplicity {
  final int from, to;

  const UMLRelationshipMultiplicity(this.from, this.to);

  UMLRelationshipMultiplicity.empty()
      : from = -1,
        to = -1;

  static UMLRelationshipMultiplicity parse(String string) {
    if (string == '') {
      return UMLRelationshipMultiplicity.empty();
    }
    if (!string.contains('..')) {
      return UMLRelationshipMultiplicity(
          _parseMultiplicityComponent(string), -1);
    }
    final components = string.split('..');
    return UMLRelationshipMultiplicity(
        _parseMultiplicityComponent(components[0]),
        _parseMultiplicityComponent(components[1]));
  }

  static int _parseMultiplicityComponent(String component) {
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

  String get xmlRepresentation => from == to || to == -1
      ? componentString(from)
      : from == -1
          ? componentString(to)
          : componentString(from) + '..' + componentString(to);
}
