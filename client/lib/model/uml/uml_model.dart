import 'package:client/model/uml/uml_class.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLModel {
  static const currentVersion = '1.0';

  String version;
  String uuid;
  List<UMLClass> classes = [];

  UMLModel(String? uuid, [this.version = '1.0']) : uuid = uuid ?? Uuid().v4();

  UMLModel.fromXml(XmlElement element)
      : assert(element.name.toString() == 'model'),
        version = element.getAttribute('version') ?? '1.0',
        uuid = element.getAttribute('uuid') ?? Uuid().v4(),
        classes = element
            .findElements('class')
            .map((child) => UMLClass.fromXml(child))
            .toList();
}
