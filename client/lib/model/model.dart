import 'dart:io';

import 'package:client/model/document.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class Model extends ChangeNotifier {
  String name;
  UMLModel umlModel;

  Model(this.name, this.umlModel);

  static Future<Model> fromDocument(Document document) async {
    final xml = await File(document.path).readAsString();
    final root = XmlDocument.parse(xml).rootElement;
    return Model(document.name, UMLModel.fromXml(root));
  }

  notify() => notifyListeners();
}
