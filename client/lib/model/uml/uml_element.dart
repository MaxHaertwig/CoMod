import 'package:tuple/tuple.dart';

/// A UML element.
abstract class UMLElement {
  String get id => '';

  /// Instructs the element to update its attributes, insert element, and delete elements. Returns the elements that were created as part of the update.
  List<UMLElement>? update(List<Tuple2<String, String>> attributes,
      List<String> addedElements, List<String> deletedElements) {}
}

/// A UMLElement with a name.
abstract class NamedUMLElement extends UMLElement {
  String get name => '';
  set name(String newName) {}
}
