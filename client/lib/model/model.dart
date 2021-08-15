import 'dart:async';
import 'dart:io';

import 'package:client/logic/collaboration_session.dart';
import 'package:client/logic/js_bridge.dart';
import 'package:client/logic/models_manager.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class Model extends ChangeNotifier {
  final String path;
  late final UMLModel umlModel;

  final _jsBridge = JSBridge();

  String _name;
  bool _hasModel = false;
  bool _isDeleted = false;

  CollaborationSession? _session;

  Model(this.path, this._name, {UMLModel? umlModel}) {
    if (umlModel != null) {
      this.umlModel = umlModel;
    }
  }

  String get name => _name;

  String get uuid => path.split('/').last.split('.').first;

  bool get isSessionInProgress => _session != null;

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

  Future<void> collaborate(OnErrorFunction onError) async {
    final completer = Completer();
    _session = CollaborationSession(
      uuid,
      await _jsBridge.stateVector(),
      onUpdateReceived: _jsBridge.processUpdate,
      onSyncModel: _jsBridge.sync,
      onStateChanged: (state) {
        print('Session state changed: $state');
        switch (state) {
          case SessionState.connecting:
          case SessionState.syncing:
            break;
          case SessionState.connected:
            completer.complete();
            break;
          case SessionState.disconnected:
            completer.complete();
            _jsBridge.onDocUpdateFunction = null;
            _session = null;
            notifyListeners();
            break;
        }
      },
      onError: onError,
    );
    _jsBridge.onDocUpdateFunction = _session!.sendUpdate;
    notifyListeners();
    return completer.future;
  }

  void stopCollaborating() async {
    await _session!.close();
    _session = null;
    notifyListeners();
  }

  static const _elementsWithNameElement = {
    UMLClass.xmlTag,
    UMLOperation.xmlTag
  };

  void insertElement(String parentID, String id, String nodeName, String name,
      List<Tuple2<String, String>>? attributes) {
    _jsBridge.insertElement(parentID, id, nodeName,
        _elementsWithNameElement.contains(nodeName), name, attributes);
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
