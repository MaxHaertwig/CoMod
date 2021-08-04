import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLAttribute {
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
  set visibility(UMLVisibility visibility) => _visibility = visibility;

  UMLDataType get dataType => _dataType;
  set dataType(UMLDataType dataType) => _dataType = dataType;

  get stringRepresentation =>
      '${_visibility.stringRepresentation} ${_name.isEmpty ? '<name>' : _name}: ${_dataType.stringRepresentation}';

  @override
  String toString() => stringRepresentation;

  @override
  bool operator ==(other) =>
      other is UMLAttribute &&
      _name == other._name &&
      _visibility == other._visibility &&
      _dataType == other._dataType;
}
