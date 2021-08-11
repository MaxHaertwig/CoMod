import 'dart:collection';

import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

class UMLModel {
  static const currentVersion = '1.0';
  static const _xmlDeclaration = '<?xml version="1.0" encoding="UTF-8"?>';
  static const _xmlTag = 'model';

  Model? _model = null;
  final String version, uuid;
  Map<String, UMLClass> _classes;

  UMLModel(
      {String this.version = currentVersion,
      String? uuid,
      List<UMLClass>? classes})
      : uuid = uuid ?? Uuid().v4(),
        _classes = {for (var cls in classes ?? []) cls.id: cls};

  static UMLModel fromXml(XmlElement element) {
    assert(element.name.toString() == 'model');
    return UMLModel(
      version: element.getAttribute('version')!,
      uuid: element.getAttribute('uuid')!,
      classes: element
          .findElements('class')
          .map((child) => UMLClass.fromXml(child))
          .toList(),
    );
  }

  Model? get model => _model;

  set model(Model? model) {
    _model = model;
    _classes.values.forEach((cls) => cls.umlModel = this);
  }

  UnmodifiableMapView<String, UMLClass> get classes =>
      UnmodifiableMapView(_classes);

  void addClass(UMLClass umlClass) {
    umlClass.umlModel = this;
    _classes[umlClass.id] = umlClass;
    _model?.jsBridge?.insertElement(null, umlClass.id, UMLClass.xmlTag);
    _model?.didChange();
  }

  void removeClass(UMLClass umlClass) {
    _classes.remove(umlClass.id);
    _model?.jsBridge?.deleteElement(umlClass.id);
    _model?.didChange();
  }

  String get xmlRepresentation {
    final classes = _classes.values.map((cls) => cls.xmlRepresentation).join();
    return _xmlDeclaration +
        '<$_xmlTag version="$currentVersion" uuid="$uuid">' +
        classes +
        '</$_xmlTag>';
  }
}
