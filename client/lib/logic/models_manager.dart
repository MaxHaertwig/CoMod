import 'dart:convert';
import 'dart:io';

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

  static Future<String> path(String uuid) async =>
      '${(await _documentsDirectory).path}/$uuid.yjs';

  static Future<Model> newModel(String name) async {
    final uuid = Uuid().v4();
    await JSBridge().newModel(uuid);

    final model = Model(await path(uuid), name);
    await addModel(uuid, name);
    return model;
  }

  static Future<void> addModel(String uuid, String name) async {
    if (_models != null) {
      _models![uuid] = name;
    } else {
      _models = {uuid: name};
    }
    await _saveModels();
  }

  static Future<void> saveModel(String uuid, List<int> data) async =>
      await File(await path(uuid)).writeAsBytes(data);

  static void renameModel(String uuid, String newName) async {
    _models![uuid] = newName;
    await File('${(await _documentsDirectory).path}/$_modelsFile')
        .writeAsString(jsonEncode(_models));
  }

  static Future<void> deleteModel(String uuid) async {
    try {
      await File(await path(uuid)).delete();
    } on OSError catch (e) {
      if (e.errorCode == 2) {
        // No such file or directory
        print('Cannot delete non-existing file $path');
      } else {
        print(e);
      }
    }
    _models!.remove(uuid);
    await _saveModels();
  }

  static Future<void> _saveModels() async =>
      await File('${(await _documentsDirectory).path}/$_modelsFile')
          .writeAsString(jsonEncode(_models));
}
