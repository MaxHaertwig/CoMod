import 'dart:collection';

import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:either_dart/either.dart';
import 'package:xml/xml.dart';

class UMLOperation {
  String _name;
  UMLVisibility _visibility;
  UMLDataType _returnType;
  List<UMLOperationParameter> _parameters;

  UMLOperation(
      {name = '',
      visibility = UMLVisibility.public,
      UMLDataType? returnType,
      List<UMLOperationParameter>? parameters})
      : _name = name,
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

  String get name => _name;

  UMLVisibility get visibility => _visibility;

  UMLDataType get returnType => _returnType;

  UnmodifiableListView<UMLOperationParameter> get parameters =>
      UnmodifiableListView(_parameters);

  String get stringRepresentation =>
      '${_visibility.stringRepresentation} $_name(${_parameters.map((arg) => arg.stringRepresentation).join(', ')}): ${_returnType.stringRepresentation}';
}

class UMLOperationParameter {
  String _name;
  UMLDataType _type;

  UMLOperationParameter({name = '', UMLDataType? type})
      : _name = name,
        _type = type ?? UMLDataType(Left(UMLPrimitiveType.string));

  static UMLOperationParameter fromXml(XmlElement element) {
    assert(element.name.toString() == 'param');
    return UMLOperationParameter(
      name: element.innerText.trim(),
      type: UMLDataType.fromString(element.getAttribute('type')!),
    );
  }

  String get name => _name;

  UMLDataType get type => _type;

  String get stringRepresentation => '$_name: ${_type.stringRepresentation}';
}
