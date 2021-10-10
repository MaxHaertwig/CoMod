import 'dart:collection';

import 'package:client/extensions.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_relationship.dart';
import 'package:client/model/uml/uml_relationship_type.dart';
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
  Map<String, UMLRelationship> _relationships;

  UMLModel(
      {String? uuid,
      List<UMLType>? types,
      List<UMLRelationship>? relationships})
      : uuid = uuid ?? Uuid().v4(),
        _types = {for (var type in types ?? []) type.id: type},
        _relationships = {for (var rel in relationships ?? []) rel.id: rel};

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
      relationships: element
          .findElements(UMLRelationship.xmlTag)
          .map((child) => UMLRelationship.fromXmlElement(child))
          .toList(),
    );
  }

  String get id => uuid;

  Model? get model => _model;

  set model(Model? model) {
    _model = model;
    _types.values.forEach((type) => type.umlModel = this);
    _relationships.values.forEach((rel) => rel.umlModel = this);
  }

  UnmodifiableMapView<String, UMLType> get types => UnmodifiableMapView(_types);

  void addType(UMLType umlType) {
    _types[umlType.id] = umlType;
    umlType.addToModel();
  }

  void removeType(UMLType umlType) {
    _types.remove(umlType.id);
    final deletedTypeIDs = _types.values
        .compactMap((type) => type.removeSupertype(umlType.id, true))
        .expand((x) => x)
        .toList();
    final relationshipIDs = _relationships.values
        .where((rel) => rel.fromID == umlType.id || rel.toID == umlType.id)
        .map((rel) => rel.id)
        .toList();
    relationshipIDs.forEach((id) => _relationships.remove(id));
    model?.beginTransaction();
    _model?.deleteElements([umlType.id] + deletedTypeIDs + relationshipIDs);
    _relationships.values
        .where((rel) =>
            rel.type == UMLRelationshipType.associationWithClass &&
            rel.associationClassID == umlType.id)
        .forEach(
            (rel) => rel.setType(UMLRelationshipType.association, '', true));
    model?.endTransaction();
  }

  UnmodifiableMapView<String, UMLRelationship> get relationships =>
      UnmodifiableMapView(_relationships);

  void addRelationship(UMLRelationship relationship) {
    relationship.umlModel = this;
    _relationships[relationship.id] = relationship;
    relationship.addToModel();
  }

  void removeRelationship(UMLRelationship relationship) {
    _relationships.remove(relationship.id);
    _model?.deleteElements([relationship.id]);
  }

  String get xmlRepresentation {
    final types = _types.values.map((type) => type.xmlRepresentation).join();
    final relationships =
        _relationships.values.map((rel) => rel.xmlRepresentation).join();
    return _xmlDeclaration +
        '<$_xmlTag $_uuidAttribute="$uuid">' +
        types +
        relationships +
        '</$_xmlTag>';
  }

  void addToMapping(Map<String, UMLElement> mapping) {
    mapping[id] = this;
    _types.values.forEach((type) => type.addToMapping(mapping));
    _relationships.values.forEach((rel) => mapping[rel.id] = rel);
  }

  @override
  List<UMLElement>? update(
      List<Tuple2<String, String>> attributes,
      List<Tuple2<String, int>> addedElements,
      List<Tuple2<String, String>> deletedElements) {
    deletedElements
        .where((tuple) => tuple.item2 == UMLType.xmlTag)
        .forEach((tuple) => _types.remove(tuple.item1));
    deletedElements
        .where((tuple) => tuple.item2 == UMLRelationship.xmlTag)
        .forEach((tuple) => _relationships.remove(tuple.item1));

    return addedElements.map((tuple) {
      if (tuple.item1.startsWith('<' + UMLType.xmlTag)) {
        final umlType = UMLType.fromXml(tuple.item1);
        umlType.umlModel = this;
        _types[umlType.id] = umlType;
        return umlType;
      } else {
        final relationship = UMLRelationship.fromXml(tuple.item1);
        _relationships[relationship.id] = relationship;
        return relationship;
      }
    }).toList();
  }
}
