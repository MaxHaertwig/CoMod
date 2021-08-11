import 'dart:collection';

import 'package:client/extensions.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_attribute.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLClass {
  static const xmlTag = 'class';
  static const _nameTag = 'name';

  UMLModel? _umlModel = null;
  final String id;
  String _name;
  int _x, _y;
  LinkedHashMap<String, UMLAttribute> _attributes;
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
        _attributes =
            LinkedHashMap.fromIterable(attributes ?? [], key: (a) => a.id),
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

  set umlModel(UMLModel? umlModel) {
    _umlModel = umlModel;
    _attributes.values.forEach((attribute) => attribute.umlClass = this);
    _operations.forEach((op) => op.umlClass = this);
  }

  Model? get model => _umlModel?.model;

  String get name => _name;

  void set name(String newName) {
    if (newName != _name) {
      model?.jsBridge?.updateText(id, _name, newName);
      _name = newName;
      model?.didChange();
    }
  }

  UnmodifiableMapView<String, UMLAttribute> get attributes =>
      UnmodifiableMapView(_attributes);

  void addAttribute(UMLAttribute attribute) {
    attribute.umlClass = this;
    _attributes[attribute.id] = attribute;
    model?.jsBridge?.insertElement(id, attribute.id, UMLAttribute.xmlTag);
    model?.didChange();
  }

  void removeAttribute(UMLAttribute attribute) {
    _attributes.remove(attribute.id);
    model?.jsBridge?.deleteElement(id);
    model?.didChange();
  }

  void moveAttribute(UMLAttribute attribute, MoveType moveType) {
    _attributes.move(attribute.id, moveType);
    model?.didChange();
  }

  UnmodifiableListView<UMLOperation> get operations =>
      UnmodifiableListView(_operations);

  bool get isEmpty =>
      _name.isEmpty && _attributes.isEmpty && _operations.isEmpty;

  String get xmlRepresentation {
    final name = '<$_nameTag>' + _name + '</$_nameTag>';
    final attributes =
        _attributes.values.map((attr) => attr.xmlRepresentation).join();
    final operations = _operations.map((op) => op.xmlRepresentation).join();
    return '<$xmlTag id="$id" x="$_x" y="$_y">' +
        name +
        attributes +
        operations +
        '</$xmlTag>';
  }

  @override
  String toString() {
    final name = _name.isEmpty ? '<name>' : _name;
    final attributes =
        _attributes.values.map((a) => a.stringRepresentation).join(', ');
    final operations =
        _operations.map((op) => op.stringRepresentation).join(', ');
    return '$name[$attributes | $operations]';
  }
}
