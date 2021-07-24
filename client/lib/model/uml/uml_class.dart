import 'package:client/model/uml/uml_attribute.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLClass {
  String name, id;
  int x, y;
  List<UMLAttribute> attributes = [];
  List<UMLOperation> operations = [];

  UMLClass(this.name, String? id, [int this.x = 0, int this.y = 0])
      : id = id ?? Uuid().v4();

  static UMLClass fromXml(XmlElement element) {
    assert(element.name.toString() == 'class');

    final name = element.getElement('name')!.innerText.trim();
    final x = int.parse(element.getAttribute('x')!);
    final y = int.parse(element.getAttribute('y')!);

    var umlClass = UMLClass(name, element.getAttribute('id')!, x, y);
    umlClass.attributes = element
        .findElements('attribute')
        .map((child) => UMLAttribute.fromXml(child))
        .toList();
    umlClass.operations = element
        .findElements('operation')
        .map((child) => UMLOperation.fromXml(child))
        .toList();
    return umlClass;
  }
}
