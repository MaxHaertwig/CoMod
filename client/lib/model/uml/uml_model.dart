import 'dart:collection';

import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_type.dart';
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
  Map<String, UMLType> _types;

  UMLModel({String? uuid, List<UMLType>? types})
      : uuid = uuid ?? Uuid().v4(),
        _types = {for (var cls in types ?? []) cls.id: cls};

  static UMLModel fromXml(String xml) =>
      fromXmlElement(XmlDocument.parse(xml).rootElement);

  static UMLModel fromXmlElement(XmlElement element) {
    assert(element.name.toString() == _xmlTag);
    return UMLModel(
      uuid: element.getAttribute(_uuidAttribute)!,
      types: element
          .findElements(UMLType.xmlTag)
          .map((child) => UMLType.fromXmlElement(child))
          .toList(),
    );
  }

  String get id => uuid;

  Model? get model => _model;

  set model(Model? model) {
    _model = model;
    _types.values.forEach((cls) => cls.umlModel = this);
  }

  UnmodifiableMapView<String, UMLType> get types => UnmodifiableMapView(_types);

  void addType(UMLType umlType) {
    umlType.umlModel = this;
    _types[umlType.id] = umlType;
    umlType.addToModel();
  }

  void removeType(UMLType umlType) {
    _types.remove(umlType.id);
    _model?.deleteElements([umlType.id]);
  }

  String get xmlRepresentation {
    final types = _types.values.map((cls) => cls.xmlRepresentation).join();
    return _xmlDeclaration +
        '<$_xmlTag $_uuidAttribute="$uuid">' +
        types +
        '</$_xmlTag>';
  }

  void addToMapping(Map<String, UMLElement> mapping) {
    mapping[id] = this;
    _types.values.forEach((cls) => cls.addToMapping(mapping));
  }

  @override
  List<UMLElement>? update(
      List<Tuple2<String, String>> attributes,
      List<Tuple2<String, int>> addedElements,
      List<Tuple2<String, String>> deletedElements) {
    deletedElements.forEach((tuple) => _types.remove(tuple.item1));

    final List<UMLElement> newElements = [];
    for (final tuple in addedElements) {
      final umlType = UMLType.fromXml(tuple.item1);
      _types[umlType.id] = umlType;
      newElements.add(umlType);
    }
    return newElements;
  }
}
