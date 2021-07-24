import 'dart:io';

import 'package:client/model/uml/uml_model.dart';
import 'package:xml/xml.dart';

class Model {
  UMLModel model;

  Model(this.model);

  static Future<Model> fromFile(String path) async {
    final xml = await File(path).readAsString();
    final root = XmlDocument.parse(xml).rootElement;
    return Model(UMLModel.fromXml(root));
  }
}
