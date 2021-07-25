import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:xml/xml.dart';

class UMLAttribute {
  String name;
  UMLVisibility visibility;
  UMLDataType dataType;

  UMLAttribute(this.name,
      {this.visibility = UMLVisibility.public, UMLDataType? dataType})
      : dataType = dataType ?? UMLDataType.string();

  static UMLAttribute fromXml(XmlElement element) {
    assert(element.name.toString() == 'attribute');

    return UMLAttribute(element.innerText.trim(),
        visibility:
            UMLVisibilityExt.fromString(element.getAttribute('visibility')!),
        dataType: UMLDataType.fromString(element.getAttribute('type')!));
  }

  String get stringRepresentation =>
      '${visibility.stringRepresentation} $name: ${dataType.stringRepresentation}';
}
