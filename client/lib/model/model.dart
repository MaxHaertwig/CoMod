import 'dart:io';

import 'package:client/logic/js_bridge.dart';
import 'package:client/logic/models_manager.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:flutter/material.dart';

class Model extends ChangeNotifier {
  final String path;
  late final UMLModel umlModel;

  final _jsBridge = JSBridge();

  String _name;
  bool _hasModel = false;
  bool _isDeleted = false;

  Model(this.path, this._name, {UMLModel? umlModel}) {
    if (umlModel != null) {
      this.umlModel = umlModel;
    }
  }

  String get name => _name;

  String get uuid => path.split('/').last.split('.').first;

  Future<void> load() async {
    final xml =
        await JSBridge().loadModel(uuid, await File(path).readAsBytes());
    if (!_hasModel) {
      _hasModel = true;
      umlModel = UMLModel.fromXmlString(xml);
      umlModel.model = this;
    }
  }

  Future<void> rename(String newName) async {
    assert(!_isDeleted);
    _name = newName;
    ModelsManager.renameModel(uuid, newName);
  }

  Future<void> delete() async {
    assert(!_isDeleted);
    _isDeleted = true;
    await File(path).delete();
  }

  static const _elementsWithNameElement = {
    UMLClass.xmlTag,
    UMLOperation.xmlTag
  };

  void insertElement(String parentID, String id, String nodeName) {
    _jsBridge.insertElement(
        parentID, id, nodeName, _elementsWithNameElement.contains(nodeName));
    notifyListeners();
  }

  void deleteElement(String id) {
    _jsBridge.deleteElement(id);
    notifyListeners();
  }

  // TODO: apply delta
  void updateText(String id, String oldText, String newText) {
    _jsBridge.updateText(id, oldText, newText);
    notifyListeners();
  }

  void updateAttribute(String id, String attribute, String value) {
    _jsBridge.updateAttribute(id, attribute, value);
    notifyListeners();
  }

  void didChange() => notifyListeners();
}
