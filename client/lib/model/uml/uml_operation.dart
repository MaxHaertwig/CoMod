import 'dart:collection';

import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_operation_parameter.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLOperation {
  static const xmlTag = 'operation';
  static const _nameTag = 'name';
  static const _visibilityAttribute = 'visibility';
  static const _returnTypeAttribute = 'returnType';

  UMLClass? _umlClass;
  final String id;
  String _name;
  UMLVisibility _visibility;
  UMLDataType _returnType;
  List<UMLOperationParameter> _parameters;

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
        _parameters = parameters ?? [];

  static UMLOperation fromXml(XmlElement element) {
    assert(element.name.toString() == 'operation');
    return UMLOperation(
      name: element.getElement('name')!.innerText.trim(),
      visibility:
          UMLVisibilityExt.fromString(element.getAttribute('visibility')!),
      returnType: UMLDataType.fromString(element.getAttribute('returnType')!),
      parameters: element
          .findElements('param')
          .map((el) => UMLOperationParameter.fromXml(el))
          .toList(),
    );
  }

  set umlClass(UMLClass umlClass) {
    _umlClass = umlClass;
    _parameters.forEach((param) => param.operation = this);
  }

  Model? get model => _umlClass?.model;

  String get name => _name;

  UMLVisibility get visibility => _visibility;

  UMLDataType get returnType => _returnType;

  UnmodifiableListView<UMLOperationParameter> get parameters =>
      UnmodifiableListView(_parameters);

  String get stringRepresentation {
    final parameters =
        _parameters.map((arg) => arg.stringRepresentation).join(', ');
    return '${_visibility.symbol} $_name($parameters): ${_returnType.stringRepresentation}';
  }

  String get xmlRepresentation {
    final visibility =
        '$_visibilityAttribute="${_visibility.xmlRepresentation}"';
    final returnType =
        '$_returnTypeAttribute="${_returnType.xmlRepresentation}"';
    final name = '<$_nameTag>' + _name + '</$_nameTag>';
    final params = _parameters.map((param) => param.xmlRepresentation).join();
    return '<$xmlTag id="$id" $visibility $returnType>' +
        name +
        params +
        '</$xmlTag>';
  }
}
