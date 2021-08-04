import 'dart:collection';

import 'package:client/model/uml/uml_attribute.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLClass {
  final String id;
  String _name;
  int _x, _y;
  List<UMLAttribute> _attributes;
  List<UMLOperation> _operations;

  UMLClass(
      {String? id,
      name = '',
      x = 0,
      y = 0,
      List<UMLAttribute>? attributes,
      List<UMLOperation>? operations})
      : id = id ?? Uuid().v4(),
        _name = name,
        _x = x,
        _y = y,
        _attributes = attributes ?? [],
        _operations = operations ?? [];

  static UMLClass fromXml(XmlElement element) {
    assert(element.name.toString() == 'class');
    return UMLClass(
      name: element.getElement('name')!.innerText.trim(),
      id: element.getAttribute('id')!,
      x: int.parse(element.getAttribute('x')!),
      y: int.parse(element.getAttribute('y')!),
      attributes: element
          .findElements('attribute')
          .map((child) => UMLAttribute.fromXml(child))
          .toList(),
      operations: element
          .findElements('operation')
          .map((child) => UMLOperation.fromXml(child))
          .toList(),
    );
  }

  bool get isEmpty =>
      _name.isEmpty && _attributes.isEmpty && _operations.isEmpty;

  String get name => _name;
  void set name(String newName) => _name = newName;

  UnmodifiableListView<UMLAttribute> get attributes =>
      UnmodifiableListView(_attributes);
  addAttribute(UMLAttribute attribute) => _attributes.add(attribute);
  removeAttribute(UMLAttribute attribute) => _attributes.remove(attribute);

  UnmodifiableListView<UMLOperation> get operations =>
      UnmodifiableListView(_operations);
}
