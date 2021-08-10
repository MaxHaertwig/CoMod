import 'dart:collection';

import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:either_dart/either.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLOperation {
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

  static const _xmlTag = 'operation';
  static const _nameTag = 'name';
  String get xmlRepresentation {
    final visibility = 'visibility="${_visibility.xmlRepresentation}"';
    final returnType = 'returnType="${_returnType.xmlRepresentation}"';
    final name = '<$_nameTag>' + _name + '</$_nameTag>';
    final params = _parameters.map((param) => param.xmlRepresentation).join();
    return '<$_xmlTag id="$id" $visibility $returnType>' +
        name +
        params +
        '</$_xmlTag>';
  }
}

class UMLOperationParameter {
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

  static const _xmlTag = 'param';
  String get xmlRepresentation =>
      '<$_xmlTag id="$id" type="${_type.xmlRepresentation}">' +
      _name +
      '</$_xmlTag>';
}
