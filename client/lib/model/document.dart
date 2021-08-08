import 'dart:io';

import 'package:client/model/model.dart';
import 'package:path_provider/path_provider.dart';

class Document {
  final String path;

  Document(this.path);

  String get name {
    final fileName = path.split('/').last;
    return fileName.substring(0, fileName.length - 4);
  }

  static Future<List<Document>> allDocuments() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.listSync().map((file) => Document(file.path)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  static Future<Document> newDocument(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$name.xml';
    await Model(path, name).save();
    return Document(path);
  }
}
