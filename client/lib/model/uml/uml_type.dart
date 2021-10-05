import 'dart:collection';

import 'package:client/extensions.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_attribute.dart';
import 'package:client/model/uml/uml_element.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:client/model/uml/uml_supertype.dart';
import 'package:client/model/uml/uml_type_type.dart';
import 'package:collection/collection.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

enum InheritanceType { generalization, realization }

class UMLType implements NamedUMLElement {
  static const xmlTag = 'type';

  static const _supertypesTag = 'supertypes';
  static const _attributesTag = 'attributes';
  static const _operationsTag = 'operations';

  static const _idAttribute = 'id';
  static const _xAttribute = 'x';
  static const _yAttribute = 'y';
  static const _typeAttribute = 'type';

  UMLModel? _umlModel;
  final String id;
  String _name;
  int _x, _y;
  UMLTypeType _type;
  Map<String, List<String>> _supertypes =
      {}; // superID -> ids (a supertype might be present multiple times due to concurrent edits)
  LinkedHashMap<String, UMLAttribute> _attributes;
  LinkedHashMap<String, UMLOperation> _operations;

  UMLType(
      {String? id,
      name = '',
      x = 0,
      y = 0,
      type = UMLTypeType.classType,
      Map<String, List<String>>? supertypes,
      List<UMLAttribute>? attributes,
      List<UMLOperation>? operations})
      : id = id ?? Uuid().v4(),
        _name = name,
        _x = x,
        _y = y,
        _type = type,
        _supertypes = supertypes ?? {},
        _attributes =
            LinkedHashMap.fromIterable(attributes ?? [], key: (a) => a.id),
        _operations =
            LinkedHashMap.fromIterable(operations ?? [], key: (op) => op.id);

  static UMLType fromXml(String xml) =>
      fromXmlElement(XmlDocument.parse(xml).rootElement);

  static UMLType fromXmlElement(XmlElement element) {
    assert(element.name.toString() == xmlTag);
    final supertypes = Map<String, List<String>>();
    for (final supertypeElement
        in element.getElement(_supertypesTag)!.findElements('supertype')) {
      final supertype = UMLSupertype.fromXmlElement(supertypeElement);
      if (supertypes.containsKey(supertype.superID)) {
        supertypes[supertype.superID]!.add(supertype.id);
      } else {
        supertypes[supertype.superID] = [supertype.id];
      }
    }
    return UMLType(
      name: element.firstChild is XmlText
          ? (element.firstChild as XmlText).text.trim()
          : '',
      id: element.getAttribute(_idAttribute)!,
      x: int.parse(element.getAttribute(_xAttribute) ?? '0'),
      y: int.parse(element.getAttribute(_yAttribute) ?? '0'),
      type: UMLTypeTypeExt.fromString(element.getAttribute(_typeAttribute)!),
      supertypes: supertypes,
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
    _attributes.values.forEach((attribute) => attribute.umlType = this);
    _operations.values.forEach((op) => op.umlType = this);
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

  UMLTypeType get type => _type;

  set type(UMLTypeType newType) {
    if (newType != _type) {
      _type = newType;
      model?.updateAttribute(id, _typeAttribute, _type.xmlRepresentation);
    }
  }

  List<String> get supertypes => _supertypes.keys.toList();

  void addSupertype(String superID, [bool force = false]) {
    if (!_supertypes.containsKey(superID) || force) {
      _supertypes[superID] = [Uuid().v4()];
      final supertype = UMLSupertype(superID: superID)..umlType = this;
      supertype.addToModel();
    }
  }

  void removeSupertype(String superID) {
    final ids = _supertypes.remove(superID);
    if (ids != null) {
      model?.deleteElements(ids);
    }
  }

  InheritanceType? inheritanceRelationTo(UMLType supertype) {
    if (_supertypes.keys.contains(supertype.id) &&
        !(type == UMLTypeType.interface &&
            supertype.type != UMLTypeType.interface)) {
      return (type == UMLTypeType.interface) ==
              (supertype.type == UMLTypeType.interface)
          ? InheritanceType.generalization
          : InheritanceType.realization;
    }
    return null;
  }

  bool hasInheritanceCycle() {
    final queue = supertypes;
    while (queue.isNotEmpty) {
      final last = queue.removeLast();
      if (last == id) {
        return true;
      }
      final type = _umlModel!.types[last];
      if (type != null) {
        queue.addAll(type.supertypes);
      }
    }

    return false;
  }

  UnmodifiableMapView<String, UMLAttribute> get attributes =>
      UnmodifiableMapView(_attributes);

  void addAttribute(UMLAttribute attribute) {
    attribute.umlType = this;
    _attributes[attribute.id] = attribute;
    attribute.addToModel();
  }

  void removeAttribute(UMLAttribute attribute) {
    _attributes.remove(attribute.id);
    model?.deleteElements([attribute.id]);
  }

  void moveAttribute(UMLAttribute attribute, MoveType moveType) {
    _attributes.move(attribute.id, moveType);
    model?.moveElement(attribute.id, moveType);
  }

  UnmodifiableMapView<String, UMLOperation> get operations =>
      UnmodifiableMapView(_operations);

  void addOperation(UMLOperation operation) {
    operation.umlType = this;
    _operations[operation.id] = operation;
    operation.addToModel();
  }

  void removeOperation(UMLOperation operation) {
    _operations.remove(operation.id);
    model?.deleteElements([operation.id]);
  }

  void moveOperation(UMLOperation operation, MoveType moveType) {
    _operations.move(operation.id, moveType);
    model?.moveElement(operation.id, moveType);
  }

  bool get isEmpty =>
      _name.isEmpty && _attributes.isEmpty && _operations.isEmpty;

  void addToModel() => model?.insertElement(
      this,
      model!.uuid,
      -1,
      xmlTag,
      name,
      [Tuple2(_typeAttribute, _type.xmlRepresentation)],
      [_supertypesTag, _attributesTag, _operationsTag]);

  String get xmlRepresentation {
    final supertypes = _supertypes.entries
        .expand((entry) => entry.value.map(
            (id) => UMLSupertype(id: id, superID: entry.key).xmlRepresentation))
        .join('');
    final attributes =
        _attributes.values.map((attr) => attr.xmlRepresentation).join();
    final operations =
        _operations.values.map((op) => op.xmlRepresentation).join();
    return '<$xmlTag $_idAttribute="$id" $_xAttribute="$_x" $_yAttribute="$_y" $_typeAttribute="${_type.xmlRepresentation}">' +
        name +
        '<$_supertypesTag>$supertypes</$_supertypesTag>' +
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
    for (final tuple in attributes) {
      if (tuple.item1 == _typeAttribute) {
        _type = UMLTypeTypeExt.fromString(tuple.item2);
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