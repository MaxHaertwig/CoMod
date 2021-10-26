import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_relationship_multiplicity.dart';
import 'package:client/model/uml/uml_relationship_type.dart';
import 'package:client/model/uml/uml_element.dart';
import 'package:quiver/core.dart';
import 'package:tuple/tuple.dart';
import 'package:xml/xml.dart';

typedef MultiplicityChangedFunction = void Function(
    UMLRelationshipMultiplicity);

class UMLRelationship extends NamedUMLElement {
  static const xmlTag = 'relationship';
  static const _idAttribute = 'id';
  static const _fromAttribute = 'from';
  static const _toAttribute = 'to';
  static const _typeAttribute = 'type';
  static const _fromMultiplicityAttribute = 'fromMulti';
  static const _toMultiplicityAttribute = 'toMulti';
  static const _associationClassAttribute = 'associationClass';

  UMLModel? _umlModel;
  String _fromID, _toID, _associationClassID;
  UMLRelationshipType _type;
  UMLRelationshipMultiplicity _fromMultiplicity, _toMultiplicity;
  MultiplicityChangedFunction? onFromMultiplicityChanged,
      onToMultiplicityChanged;

  UMLRelationship(
      {String? id,
      name = '',
      required fromID,
      required toID,
      UMLRelationshipType? type,
      UMLRelationshipMultiplicity? fromMultiplicity,
      UMLRelationshipMultiplicity? toMultiplicity,
      associationClassID = ''})
      : _fromID = fromID,
        _toID = toID,
        _type = type ?? UMLRelationshipType.association,
        _fromMultiplicity =
            fromMultiplicity ?? UMLRelationshipMultiplicity.empty(),
        _toMultiplicity = toMultiplicity ?? UMLRelationshipMultiplicity.empty(),
        _associationClassID = associationClassID,
        super(id: id, name: name);

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
      associationClassID:
          element.getAttribute(_associationClassAttribute) ?? '',
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

  UMLRelationshipType get type =>
      _type != UMLRelationshipType.associationWithClass ||
              _associationClassID.isNotEmpty
          ? _type
          : UMLRelationshipType.association;

  void setType(UMLRelationshipType newType, String newAssociationClassID,
      [inTransaction = false]) {
    assert((newType == UMLRelationshipType.associationWithClass) ==
        newAssociationClassID.isNotEmpty);
    if (newType != _type) {
      if (!inTransaction) {
        model?.beginTransaction();
      }
      if (_type == UMLRelationshipType.associationWithClass) {
        updateName('', 0, name.length, ''); // triggers update (in transaction)
        setAssociationClassID('', true); // triggers update (in transaction)
      }
      _type = newType;
      if (newType == UMLRelationshipType.associationWithClass) {
        setAssociationClassID(
            newAssociationClassID, true); // triggers update (in transaction)
      } else if (newType == UMLRelationshipType.qualifiedAssociation) {
        fromMultiplicity = UMLRelationshipMultiplicity
            .empty(); // triggers update (in transaction)
      }
      model?.updateAttribute(id, _typeAttribute, _type.xmlRepresentation);
      if (!inTransaction) {
        model?.endTransaction();
      }
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

  String get associationClassID => _associationClassID;

  void setAssociationClassID(String newID, [inTransaction = false]) {
    if (newID != _associationClassID) {
      _associationClassID = newID;
      if (!inTransaction) {
        model?.beginTransaction();
      }
      model?.updateAttribute(id, _associationClassAttribute, newID);
      if (_type != UMLRelationshipType.associationWithClass) {
        setType(UMLRelationshipType.associationWithClass, newID, inTransaction);
      }
      if (!inTransaction) {
        model?.endTransaction();
      }
    }
  }

  void addToModel() =>
      model?.insertElement(this, model!.uuid, -1, xmlTag, name, [
        Tuple2(_fromAttribute, _fromID),
        Tuple2(_toAttribute, _toID),
        Tuple2(_typeAttribute, _type.xmlRepresentation),
        Tuple2(_fromMultiplicityAttribute, _fromMultiplicity.xmlRepresentation),
        Tuple2(_toMultiplicityAttribute, _toMultiplicity.xmlRepresentation),
        Tuple2(_associationClassAttribute, _associationClassID),
      ]);

  String get xmlRepresentation =>
      '<$xmlTag $_idAttribute="$id" $_fromAttribute="$_fromID" $_toAttribute="$_toID" $_typeAttribute="${_type.xmlRepresentation}" $_fromMultiplicityAttribute="${_fromMultiplicity.xmlRepresentation}" $_toMultiplicityAttribute="${_toMultiplicity.xmlRepresentation}" $_associationClassAttribute="$_associationClassID">' +
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
          if (onFromMultiplicityChanged != null) {
            onFromMultiplicityChanged!(_fromMultiplicity);
          }
          break;
        case _toMultiplicityAttribute:
          _toMultiplicity = UMLRelationshipMultiplicity.parse(tuple.item2);
          if (onToMultiplicityChanged != null) {
            onToMultiplicityChanged!(_toMultiplicity);
          }
          break;
      }
    }
  }
}
