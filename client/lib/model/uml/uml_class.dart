import 'dart:collection';

import 'package:client/extensions.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_attribute.dart';
import 'package:client/model/uml/uml_element.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:collection/collection.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLClass implements UMLElement {
  static const xmlTag = 'class';
  static const _nameTag = 'name';

  UMLModel? _umlModel;
  final String id;
  String _name;
  int _x, _y;
  LinkedHashMap<String, UMLAttribute> _attributes;
  LinkedHashMap<String, UMLOperation> _operations;

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
        _operations =
            LinkedHashMap.fromIterable(operations ?? [], key: (op) => op.id);

  static UMLClass fromXml(String xml) =>
      fromXmlElement(XmlDocument.parse(xml).rootElement);

  static UMLClass fromXmlElement(XmlElement element) {
    assert(element.name.toString() == 'class');
    return UMLClass(
      name: element.children.first.text.trim(),
      id: element.getAttribute('id')!,
      x: int.parse(element.getAttribute('x') ?? '0'),
      y: int.parse(element.getAttribute('y') ?? '0'),
      attributes: element
          .findElements('attribute')
          .map((child) => UMLAttribute.fromXmlElement(child))
          .toList(),
      operations: element
          .findElements('operation')
          .map((child) => UMLOperation.fromXmlElement(child))
          .toList(),
    );
  }

  set umlModel(UMLModel? umlModel) {
    _umlModel = umlModel;
    _attributes.values.forEach((attribute) => attribute.umlClass = this);
    _operations.values.forEach((op) => op.umlClass = this);
  }

  Model? get model => _umlModel?.model;

  String get name => _name;

  set name(String newName) {
    if (newName != _name) {
      final oldName = _name;
      _name = newName;
      model?.updateText(id, oldName, newName);
    }
  }

  UnmodifiableMapView<String, UMLAttribute> get attributes =>
      UnmodifiableMapView(_attributes);

  void addAttribute(UMLAttribute attribute) {
    attribute.umlClass = this;
    _attributes[attribute.id] = attribute;
    attribute.addToModel();
  }

  void removeAttribute(UMLAttribute attribute) {
    _attributes.remove(attribute.id);
    model?.deleteElement(id);
  }

  void moveAttribute(UMLAttribute attribute, MoveType moveType) {
    // TODO: replicate in yjs
    _attributes.move(attribute.id, moveType);
    model?.didChange();
  }

  UnmodifiableMapView<String, UMLOperation> get operations =>
      UnmodifiableMapView(_operations);

  bool get isEmpty =>
      _name.isEmpty && _attributes.isEmpty && _operations.isEmpty;

  void addToModel() =>
      model?.insertElement(this, model!.uuid, id, xmlTag, name, null);

  String get xmlRepresentation {
    final name = '<$_nameTag>' + _name + '</$_nameTag>';
    final attributes =
        _attributes.values.map((attr) => attr.xmlRepresentation).join();
    final operations =
        _operations.values.map((op) => op.xmlRepresentation).join();
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
        _operations.values.map((op) => op.stringRepresentation).join(', ');
    return '$name[$attributes | $operations]';
  }

  void addToMapping(Map<String, UMLElement> mapping) {
    mapping[id] = this;
    _attributes.values.forEach((a) => mapping[a.id] = a);
    _operations.values.forEach((op) => op.addToMapping(mapping));
  }

  List<UMLElement>? update(List<Tuple2<String, String>> attributes,
      List<String> addedElements, List<String> deletedElements) {
    final List<UMLElement> newElements = [];
    for (final xml in addedElements) {
      final attribute = UMLAttribute.fromXml(xml);
      _attributes[attribute.id] = attribute;
      newElements.add(attribute);
    }
    deletedElements.forEach((id) {
      _attributes.remove(id);
      _operations.remove(id);
    });
    return newElements;
  }
}
