import 'dart:collection';

import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:client/model/uml/uml_element.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLModel implements UMLElement {
  static const _xmlDeclaration = '<?xml version="1.0" encoding="UTF-8"?>';
  static const _xmlTag = 'model';
  static const _uuidAttribute = 'uuid';

  Model? _model;
  final String uuid;
  Map<String, UMLClass> _classes;

  UMLModel({String? uuid, List<UMLClass>? classes})
      : uuid = uuid ?? Uuid().v4(),
        _classes = {for (var cls in classes ?? []) cls.id: cls};

  static UMLModel fromXml(String xml) =>
      fromXmlElement(XmlDocument.parse(xml).rootElement);

  static UMLModel fromXmlElement(XmlElement element) {
    assert(element.name.toString() == _xmlTag);
    return UMLModel(
      uuid: element.getAttribute(_uuidAttribute)!,
      classes: element
          .findElements(UMLClass.xmlTag)
          .map((child) => UMLClass.fromXmlElement(child))
          .toList(),
    );
  }

  String get id => uuid;

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
        '<$_xmlTag $_uuidAttribute="$uuid">' +
        classes +
        '</$_xmlTag>';
  }

  void addToMapping(Map<String, UMLElement> mapping) {
    mapping[id] = this;
    _classes.values.forEach((cls) => cls.addToMapping(mapping));
  }

  @override
  List<UMLElement>? update(List<Tuple2<String, String>> attributes,
      List<Tuple2<String, int>> addedElements, List<String> deletedElements) {
    deletedElements.forEach((id) => _classes.remove(id));

    final List<UMLElement> newElements = [];
    for (final tuple in addedElements) {
      final umlClass = UMLClass.fromXml(tuple.item1);
      _classes[umlClass.id] = umlClass;
      newElements.add(umlClass);
    }
    return newElements;
  }
}
