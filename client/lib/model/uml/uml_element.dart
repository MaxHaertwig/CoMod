import 'package:client/model/model.dart';
import 'package:tuple/tuple.dart';

/// A UML element.
abstract class UMLElement {
  String get id => '';

  /// Instructs the element to update its attributes, insert element, and delete elements. Returns the elements that were created as part of the update.
  List<UMLElement>? update(
      List<Tuple2<String, String>> attributes,
      List<Tuple2<String, int>> addedElements,
      List<Tuple2<String, String>> deletedElements) {}
}

/// A UMLElement with a name.
abstract class NamedUMLElement extends UMLElement {
  String name = '';
  Model? get model;

  void updateName(
      String newName, int position, int deleteLength, String insertString) {
    if (newName != name) {
      name = newName;
      model?.updateText(id, position, deleteLength, insertString);
    }
  }
}
