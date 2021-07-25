import 'package:client/components/no_data_view.dart';
import 'package:client/model/document.dart';
import 'package:client/model/model.dart';
import 'package:client/screens/new_model_screen.dart';
import 'package:flutter/material.dart';

class ModelsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<ModelsScreen> {
  List<Document>? _documents;

  @override
  void initState() {
    super.initState();
    Document.allDocuments().then((documents) {
      setState(() {
        _documents = documents;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Models')),
      body: _documents == null
          ? Container()
          : _documents!.isEmpty
              ? NoDataView(
                  'No Models',
                  'It looks pretty empty here. Create a model to get started.',
                  'Create Model',
                  _newDocument)
              : ListView(
                  children: _documents!
                      .map((document) => ListTile(
                            title: Text(document.name),
                            onTap: () {
                              _openDocument(document);
                            },
                          ))
                      .toList(),
                ),
      floatingActionButton: _documents?.isEmpty == true
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: _documents != null ? _newDocument : null,
            ),
    );
  }

  void _openDocument(Document document) async {
    var model = await Model.fromFile(document.path);
    print(model);
  }
}
