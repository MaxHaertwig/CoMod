import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_relationship_multiplicity.dart';
import 'package:client/model/uml/uml_relationship_type.dart';
import 'package:client/model/uml/uml_element.dart';
import 'package:quiver/core.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLRelationship extends NamedUMLElement {
  static const xmlTag = 'relationship';
  static const _idAttribute = 'id';
  static const _fromAttribute = 'from';
  static const _toAttribute = 'to';
  static const _typeAttribute = 'type';
  static const _fromMultiplicityAttribute = 'fromMulti';
  static const _toMultiplicityAttribute = 'toMulti';

  UMLModel? _umlModel;
  final String id;
  String name, _fromID, _toID;
  UMLRelationshipType _type;
  UMLRelationshipMultiplicity _fromMultiplicity, _toMultiplicity;

  UMLRelationship(
      {String? id,
      this.name = '',
      required fromID,
      required toID,
      UMLRelationshipType? type,
      UMLRelationshipMultiplicity? fromMultiplicity,
      UMLRelationshipMultiplicity? toMultiplicity})
      : id = id ?? Uuid().v4(),
        _fromID = fromID,
        _toID = toID,
        _type = type ?? UMLRelationshipType.association,
        _fromMultiplicity =
            fromMultiplicity ?? UMLRelationshipMultiplicity.empty(),
        _toMultiplicity = toMultiplicity ?? UMLRelationshipMultiplicity.empty();

  static UMLRelationship fromXml(String xml) =>
      fromXmlElement(XmlDocument.parse(xml).rootElement);

  static UMLRelationship fromXmlElement(XmlElement element) {
    assert(element.name.toString() == xmlTag);
    return UMLRelationship(
      id: element.getAttribute(_idAttribute)!,
      name: element.text.trim(),
      fromID: element.getAttribute(_fromAttribute)!,
      toID: element.getAttribute(_toAttribute)!,
      type: UMLRelationshipTypeExt.fromString(
          element.getAttribute(_typeAttribute)!),
      fromMultiplicity: UMLRelationshipMultiplicity.parse(
          element.getAttribute(_fromMultiplicityAttribute)!),
      toMultiplicity: UMLRelationshipMultiplicity.parse(
          element.getAttribute(_toMultiplicityAttribute)!),
    );
  }

  set umlModel(UMLModel? umlModel) => _umlModel = umlModel;

  Model? get model => _umlModel?.model;

  String get fromID => _fromID;

  set fromID(String fromID) {
    if (fromID != _fromID) {
      _fromID = fromID;
      model?.updateAttribute(id, _fromAttribute, _fromID);
    }
  }

  String get toID => _toID;

  set toID(String toID) {
    if (toID != _toID) {
      _toID = toID;
      model?.updateAttribute(id, _toAttribute, _toID);
    }
  }

  UMLRelationshipType get type => _type;

  set type(UMLRelationshipType type) {
    if (type != _type) {
      _type = type;
      model?.updateAttribute(id, _typeAttribute, type.xmlRepresentation);
    }
  }

  UMLRelationshipMultiplicity get fromMultiplicity => _fromMultiplicity;

  set fromMultiplicity(UMLRelationshipMultiplicity multiplicity) {
    if (multiplicity != _fromMultiplicity) {
      _fromMultiplicity = multiplicity;
      model?.updateAttribute(
          id, _fromMultiplicityAttribute, multiplicity.xmlRepresentation);
    }
  }

  UMLRelationshipMultiplicity get toMultiplicity => _toMultiplicity;

  set toMultiplicity(UMLRelationshipMultiplicity multiplicity) {
    if (multiplicity != _toMultiplicity) {
      _toMultiplicity = multiplicity;
      model?.updateAttribute(
          id, _toMultiplicityAttribute, multiplicity.xmlRepresentation);
    }
  }

  void addToModel() =>
      model?.insertElement(this, model!.uuid, -1, xmlTag, name, [
        Tuple2(_fromAttribute, _fromID),
        Tuple2(_toAttribute, _toID),
        Tuple2(_typeAttribute, _type.xmlRepresentation),
        Tuple2(_fromMultiplicityAttribute, _fromMultiplicity.xmlRepresentation),
        Tuple2(_toMultiplicityAttribute, _toMultiplicity.xmlRepresentation),
      ]);

  String get xmlRepresentation =>
      '<$xmlTag $_idAttribute="$id" $_fromAttribute="$_fromID" $_toAttribute="$_toID" $_typeAttribute="${_type.xmlRepresentation}" $_fromMultiplicityAttribute="${_fromMultiplicity.xmlRepresentation}" $_toMultiplicityAttribute="${_toMultiplicity.xmlRepresentation}">' +
      name +
      '</$xmlTag>';

  @override
  int get hashCode => hash2(hash4(name, _toID, _fromID, _type),
      hash2(_fromMultiplicity, _toMultiplicity));

  @override
  bool operator ==(other) =>
      other is UMLRelationship &&
      name == other.name &&
      _toID == other._toID &&
      _fromID == other._fromID &&
      _type == other._type &&
      _fromMultiplicity == other._fromMultiplicity &&
      _toMultiplicity == other._toMultiplicity;

  @override
  List<UMLElement>? update(
      List<Tuple2<String, String>> attributes,
      List<Tuple2<String, int>> addedElements,
      List<Tuple2<String, String>> deletedElements) {
    for (final tuple in attributes) {
      switch (tuple.item1) {
        case _fromAttribute:
          _fromID = tuple.item2;
          break;
        case _toAttribute:
          _toID = tuple.item2;
          break;
        case _typeAttribute:
          _type = UMLRelationshipTypeExt.fromString(tuple.item2);
          break;
        case _fromMultiplicityAttribute:
          _fromMultiplicity = UMLRelationshipMultiplicity.parse(tuple.item2);
          break;
        case _toMultiplicityAttribute:
          _toMultiplicity = UMLRelationshipMultiplicity.parse(tuple.item2);
          break;
      }
    }
  }
}
