import 'dart:collection';

import 'package:client/extensions.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_element.dart';
import 'package:client/model/uml/uml_operation_parameter.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:tuple/tuple.dart';
import 'package:xml/xml.dart';

class UMLOperation extends NamedUMLElement {
  static const xmlTag = 'operation';
  static const _idAttribute = 'id';
  static const _visibilityAttribute = 'visibility';
  static const _returnTypeAttribute = 'returnType';

  UMLType? _umlType;
  UMLVisibility _visibility;
  UMLDataType _returnType;
  LinkedHashMap<String, UMLOperationParameter> _parameters;

  UMLOperation(
      {String? id,
      name = '',
      visibility = UMLVisibility.public,
      UMLDataType? returnType,
      List<UMLOperationParameter>? parameters})
      : _visibility = visibility,
        _returnType = returnType ?? UMLDataType.voidType(),
        _parameters =
            LinkedHashMap.fromIterable(parameters ?? [], key: (p) => p.id),
        super(id: id, name: name);

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
    if (dataType != _returnType) {
      _returnType = dataType;
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

  String stringRepresentation(UMLModel umlModel) =>
      '${_visibility.symbol} $name(${_parameters.values.map((param) => param.stringRepresentation(umlModel)).join(', ')}): ${_returnType.stringRepresentation(umlModel)}';

  void addToMapping(Map<String, UMLElement> mapping) {
    mapping[id] = this;
    _parameters.values.forEach((param) => mapping[param.id] = param);
  }

  @override
  String toString() =>
      '${_visibility.symbol} $name(${_parameters.values.map((param) => param.toString()).join(', ')}): $_returnType';

  @override
  List<UMLElement>? update(
      List<Tuple2<String, String>> attributes,
      List<Tuple2<String, int>> addedElements,
      List<Tuple2<String, String>> deletedElements) {
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

    deletedElements.forEach((tuple) => _parameters.remove(tuple.item1));

    return (addedElements..sort((a, b) => a.item2.compareTo(b.item2)))
        .map((tuple) {
      final parameter = UMLOperationParameter.fromXml(tuple.item1);
      _parameters[parameter.id] = parameter;
      return parameter;
    }).toList();
  }
}
