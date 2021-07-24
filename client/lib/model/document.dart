import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

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
    final file = File('${directory.path}/$name.xml');
    final uuid = Uuid().v4();
    await file.writeAsString(
        '<?xml version="1.0" encoding="UTF-8"?><model version="1.0" uuid="$uuid"></model>');
    return Document(file.path);
  }
}
