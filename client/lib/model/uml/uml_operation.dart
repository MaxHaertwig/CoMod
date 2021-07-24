import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:either_dart/either.dart';
import 'package:xml/xml.dart';

class UMLOperation {
  String name;
  UMLVisibility visibility;
  UMLDataType returnType;
  List<UMLOperationArgument> arguments = [];

  UMLOperation(this.name, [UMLVisibility? visibility, UMLDataType? returnType])
      : visibility = visibility ?? UMLVisibility.public,
        returnType = returnType ?? UMLDataType(Left(UMLPrimitiveType.voidType));

  static UMLOperation fromXml(XmlElement element) {
    assert(element.name.toString() == 'operation');

    final name = element.getElement('name')?.innerText ?? '';
    final visibilityString = element.getAttribute('visibility');
    final visibility = visibilityString != null
        ? UMLVisibilityExt.fromString(visibilityString)
        : null;
    final returnTypeString = element.getAttribute('returnType');
    final returnType = returnTypeString != null
        ? UMLDataType.fromString(returnTypeString)
        : null;
    final operation = UMLOperation(name, visibility, returnType);
    operation.arguments = element
        .findElements('arg')
        .map((el) => UMLOperationArgument.fromXml(el))
        .toList();
    return operation;
  }
}

class UMLOperationArgument {
  String name;
  UMLDataType type;

  UMLOperationArgument(this.name, UMLDataType? type)
      : type = type ?? UMLDataType(Left(UMLPrimitiveType.string));

  static UMLOperationArgument fromXml(XmlElement element) {
    assert(element.name.toString() == 'arg');

    final dataTypeString = element.getAttribute('type');
    final dataType =
        dataTypeString != null ? UMLDataType.fromString(dataTypeString) : null;
    return UMLOperationArgument(element.innerText.trim(), dataType);
  }
}
