import 'package:client/model/uml/uml_data_type.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class UMLAttribute extends ChangeNotifier {
  String _name;
  UMLVisibility _visibility;
  UMLDataType _dataType;

  UMLAttribute(
      {String name = '',
      UMLVisibility visibility = UMLVisibility.public,
      UMLDataType? dataType})
      : _name = name,
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
  set name(String name) {
    _name = name;
    notifyListeners();
  }

  UMLVisibility get visibility => _visibility;
  set visibility(UMLVisibility visibility) {
    _visibility = visibility;
    notifyListeners();
  }

  UMLDataType get dataType => _dataType;
  set dataType(UMLDataType dataType) {
    _dataType = dataType;
    notifyListeners();
  }

  get stringRepresentation =>
      '${_visibility.stringRepresentation} $_name: ${_dataType.stringRepresentation}';
}
