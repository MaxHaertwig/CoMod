import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:quiver/core.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLAttribute {
  static const xmlTag = 'attribute';
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

  static UMLAttribute fromXml(XmlElement element) {
    assert(element.name.toString() == 'attribute');
    return UMLAttribute(
      name: element.innerText.trim(),
      visibility:
          UMLVisibilityExt.fromString(element.getAttribute('visibility')!),
      dataType: UMLDataType.fromString(element.getAttribute('type')!),
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
  int get hashCode => hash3(_name, _visibility, _dataType);

  @override
  bool operator ==(other) =>
      other is UMLAttribute &&
      _name == other._name &&
      _visibility == other._visibility &&
      _dataType == other._dataType;
}
