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

class UMLClass implements NamedUMLElement {
  static const xmlTag = 'class';
  static const _attributesTag = 'attributes';
  static const _operationsTag = 'operations';

  static const _idAttribute = 'id';
  static const _xAttribute = 'x';
  static const _yAttribute = 'y';
  static const _isAbstractAttribute = 'isAbstract';
  static const _extendsAttribute = 'extends';

  UMLModel? _umlModel;
  final String id;
  String _name;
  int _x, _y;
  bool _isAbstract;
  String _extendsClass;
  LinkedHashMap<String, UMLAttribute> _attributes;
  LinkedHashMap<String, UMLOperation> _operations;

  UMLClass(
      {String? id,
      name = '',
      x = 0,
      y = 0,
      isAbstract = false,
      extendsClass = '',
      List<UMLAttribute>? attributes,
      List<UMLOperation>? operations})
      : id = id ?? Uuid().v4(),
        _name = name,
        _x = x,
        _y = y,
        _isAbstract = isAbstract,
        _extendsClass = extendsClass,
        _attributes =
            LinkedHashMap.fromIterable(attributes ?? [], key: (a) => a.id),
        _operations =
            LinkedHashMap.fromIterable(operations ?? [], key: (op) => op.id);

  static UMLClass fromXml(String xml) =>
      fromXmlElement(XmlDocument.parse(xml).rootElement);

  static UMLClass fromXmlElement(XmlElement element) {
    assert(element.name.toString() == xmlTag);
    return UMLClass(
      name: element.firstChild is XmlText
          ? (element.firstChild as XmlText).text.trim()
          : '',
      id: element.getAttribute(_idAttribute)!,
      x: int.parse(element.getAttribute(_xAttribute) ?? '0'),
      y: int.parse(element.getAttribute(_yAttribute) ?? '0'),
      isAbstract: (element.getAttribute(_isAbstractAttribute) ?? '') == 'true',
      extendsClass: element.getAttribute(_extendsAttribute) ?? '',
      attributes: element
          .getElement(_attributesTag)!
          .findElements(UMLAttribute.xmlTag)
          .map((child) => UMLAttribute.fromXmlElement(child))
          .toList(),
      operations: element
          .getElement(_operationsTag)!
          .findElements(UMLOperation.xmlTag)
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

  bool get isAbstract => _isAbstract;

  set isAbstract(bool newValue) {
    if (newValue != _isAbstract) {
      _isAbstract = newValue;
      model?.updateAttribute(
          id, _isAbstractAttribute, _isAbstract ? 'true' : 'false');
    }
  }

  String get extendsClass => _extendsClass;

  set extendsClass(String newValue) {
    if (newValue != _extendsClass) {
      _extendsClass = newValue;
      model?.updateAttribute(id, _extendsAttribute, newValue);
    }
  }

  bool hasInheritanceCycle() {
    if (extendsClass == '') return false;

    final seen = {id};
    var cls = _umlModel!.classes[extendsClass];
    while (cls != null) {
      if (seen.contains(cls.id)) {
        return true;
      }
      seen.add(cls.id);
      if (cls.extendsClass == '') break;
      cls = _umlModel!.classes[cls.extendsClass];
    }

    return false;
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
    model?.deleteElement(attribute.id);
  }

  void moveAttribute(UMLAttribute attribute, MoveType moveType) {
    _attributes.move(attribute.id, moveType);
    model?.moveElement(attribute.id, moveType);
  }

  UnmodifiableMapView<String, UMLOperation> get operations =>
      UnmodifiableMapView(_operations);

  void addOperation(UMLOperation operation) {
    operation.umlClass = this;
    _operations[operation.id] = operation;
    operation.addToModel();
  }

  void removeOperation(UMLOperation operation) {
    _operations.remove(operation.id);
    model?.deleteElement(operation.id);
  }

  void moveOperation(UMLOperation operation, MoveType moveType) {
    _operations.move(operation.id, moveType);
    model?.moveElement(operation.id, moveType);
  }

  bool get isEmpty =>
      _name.isEmpty && _attributes.isEmpty && _operations.isEmpty;

  void addToModel() => model?.insertElement(this, model!.uuid, -1, xmlTag, name,
      null, [_attributesTag, _operationsTag]);

  String get xmlRepresentation {
    final isAbstract = _isAbstract ? 'true' : 'false';
    final attributes =
        _attributes.values.map((attr) => attr.xmlRepresentation).join();
    final operations =
        _operations.values.map((op) => op.xmlRepresentation).join();
    return '<$xmlTag $_idAttribute="$id" $_xAttribute="$_x" $_yAttribute="$_y" $_isAbstractAttribute="$isAbstract" $_extendsAttribute="$_extendsClass">' +
        name +
        '<$_attributesTag>$attributes</$_attributesTag>' +
        '<$_operationsTag>$operations</$_operationsTag>' +
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

  @override
  List<UMLElement>? update(List<Tuple2<String, String>> attributes,
      List<Tuple2<String, int>> addedElements, List<String> deletedElements) {
    for (final attribute in attributes) {
      switch (attribute.item1) {
        case _isAbstractAttribute:
          _isAbstract = attribute.item2 == 'true';
          break;
        case _extendsAttribute:
          _extendsClass = attribute.item2;
          break;
      }
    }

    for (final id in deletedElements) {
      if (_attributes.remove(id) == null) {
        _operations.remove(id);
      }
    }

    final List<UMLElement> newElements = [];
    for (final tuple in addedElements
      ..sort((a, b) => a.item2.compareTo(b.item2))) {
      if (tuple.item1.startsWith('<' + UMLAttribute.xmlTag)) {
        final attribute = UMLAttribute.fromXml(tuple.item1);
        _attributes.insertAt(attribute.id, attribute, tuple.item2);
        newElements.add(attribute);
      } else {
        final operation = UMLOperation.fromXml(tuple.item1);
        _operations.insertAt(operation.id, operation, tuple.item2);
        newElements.add(operation);
      }
    }
    return newElements;
  }
}
