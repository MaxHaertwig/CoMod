import 'dart:io';

import 'package:client/model/document.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class Model extends ChangeNotifier {
  final String path;
  String name;
  final UMLModel umlModel;

  Model(this.path, this.name, [UMLModel? umlModel])
      : umlModel = umlModel ?? UMLModel();

  static Future<Model> fromDocument(Document document) async {
    final xml = await File(document.path).readAsString();
    final root = XmlDocument.parse(xml).rootElement;
    return Model(document.path, document.name, UMLModel.fromXml(root));
  }

  Future save() async {
    await File(path).writeAsString(umlModel.xmlRepresentation);
  }

  void didChange() {
    notifyListeners();
    save();
  }
}
