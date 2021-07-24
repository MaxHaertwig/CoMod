import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:either_dart/either.dart';
import 'package:xml/xml.dart';

class UMLOperation {
  String name;
  UMLVisibility visibility;
  UMLDataType returnType;
  List<UMLOperationParameter> parameters = [];

  UMLOperation(this.name,
      [UMLVisibility? visibility,
      UMLDataType? returnType,
      List<UMLOperationParameter>? parameters])
      : visibility = visibility ?? UMLVisibility.public,
        returnType = returnType ?? UMLDataType.voidType(),
        parameters = parameters ?? [];

  static UMLOperation fromXml(XmlElement element) {
    assert(element.name.toString() == 'operation');

    final name = element.getElement('name')!.innerText.trim();
    final visibility =
        UMLVisibilityExt.fromString(element.getAttribute('visibility')!);
    final returnType =
        UMLDataType.fromString(element.getAttribute('returnType')!);
    final parameters = element
        .findElements('param')
        .map((el) => UMLOperationParameter.fromXml(el))
        .toList();
    return UMLOperation(name, visibility, returnType, parameters);
  }

  String get stringRepresentation =>
      '${visibility.stringRepresentation} $name(${parameters.map((arg) => arg.stringRepresentation).join(', ')}): ${returnType.stringRepresentation}';
}

class UMLOperationParameter {
  String name;
  UMLDataType type;

  UMLOperationParameter(this.name, UMLDataType? type)
      : type = type ?? UMLDataType(Left(UMLPrimitiveType.string));

  static UMLOperationParameter fromXml(XmlElement element) {
    assert(element.name.toString() == 'param');

    final dataType = UMLDataType.fromString(element.getAttribute('type')!);
    return UMLOperationParameter(element.innerText.trim(), dataType);
  }

  String get stringRepresentation => '$name: ${type.stringRepresentation}';
}
