import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:xml/xml.dart';

class UMLAttribute {
  String name;
  UMLVisibility visibility;
  UMLDataType dataType;

  UMLAttribute(this.name, [UMLVisibility? visibility, UMLDataType? dataType])
      : visibility = visibility ?? UMLVisibility.public,
        dataType = dataType ?? UMLDataType.string();

  static UMLAttribute fromXml(XmlElement element) {
    assert(element.name.toString() == 'attribute');

    var visibility =
        UMLVisibilityExt.fromString(element.getAttribute('visibility')!);
    var dataType = UMLDataType.fromString(element.getAttribute('type')!);
    return UMLAttribute(element.innerText.trim(), visibility, dataType);
  }

  String get stringRepresentation =>
      '${visibility.stringRepresentation} $name: ${dataType.stringRepresentation}';
}
