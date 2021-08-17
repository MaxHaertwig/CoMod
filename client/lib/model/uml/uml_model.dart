import 'dart:collection';

import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:client/model/uml/uml_element.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLModel {
  static const _xmlDeclaration = '<?xml version="1.0" encoding="UTF-8"?>';
  static const _xmlTag = 'model';

  Model? _model;
  final String uuid;
  Map<String, UMLClass> _classes;

  UMLModel({String? uuid, List<UMLClass>? classes})
      : uuid = uuid ?? Uuid().v4(),
        _classes = {for (var cls in classes ?? []) cls.id: cls};

  static UMLModel fromXml(String xml) =>
      fromXmlElement(XmlDocument.parse(xml).rootElement);

  static UMLModel fromXmlElement(XmlElement element) {
    assert(element.name.toString() == 'model');
    return UMLModel(
      uuid: element.getAttribute('uuid')!,
      classes: element
          .findElements('class')
          .map((child) => UMLClass.fromXmlElement(child))
          .toList(),
    );
  }

  Model? get model => _model;

  set model(Model? model) {
    _model = model;
    _classes.values.forEach((cls) => cls.umlModel = this);
  }

  UnmodifiableMapView<String, UMLClass> get classes =>
      UnmodifiableMapView(_classes);

  void addClass(UMLClass umlClass) {
    umlClass.umlModel = this;
    _classes[umlClass.id] = umlClass;
    umlClass.addToModel();
  }

  void removeClass(UMLClass umlClass) {
    _classes.remove(umlClass.id);
    _model?.deleteElement(umlClass.id);
  }

  String get xmlRepresentation {
    final classes = _classes.values.map((cls) => cls.xmlRepresentation).join();
    return _xmlDeclaration +
        '<$_xmlTag uuid="$uuid">' +
        classes +
        '</$_xmlTag>';
  }

  void addToMapping(Map<String, UMLElement> mapping) =>
      _classes.values.forEach((cls) => cls.addToMapping(mapping));
}
