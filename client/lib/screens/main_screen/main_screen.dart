import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/screens/class/type_screen.dart';
import 'package:client/screens/main_screen/widgets/collaboration_dialog.dart';
import 'package:client/screens/main_screen/widgets/collaboration_menu_button.dart';
import 'package:client/screens/main_screen/widgets/inheritance_indicator.dart';
import 'package:client/screens/main_screen/widgets/type_card.dart';
import 'package:client/widgets/no_data_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  final Model _model;

  MainScreen(this._model);

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
        value: _model,
        child: Consumer<Model>(
          builder: (context, model, __) => Scaffold(
            appBar: AppBar(
              title: Selector<Model, String>(
                selector: (_, model) => model.name,
                builder: (_, name, __) => Text(name),
              ),
              actions: [
                CollaborationMenuButton(
                  model.isSessionInProgress,
                  onSelected: (index) => _collaborationAction(context, index),
                ),
              ],
            ),
            body: model.umlModel.types.isEmpty
                ? NoDataView(
                    'No types',
                    'Your model doesn\'t have any types yet. Press the button to create one.',
                    ['Create Type'],
                    (_) => _newType(context))
                : ListView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    children: model.umlModel.types.values
                        .where((cls) => !cls.isEmpty)
                        .map((cls) => Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              child: Column(
                                children: [
                                  if (cls.extendsClass != '' &&
                                      model.umlModel.types
                                          .containsKey(cls.extendsClass))
                                    InheritanceIndicator(model
                                        .umlModel.types[cls.extendsClass]!),
                                  GestureDetector(
                                    child: TypeCard(cls),
                                    onTap: () => _editType(context, cls),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
            floatingActionButton: model.umlModel.types.isEmpty
                ? null
                : FloatingActionButton(
                    child: const Icon(Icons.add),
                    onPressed: () => _newType(context),
                  ),
          ),
        ),
      );

  void _newType(BuildContext context) => _editType(context, UMLType(), true);

  void _editType(BuildContext context, UMLType umlType,
      [bool isNewType = false]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: Provider.of<Model>(context, listen: false),
          child: TypeScreen(umlType, isNewType),
        ),
      ),
    );
  }

  void _collaborationAction(BuildContext context, int index) {
    switch (index) {
      case 0:
        _collaborate(context);
        break;
      case 1:
        Clipboard.setData(ClipboardData(text: _model.sessionLink));
        break;
      case 2:
        _model.stopCollaborating();
        break;
    }
  }

  void _collaborate(BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) => CollaborationDialog(
        onCancel: () => Navigator.pop(context),
      ),
      barrierDismissible: false,
    );
    await _model.collaborate((error) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error))));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Connected to collaboration session'),
      action: SnackBarAction(
        label: 'Copy link',
        onPressed: () =>
            Clipboard.setData(ClipboardData(text: _model.sessionLink)),
      ),
    ));
    Navigator.pop(context);
  }
}
