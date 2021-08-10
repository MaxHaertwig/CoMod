import 'dart:io';

import 'package:client/model/document.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class Model extends ChangeNotifier {
  String _path;
  final UMLModel umlModel;

  Model(this._path, {UMLModel? umlModel}) : umlModel = umlModel ?? UMLModel();

  Model.fromXML(String xml, String path)
      : this(
          path,
          umlModel: UMLModel.fromXml(XmlDocument.parse(xml).rootElement),
        );

  static Future<Model> fromDocument(Document document) async =>
      Model.fromXML(await document.readXML(), document.path);

  String get name {
    final fileName = _path.split('/').last;
    return fileName.substring(0, fileName.length - 4);
  }

  Future<void> save() async =>
      await File(_path).writeAsString(umlModel.xmlRepresentation);

  void didChange() {
    notifyListeners();
    save();
  }
}
