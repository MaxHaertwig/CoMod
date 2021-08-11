import 'dart:io';

import 'package:client/model/model.dart';
import 'package:path_provider/path_provider.dart';

class Document {
  String _path;
  bool isDeleted = false;

  Document(this._path);

  String get name {
    final fileName = _path.split('/').last;
    return fileName.substring(0, fileName.length - 4);
  }

  String get path => _path;

  Future<String> readXML() async => await File(_path).readAsString();

  Future<void> rename(String newName) async {
    assert(!isDeleted);
    final parts = _path.split('/');
    final newPath = parts.take(parts.length - 1).join('/') + '/$newName.xml';
    await File(_path).rename(newPath);
    _path = newPath;
  }

  Future<void> delete() async {
    isDeleted = true;
    await File(_path).delete();
  }

  static Future<List<Document>> allDocuments() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory
        .listSync()
        .where((file) => file.path.endsWith('.xml'))
        .map((file) => Document(file.path))
        .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
  }

  static Future<Document> newDocument(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$name.xml';
    await Model(path: path).save();
    return Document(path);
  }
}
