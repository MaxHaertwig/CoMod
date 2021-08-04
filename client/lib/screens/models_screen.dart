import 'package:client/model/document.dart';
import 'package:client/model/model.dart';
import 'package:client/screens/main_screen/main_screen.dart';
import 'package:client/screens/new_model_screen.dart';
import 'package:client/widgets/no_data_view.dart';
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
                              _openDocument(document, context);
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

  void _newDocument() async {
    final document = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NewModelScreen(
              _documents!.map((document) => document.name).toSet())),
    );
    if (document != null) {
      setState(() {
        _documents?.add(document);
        _documents?.sort((a, b) => a.name.compareTo(b.name));
      });
    }
  }

  void _openDocument(Document document, BuildContext context) async {
    final model = await Model.fromDocument(document);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(model)),
    );
  }
}
