import 'package:client/model/document.dart';
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
          : ListView(
              children: _documents!
                  .map((document) => ListTile(title: Text(document.name)))
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _documents != null
            ? () async {
                final document = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewModelScreen(_documents!
                            .map((document) => document.name)
                            .toSet())));
                setState(() {
                  _documents?.add(document);
                  _documents?.sort((a, b) => a.name.compareTo(b.name));
                });
              }
            : null,
        child: const Icon(Icons.add),
      ),
    );
  }
}
