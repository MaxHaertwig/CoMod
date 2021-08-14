import 'dart:io';

import 'package:client/logic/js_bridge.dart';
import 'package:client/logic/models_manager.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:flutter/material.dart';

class Model extends ChangeNotifier {
  // TODO: make private and expose functions
  final jsBridge = JSBridge();
  final String path;
  late final UMLModel umlModel;

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

  void didChange() {
    notifyListeners();
  }
}
