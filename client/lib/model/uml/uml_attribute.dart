import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_element.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:quiver/core.dart';
import 'package:tuple/tuple.dart';
import 'package:xml/xml.dart';

class UMLAttribute extends NamedUMLElement {
  static const xmlTag = 'attribute';
  static const _idAttribute = 'id';
  static const _visibilityAttribute = 'visibility';
  static const _typeAttribute = 'type';

  UMLType? _umlType;
  UMLVisibility _visibility;
  UMLDataType _dataType;

  UMLAttribute(
      {String? id,
      name = '',
      UMLVisibility visibility = UMLVisibility.public,
      UMLDataType? dataType})
      : _visibility = visibility,
        _dataType = dataType ?? UMLDataType.string(),
        super(id: id, name: name);

  static UMLAttribute fromXml(String xml) =>
      fromXmlElement(XmlDocument.parse(xml).rootElement);

  static UMLAttribute fromXmlElement(XmlElement element) {
    assert(element.name.toString() == xmlTag);
    return UMLAttribute(
      id: element.getAttribute(_idAttribute)!,
      name: element.text.trim(),
      visibility: UMLVisibilityExt.fromString(
          element.getAttribute(_visibilityAttribute)!),
      dataType: UMLDataType.fromString(element.getAttribute(_typeAttribute)!),
    );
  }

  set umlType(UMLType umlType) => _umlType = umlType;

  Model? get model => _umlType?.model;

  UMLVisibility get visibility => _visibility;

  set visibility(UMLVisibility visibility) {
    if (visibility != _visibility) {
      _visibility = visibility;
      model?.updateAttribute(
          id, _visibilityAttribute, visibility.xmlRepresentation);
    }
  }

  UMLDataType get dataType => _dataType;

  set dataType(UMLDataType dataType) {
    if (dataType != _dataType) {
      _dataType = dataType;
      model?.updateAttribute(id, _typeAttribute, dataType.xmlRepresentation);
    }
  }

  void addToModel() =>
      model?.insertElement(this, _umlType!.id, 2, xmlTag, name, [
        Tuple2(_visibilityAttribute, visibility.xmlRepresentation),
        Tuple2(_typeAttribute, dataType.xmlRepresentation)
      ]);

  String get xmlRepresentation {
    final visibility =
        '$_visibilityAttribute="${_visibility.xmlRepresentation}"';
    final type = '$_typeAttribute="${_dataType.xmlRepresentation}"';
    return '<$xmlTag $_idAttribute="$id" $visibility $type>' +
        name +
        '</$xmlTag>';
  }

  String stringRepresentation(UMLModel umlModel) =>
      '${_visibility.symbol} ${name.isEmpty ? '<no name>' : name}: ${_dataType.stringRepresentation(umlModel)}';

  @override
  String toString() =>
      '${_visibility.symbol} ${name.isEmpty ? '<no name>' : name}: $_dataType';

  @override
  int get hashCode => hash3(name, _visibility, _dataType);

  @override
  bool operator ==(other) =>
      other is UMLAttribute &&
      name == other.name &&
      _visibility == other._visibility &&
      _dataType == other._dataType;

  @override
  List<UMLElement>? update(
      List<Tuple2<String, String>> attributes,
      List<Tuple2<String, int>> addedElements,
      List<Tuple2<String, String>> deletedElements) {
    for (final tuple in attributes) {
      switch (tuple.item1) {
        case _visibilityAttribute:
          _visibility = UMLVisibilityExt.fromString(tuple.item2);
          break;
        case _typeAttribute:
          _dataType = UMLDataType.fromString(tuple.item2);
          break;
      }
    }
  }
}
