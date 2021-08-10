import 'package:client/logic/js_bridge.dart';
import 'package:client/model/document.dart';
import 'package:client/model/model.dart';
import 'package:client/screens/main_screen/main_screen.dart';
import 'package:client/screens/models/widgets/model_row.dart';
import 'package:client/screens/edit_model_screen.dart';
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
    Document.allDocuments()
        .then((documents) => setState(() => _documents = documents));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Models')),
        body: _documents == null
            ? Container()
            : _documents!.isEmpty
                ? NoDataView(
                    'No Models',
                    'It looks pretty empty here. Create a model to get started.',
                    'Create Model',
                    () => _newDocument(context))
                : ListView(
                    children: _documents!
                        .map((document) => ModelRow(
                              document.name,
                              onTap: () => _openDocument(context, document),
                              onAction: (action) =>
                                  _modelAction(context, document, action),
                            ))
                        .toList(),
                  ),
        floatingActionButton: _documents?.isEmpty == true
            ? null
            : FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () =>
                    _documents == null ? null : _newDocument(context),
              ),
      );

  void _newDocument(BuildContext context) async {
    final document = await _editDocument(context, null);
    if (document != null) {
      setState(() {
        _documents?.add(document);
        _documents?.sort((a, b) => a.name.compareTo(b.name));
      });
    }
  }

  void _openDocument(BuildContext context, Document document) async {
    final xml = await document.readXML();
    final model = await Model.fromXML(xml, document.path);
    await JSBridge().loadModel(xml);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(model)),
    );
  }

  void _modelAction(
      BuildContext context, Document document, ModelRowAction action) async {
    switch (action) {
      case ModelRowAction.rename:
        await _editDocument(context, document);
        setState(() => _documents?.sort((a, b) => a.name.compareTo(b.name)));
        break;
      case ModelRowAction.delete:
        document.delete();
        setState(() => _documents?.remove(document));
        break;
    }
  }

  Future<Document?> _editDocument(
          BuildContext context, Document? document) async =>
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditModelScreen(
            document,
            existingNames: _documents!.map((document) => document.name).toSet(),
          ),
        ),
      );
}
