import 'package:client/logic/js_bridge.dart';
import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLAttribute {
  static const xmlTag = 'attribute';
  static const _visibilityAttribute = 'visibility';
  static const _typeAttribute = 'type';

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

  static UMLAttribute fromXml(XmlElement element) {
    assert(element.name.toString() == 'attribute');
    return UMLAttribute(
      name: element.innerText.trim(),
      visibility:
          UMLVisibilityExt.fromString(element.getAttribute('visibility')!),
      dataType: UMLDataType.fromString(element.getAttribute('type')!),
    );
  }

  String get name => _name;
  set name(String name) => _name = name;

  UMLVisibility get visibility => _visibility;
  set visibility(UMLVisibility visibility) {
    if (visibility != _visibility) {
      _visibility = visibility;
      JSBridge().updateAttribute(
          id, _visibilityAttribute, visibility.xmlRepresentation);
    }
  }

  UMLDataType get dataType => _dataType;

  set dataType(UMLDataType dataType) {
    if (dataType != _dataType) {
      _dataType = dataType;
      JSBridge()
          .updateAttribute(id, _typeAttribute, dataType.xmlRepresentation);
    }
  }

  String get stringRepresentation =>
      '${_visibility.symbol} ${_name.isEmpty ? '<name>' : _name}: ${_dataType.stringRepresentation}';

  String get xmlRepresentation {
    final visibility =
        '$_visibilityAttribute="${_visibility.xmlRepresentation}"';
    final type = '$_typeAttribute="${_dataType.xmlRepresentation}"';
    return '<$xmlTag id="$id" $visibility $type>' + _name + '</$xmlTag>';
  }

  @override
  String toString() => stringRepresentation;

  @override
  bool operator ==(other) =>
      other is UMLAttribute &&
      _name == other._name &&
      _visibility == other._visibility &&
      _dataType == other._dataType;
}
