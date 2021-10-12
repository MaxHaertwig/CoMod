import 'package:client/model/model.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

/// A UML element.
abstract class UMLElement {
  final String id;

  UMLElement(String? id) : id = id ?? Uuid().v4();

  /// Instructs the element to update its attributes, insert element, and delete elements. Returns the elements that were created as part of the update.
  List<UMLElement>? update(
      List<Tuple2<String, String>> attributes,
      List<Tuple2<String, int>> addedElements,
      List<Tuple2<String, String>> deletedElements) {}
}

typedef NameChangedFunction = void Function(String);

abstract class NamedUMLElement extends UMLElement
    implements Comparable<NamedUMLElement> {
  String _name = '';
  Model? get model;

  NameChangedFunction? onNameChanged;

  NamedUMLElement({String? id, name = ''})
      : _name = name,
        super(id);

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

  @override
  int compareTo(NamedUMLElement other) => _name.compareTo(other._name);
}
