import 'package:client/model/uml/uml_class.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLModel {
  static const currentVersion = '1.0';

  String version;
  String uuid;
  List<UMLClass> classes = [];

  UMLModel({String? uuid, this.version = currentVersion})
      : uuid = uuid ?? Uuid().v4();

  UMLModel.fromXml(XmlElement element)
      : assert(element.name.toString() == 'model'),
        version = element.getAttribute('version')!,
        uuid = element.getAttribute('uuid')!,
        classes = element
            .findElements('class')
            .map((child) => UMLClass.fromXml(child))
            .toList();
}
