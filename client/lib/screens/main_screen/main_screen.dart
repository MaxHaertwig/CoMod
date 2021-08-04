import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:client/screens/edit_class/edit_class_screen.dart';
import 'package:client/screens/main_screen/widgets/outline_class.dart';
import 'package:client/widgets/no_data_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  final Model _model;

  MainScreen(this._model);

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
        value: _model,
        child: Selector<Model, Iterable<UMLClass>>(
          selector: (_, model) => model.umlModel.classes.values,
          shouldRebuild: (_, __) => true,
          builder: (context, classes, __) => Scaffold(
            appBar: AppBar(
              title: Selector<Model, String>(
                selector: (_, model) => model.name,
                builder: (_, name, __) => Text(name),
              ),
            ),
            body: classes.isEmpty
                ? NoDataView(
                    'No classes',
                    'Your model doesn\'t have any classes yet. Press the button to create one.',
                    'Create Class', () {
                    _newClass(context);
                  })
                : ListView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    children: classes
                        .where((cls) => !cls.isEmpty)
                        .map((cls) => GestureDetector(
                              child: OutlineClass(cls),
                              onTap: () => _editClass(context, cls),
                            ))
                        .toList(),
                  ),
            floatingActionButton: classes.isEmpty
                ? null
                : FloatingActionButton(
                    child: const Icon(Icons.add),
                    onPressed: () => _newClass(context),
                  ),
          ),
        ),
      );

  void _newClass(BuildContext context) => _editClass(context, UMLClass(), true);

  void _editClass(BuildContext context, UMLClass umlClass,
      [bool isNewClass = false]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: Provider.of<Model>(context, listen: false),
          child: EditClassScreen(umlClass, isNewClass),
        ),
      ),
    );
  }
}
