import 'dart:collection';

import 'package:client/extensions.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_element.dart';
import 'package:client/model/uml/uml_operation_parameter.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLOperation implements NamedUMLElement {
  static const xmlTag = 'operation';
  static const _idAttribute = 'id';
  static const _visibilityAttribute = 'visibility';
  static const _returnTypeAttribute = 'returnType';

  UMLType? _umlType;
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
    assert(element.name.toString() == xmlTag);
    return UMLOperation(
      id: element.getAttribute(_idAttribute)!,
      name: element.firstChild is XmlText
          ? (element.firstChild as XmlText).text.trim()
          : '',
      visibility: UMLVisibilityExt.fromString(
          element.getAttribute(_visibilityAttribute)!),
      returnType:
          UMLDataType.fromString(element.getAttribute(_returnTypeAttribute)!),
      parameters: element
          .findElements(UMLOperationParameter.xmlTag)
          .map((el) => UMLOperationParameter.fromXmlElement(el))
          .toList(),
    );
  }

  set umlType(UMLType umlType) {
    _umlType = umlType;
    _parameters.values.forEach((param) => param.operation = this);
  }

  Model? get model => _umlType?.model;

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
    model?.deleteElements([parameter.id]);
  }

  void moveParameter(UMLOperationParameter parameter, MoveType moveType) {
    _parameters.move(parameter.id, moveType);
    model?.moveElement(parameter.id, moveType);
  }

  void addToModel() =>
      model?.insertElement(this, _umlType!.id, 3, xmlTag, name, [
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
    final params =
        _parameters.values.map((param) => param.xmlRepresentation).join();
    return '<$xmlTag $_idAttribute="$id" $visibility $returnType>' +
        name +
        params +
        '</$xmlTag>';
  }

  void addToMapping(Map<String, UMLElement> mapping) {
    mapping[id] = this;
    _parameters.values.forEach((param) => mapping[param.id] = param);
  }

  @override
  List<UMLElement>? update(List<Tuple2<String, String>> attributes,
      List<Tuple2<String, int>> addedElements, List<String> deletedElements) {
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

    deletedElements.forEach((id) => _parameters.remove(id));

    final List<UMLElement> newElements = [];
    for (final tuple in addedElements) {
      final parameter = UMLOperationParameter.fromXml(tuple.item1);
      _parameters[parameter.id] = parameter;
      newElements.add(parameter);
    }
    return newElements;
  }
}
