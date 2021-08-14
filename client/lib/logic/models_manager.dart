import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:client/model/model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'js_bridge.dart';

class ModelsManager {
  static final _documentsDirectory = getApplicationDocumentsDirectory();
  static const _modelsFile = 'models.json';
  static Map<String, String>? _models; // uuid -> name

  static Future<List<Model>> allModels() async {
    final directory = await _documentsDirectory;
    if (_models == null) {
      final file = File('${directory.path}/$_modelsFile');
      if (await file.exists()) {
        Map<String, dynamic> json = jsonDecode(await file.readAsString());
        _models = json.map((key, value) => MapEntry(key, value as String));
      } else {
        return [];
      }
    }

    return _models!.entries
        .map(
            (entry) => Model('${directory.path}/${entry.key}.yjs', entry.value))
        .toList();
  }

  static Future<Model> newModel(String name) async {
    final directory = await _documentsDirectory;
    final uuid = Uuid().v4();
    JSBridge().newModel(uuid);

    final path = '${directory.path}/$uuid.yjs';
    final document = Model(path, name);
    if (_models != null) {
      _models![uuid] = name;
    } else {
      _models = {uuid: name};
    }
    await File('${directory.path}/$_modelsFile')
        .writeAsString(jsonEncode(_models));
    return document;
  }

  static Future<void> saveModel(String uuid, Uint8List data) async {
    final directory = await _documentsDirectory;
    await File('${directory.path}/$uuid.yjs').writeAsBytes(data);
  }

  static void renameModel(String uuid, String newName) async {
    _models![uuid] = newName;
    final directory = await _documentsDirectory;
    await File('${directory.path}/$_modelsFile')
        .writeAsString(jsonEncode(_models));
  }

  static void deleteModel(String uuid) {
    _models!.remove(uuid);
  }
}
