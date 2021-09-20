import 'dart:collection';

import 'package:client/extensions.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_element.dart';
import 'package:client/model/uml/uml_operation_parameter.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLOperation implements NamedUMLElement {
  static const xmlTag = 'operation';
  static const _nameTag = 'name';
  static const _visibilityAttribute = 'visibility';
  static const _returnTypeAttribute = 'returnType';

  UMLClass? _umlClass;
  final String id;
  String _name;
  UMLVisibility _visibility;
  UMLDataType _returnType;
  LinkedHashMap<String, UMLOperationParameter> _parameters;

  UMLOperation(
      {String? id,
      name = '',
      visibility = UMLVisibility.public,
      UMLDataType? returnType,
      List<UMLOperationParameter>? parameters})
      : id = id ?? Uuid().v4(),
        _name = name,
        _visibility = visibility,
        _returnType = returnType ?? UMLDataType.voidType(),
        _parameters =
            LinkedHashMap.fromIterable(parameters ?? [], key: (p) => p.id);

  static UMLOperation fromXml(String xml) =>
      fromXmlElement(XmlDocument.parse(xml).rootElement);

  static UMLOperation fromXmlElement(XmlElement element) {
    assert(element.name.toString() == 'operation');
    return UMLOperation(
      name: element.children.first.text.trim(),
      visibility:
          UMLVisibilityExt.fromString(element.getAttribute('visibility')!),
      returnType: UMLDataType.fromString(element.getAttribute('returnType')!),
      parameters: element
          .findElements('param')
          .map((el) => UMLOperationParameter.fromXmlElement(el))
          .toList(),
    );
  }

  set umlClass(UMLClass umlClass) {
    _umlClass = umlClass;
    _parameters.values.forEach((param) => param.operation = this);
  }

  Model? get model => _umlClass?.model;

  String get name => _name;

  set name(String newName) {
    if (newName != _name) {
      final oldName = _name;
      _name = newName;
      model?.updateText(id, oldName, newName);
    }
  }

  UMLVisibility get visibility => _visibility;

  set visibility(UMLVisibility visibility) {
    if (visibility != _visibility) {
      _visibility = visibility;
      model?.updateAttribute(
          id, _visibilityAttribute, visibility.xmlRepresentation);
    }
  }

  UMLDataType get returnType => _returnType;

  set returnType(UMLDataType dataType) {
    if (dataType != returnType) {
      returnType = dataType;
      model?.updateAttribute(
          id, _returnTypeAttribute, dataType.xmlRepresentation);
    }
  }

  UnmodifiableMapView<String, UMLOperationParameter> get parameters =>
      UnmodifiableMapView(_parameters);

  void addParameter(UMLOperationParameter parameter) {
    parameter.operation = this;
    _parameters[parameter.id] = parameter;
    parameter.addToModel();
  }

  void removeParameter(UMLOperationParameter parameter) {
    _parameters.remove(parameter.id);
    model?.deleteElement(id);
  }

  void moveParameter(UMLOperationParameter parameter, MoveType moveType) {
    // TODO: replicate in yjs
    _parameters.move(parameter.id, moveType);
    model?.didChange();
  }

  void addToModel() =>
      model?.insertElement(this, _umlClass!.id, id, xmlTag, name, [
        Tuple2(_visibilityAttribute, visibility.xmlRepresentation),
        Tuple2(_returnTypeAttribute, returnType.xmlRepresentation)
      ]);

  String get stringRepresentation {
    final parameters = _parameters.values
        .map((param) => param.stringRepresentation)
        .join(', ');
    return '${_visibility.symbol} $_name($parameters): ${_returnType.stringRepresentation}';
  }

  String get xmlRepresentation {
    final visibility =
        '$_visibilityAttribute="${_visibility.xmlRepresentation}"';
    final returnType =
        '$_returnTypeAttribute="${_returnType.xmlRepresentation}"';
    final name = '<$_nameTag>' + _name + '</$_nameTag>';
    final params =
        _parameters.values.map((param) => param.xmlRepresentation).join();
    return '<$xmlTag id="$id" $visibility $returnType>' +
        name +
        params +
        '</$xmlTag>';
  }

  void addToMapping(Map<String, UMLElement> mapping) {
    mapping[id] = this;
    _parameters.values.forEach((param) => mapping[param.id] = param);
  }

  List<UMLElement>? update(List<Tuple2<String, String>> attributes,
      List<String> addedElements, List<String> deletedElements) {
    for (final tuple in attributes) {
      switch (tuple.item1) {
        case _visibilityAttribute:
          _visibility = UMLVisibilityExt.fromString(tuple.item2);
          break;
        case _returnTypeAttribute:
          _returnType = UMLDataType.fromString(tuple.item2);
          break;
      }
    }

    final List<UMLElement> newElements = [];
    for (final xml in addedElements) {
      final parameter = UMLOperationParameter.fromXml(xml);
      _parameters[parameter.id] = parameter;
      newElements.add(parameter);
    }

    deletedElements.forEach((id) => _parameters.remove(id));

    return newElements;
  }
}
