import 'package:client/logic/models_manager.dart';
import 'package:client/model/model.dart';
import 'package:client/screens/main_screen/main_screen.dart';
import 'package:client/screens/models/widgets/model_row.dart';
import 'package:client/screens/edit_model_screen.dart';
import 'package:client/widgets/no_data_view.dart';
import 'package:flutter/material.dart';

class ModelsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends State<ModelsScreen> {
  List<Model>? _models;

  @override
  void initState() {
    super.initState();
    ModelsManager.allModels()
        .then((models) => setState(() => _models = models));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Models')),
        body: _models == null
            ? Container()
            : _models!.isEmpty
                ? NoDataView(
                    'No Models',
                    'It looks pretty empty here. Create a model to get started.',
                    'Create Model',
                    () => _newModel(context))
                : ListView(
                    children: _models!
                        .map((model) => ModelRow(
                              model,
                              onTap: () => _openModel(context, model),
                              onAction: (action) =>
                                  _modelAction(context, model, action),
                            ))
                        .toList(),
                  ),
        floatingActionButton: _models?.isEmpty == true
            ? null
            : FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () => _models == null ? null : _newModel(context),
              ),
      );

  void _newModel(BuildContext context) async {
    final document = await _editModelMetadata(context, null);
    if (document != null) {
      setState(() {
        _models?.add(document);
        _models?.sort((a, b) => a.name.compareTo(b.name));
      });
    }
  }

  void _openModel(BuildContext context, Model model) async {
    await model.load();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MainScreen(model)),
    );
  }

  void _modelAction(
      BuildContext context, Model model, ModelRowAction action) async {
    switch (action) {
      case ModelRowAction.rename:
        await _editModelMetadata(context, model);
        setState(() => _models?.sort((a, b) => a.name.compareTo(b.name)));
        break;
      case ModelRowAction.delete:
        model.delete();
        setState(() => _models?.remove(model));
        break;
    }
  }

  Future<Model?> _editModelMetadata(BuildContext context, Model? model) async =>
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditModelScreen(
            model,
            existingNames: _models!.map((model) => model.name).toSet(),
          ),
        ),
      );
}
