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

typedef NameChangedFunction = void Function(String);

abstract class NamedUMLElement extends UMLElement {
  String _name = '';
  Model? get model;

  NameChangedFunction? onNameChanged;

  NamedUMLElement([name = '']) : _name = name;

  String get name => _name;

  set name(String newName) {
    // Called when name changes remotely
    if (newName != _name) {
      _name = newName;
      if (onNameChanged != null) {
        onNameChanged!(newName);
      }
    }
  }

  void updateName(
      String newName, int position, int deleteLength, String insertString) {
    if (newName != _name) {
      _name = newName;
      model?.updateText(id, position, deleteLength, insertString);
    }
  }
}
