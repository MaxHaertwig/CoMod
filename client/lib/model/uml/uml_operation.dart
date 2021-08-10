import 'dart:collection';

import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:either_dart/either.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLOperation {
  static const xmlTag = 'operation';
  static const _nameTag = 'name';
  static const _visibilityAttribute = 'visibility';
  static const _returnTypeAttribute = 'returnType';

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

class UMLOperationParameter {
  static const xmlTag = 'param';

  final String id;
  String _name;
  UMLDataType _type;

  UMLOperationParameter({String? id, name = '', UMLDataType? type})
      : id = id ?? Uuid().v4(),
        _name = name,
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

  String get xmlRepresentation =>
      '<$xmlTag id="$id" type="${_type.xmlRepresentation}">' +
      _name +
      '</$xmlTag>';
}
