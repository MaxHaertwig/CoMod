import 'dart:io';

import 'package:client/logic/js_bridge.dart';
import 'package:client/model/document.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class Model extends ChangeNotifier {
  final String? path;
  final UMLModel umlModel;
  JSBridge? jsBridge;

  Model({this.path, UMLModel? umlModel, bool setUpJSBridge = false})
      : umlModel = umlModel ?? UMLModel() {
    if (setUpJSBridge) {
      jsBridge = JSBridge();
    }
    this.umlModel.model = this;
  }

  Model.fromXML(String xml, {String? path, bool setUpJSBridge = false})
      : this(
          path: path,
          umlModel: UMLModel.fromXml(XmlDocument.parse(xml).rootElement),
          setUpJSBridge: setUpJSBridge,
        );

  static Future<Model> fromDocument(Document document,
          {bool setUpJSBridge = true}) async =>
      Model.fromXML(
        await document.readXML(),
        path: document.path,
        setUpJSBridge: setUpJSBridge,
      );

  String get name {
    if (path == null) {
      return '';
    }
    final fileName = path!.split('/').last;
    return fileName.substring(0, fileName.length - 4);
  }

  Future<void> save() async {
    if (path != null) {
      await File(path!).writeAsString(umlModel.xmlRepresentation);
    }
  }

  void didChange() {
    notifyListeners();
    save();
  }
}
