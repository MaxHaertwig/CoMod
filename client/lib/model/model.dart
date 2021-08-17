import 'dart:async';
import 'dart:io';

import 'package:client/logic/collaboration_session.dart';
import 'package:client/logic/js_bridge.dart';
import 'package:client/logic/models_manager.dart';
import 'package:client/model/uml/uml_element.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class Model extends ChangeNotifier {
  final String path;
  late final UMLModel umlModel;

  final _jsBridge = JSBridge();

  late final Map<String, UMLElement> _mapping;
  String _name;
  bool _hasModel = false;
  bool _isDeleted = false;

  CollaborationSession? _session;

  Model(this.path, this._name, {UMLModel? umlModel}) {
    if (umlModel != null) {
      this.umlModel = umlModel;
      _createMapping();
    }
  }

  String get name => _name;

  String get uuid => path.split('/').last.split('.').first;

  bool get isSessionInProgress => _session != null;

  String? get sessionLink => isSessionInProgress
      ? 'collaboration://maxhaertwig.com/thesis/$uuid'
      : null;

  Future<void> load([String? inXml]) async {
    final xml = inXml ??
        await JSBridge().loadModel(uuid, await File(path).readAsBytes(), false);
    if (!_hasModel) {
      _hasModel = true;
      umlModel = UMLModel.fromXml(xml);
      umlModel.model = this;
      _createMapping();
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
    await ModelsManager.deleteModel(uuid);
  }

  Future<void> collaborate(OnErrorFunction onError) async {
    final completer = Completer();
    _session = CollaborationSession.joinWithModel(
      uuid,
      await _jsBridge.stateVector(),
      onSyncModel: _jsBridge.sync,
      onUpdateReceived: _jsBridge.processUpdate,
      onStateChanged: (state) {
        switch (state) {
          case SessionState.connecting:
          case SessionState.syncing:
            break;
          case SessionState.connected:
            _sessionConnected();
            completer.complete();
            break;
          case SessionState.disconnected:
            completer.complete();
            _sessionDisconnected();
            break;
        }
      },
      onError: onError,
    );
    _jsBridge.onLocalUpdate = _session!.sendUpdate;
    notifyListeners();
    return completer.future;
  }

  void stopCollaborating() async {
    await _session!.close();
    _session = null;
    notifyListeners();
  }

  void continueSession(CollaborationSession session) {
    assert(session.state == SessionState.connected);
    _session = session;
    _session!.onStateChanged = (state) {
      print('Session state changed: $state');
      if (state == SessionState.disconnected) {
        _sessionDisconnected();
      }
    };
    _session!.onUpdateReceived = _jsBridge.processUpdate;
    _sessionConnected();
  }

  void _sessionConnected() {
    _jsBridge.startObservingRemoteChanges();
    _jsBridge.onLocalUpdate = _session!.sendUpdate;
    _jsBridge.onRemoteUpdate = (textChanges, elementChanges) {
      textChanges.forEach((tuple) => _mapping[tuple.item1]?.name = tuple.item2);
      for (final tuple in elementChanges) {
        final element = _mapping[tuple.item1];
        if (element != null) {
          final newElements =
              element.update(tuple.item2, tuple.item3, tuple.item4);
          newElements?.forEach((el) => _mapping[el.id] = el);
        }
        tuple.item4.forEach((id) => _mapping.remove(id));
      }
      notifyListeners();
    };
  }

  void _sessionDisconnected() {
    _jsBridge.onLocalUpdate = null;
    _jsBridge.onRemoteUpdate = null;
    _session = null;
    notifyListeners();
  }

  void insertElement(UMLElement element, String parentID, String id,
      String nodeName, String name, List<Tuple2<String, String>>? attributes) {
    _mapping[id] = element;
    _jsBridge.insertElement(parentID, id, nodeName, name, attributes);
    notifyListeners();
  }

  void deleteElement(String id) {
    _mapping.remove(id);
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

  void _createMapping() {
    _mapping = {};
    umlModel.addToMapping(_mapping);
  }
}
