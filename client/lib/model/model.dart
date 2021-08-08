import 'dart:io';

import 'package:client/model/document.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class Model extends ChangeNotifier {
  String _path;
  final UMLModel umlModel;

  Model(this._path, {UMLModel? umlModel}) : umlModel = umlModel ?? UMLModel();

  static Future<Model> fromDocument(Document document) async {
    final xml = await File(document.path).readAsString();
    final root = XmlDocument.parse(xml).rootElement;
    return Model(document.path, umlModel: UMLModel.fromXml(root));
  }

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
