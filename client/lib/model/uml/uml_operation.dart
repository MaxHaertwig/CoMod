import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:either_dart/either.dart';
import 'package:xml/xml.dart';

class UMLOperation {
  String name;
  UMLVisibility visibility;
  UMLDataType returnType;
  List<UMLOperationParameter> parameters;

  UMLOperation(this.name,
      {this.visibility = UMLVisibility.public,
      UMLDataType? returnType,
      List<UMLOperationParameter>? parameters})
      : returnType = returnType ?? UMLDataType.voidType(),
        parameters = parameters ?? [];

  static UMLOperation fromXml(XmlElement element) {
    assert(element.name.toString() == 'operation');

    return UMLOperation(element.getElement('name')!.innerText.trim(),
        visibility:
            UMLVisibilityExt.fromString(element.getAttribute('visibility')!),
        returnType: UMLDataType.fromString(element.getAttribute('returnType')!),
        parameters: element
            .findElements('param')
            .map((el) => UMLOperationParameter.fromXml(el))
            .toList());
  }

  String get stringRepresentation =>
      '${visibility.stringRepresentation} $name(${parameters.map((arg) => arg.stringRepresentation).join(', ')}): ${returnType.stringRepresentation}';
}

class UMLOperationParameter {
  String name;
  UMLDataType type;

  UMLOperationParameter(this.name, {UMLDataType? type})
      : type = type ?? UMLDataType(Left(UMLPrimitiveType.string));

  static UMLOperationParameter fromXml(XmlElement element) {
    assert(element.name.toString() == 'param');

    return UMLOperationParameter(element.innerText.trim(),
        type: UMLDataType.fromString(element.getAttribute('type')!));
  }

  String get stringRepresentation => '$name: ${type.stringRepresentation}';
}
