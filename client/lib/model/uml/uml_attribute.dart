import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_element.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:quiver/core.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLAttribute implements NamedUMLElement {
  static const xmlTag = 'attribute';
  static const _idAttribute = 'id';
  static const _visibilityAttribute = 'visibility';
  static const _typeAttribute = 'type';

  UMLClass? _umlClass;
  final String id;
  String _name;
  UMLVisibility _visibility;
  UMLDataType _dataType;

  UMLAttribute(
      {String? id,
      String name = '',
      UMLVisibility visibility = UMLVisibility.public,
      UMLDataType? dataType})
      : id = id ?? Uuid().v4(),
        _name = name,
        _visibility = visibility,
        _dataType = dataType ?? UMLDataType.string();

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

  set umlClass(UMLClass umlClass) => _umlClass = umlClass;

  Model? get model => _umlClass?.model;

  String get name => _name;

  set name(String name) {
    if (name != _name) {
      final oldName = _name;
      _name = name;
      model?.updateText(id, oldName, name);
    }
  }

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
      model?.insertElement(this, _umlClass!.id, id, xmlTag, name, [
        Tuple2(_visibilityAttribute, visibility.xmlRepresentation),
        Tuple2(_typeAttribute, dataType.xmlRepresentation)
      ]);

  String get stringRepresentation =>
      '${_visibility.symbol} ${_name.isEmpty ? '<name>' : _name}: ${_dataType.stringRepresentation}';

  String get xmlRepresentation {
    final visibility =
        '$_visibilityAttribute="${_visibility.xmlRepresentation}"';
    final type = '$_typeAttribute="${_dataType.xmlRepresentation}"';
    return '<$xmlTag $_idAttribute="$id" $visibility $type>' +
        _name +
        '</$xmlTag>';
  }

  @override
  String toString() => stringRepresentation;

  @override
  int get hashCode => hash3(_name, _visibility, _dataType);

  @override
  bool operator ==(other) =>
      other is UMLAttribute &&
      _name == other._name &&
      _visibility == other._visibility &&
      _dataType == other._dataType;

  List<UMLElement>? update(List<Tuple2<String, String>> attributes,
      List<String> addedElements, List<String> deletedElements) {
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
