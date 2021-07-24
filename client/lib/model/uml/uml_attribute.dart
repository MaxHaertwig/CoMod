import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:either_dart/either.dart';
import 'package:xml/xml.dart';

class UMLAttribute {
  String name;
  UMLVisibility visibility;
  UMLDataType dataType;

  UMLAttribute(this.name, [UMLVisibility? visibility, UMLDataType? dataType])
      : visibility = visibility ?? UMLVisibility.public,
        dataType = dataType ?? UMLDataType(Left(UMLPrimitiveType.string));

  static UMLAttribute fromXml(XmlElement element) {
    assert(element.name.toString() == 'attribute');

    var visibilityString = element.getAttribute('visibility');
    var visibility = visibilityString != null
        ? UMLVisibilityExt.fromString(visibilityString)
        : null;
    var dataTypeString = element.getAttribute('type');
    var dataType =
        dataTypeString != null ? UMLDataType.fromString(dataTypeString) : null;
    return UMLAttribute(element.innerText.trim(), visibility, dataType);
  }
}
