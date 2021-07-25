import 'dart:io';

import 'package:client/model/document.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:xml/xml.dart';

class Model {
  String name;
  UMLModel model;

  Model(this.name, this.model);

  static Future<Model> fromDocument(Document document) async {
    final xml = await File(document.path).readAsString();
    final root = XmlDocument.parse(xml).rootElement;
    return Model(document.name, UMLModel.fromXml(root));
  }
}
