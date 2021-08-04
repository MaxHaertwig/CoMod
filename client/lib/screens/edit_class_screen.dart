import 'package:client/components/named_text_field.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditClassScreen extends StatelessWidget {
  final UMLClass _umlClass;
  final bool _isNewClass;

  EditClassScreen(this._umlClass, this._isNewClass);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Edit class'),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.delete),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 0,
                  child: Row(
                    children: const [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete class', style: TextStyle(color: Colors.red))
                    ],
                  ),
                ),
              ],
              onSelected: (_) => _deleteClass(context),
            ),
          ],
        ),
        body: Selector<Model, UMLClass>(
          selector: (_, model) =>
              model.umlModel.classes[_umlClass.id] ?? _umlClass,
          builder: (_, umlClass, __) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NamedTextField(
                  'Name',
                  initialValue: umlClass.name,
                  autofocus: _isNewClass,
                  onChanged: (value) =>
                      _editClass(context, (cls) => cls.name = value),
                ),
              ],
            ),
          ),
        ),
      );

  void _editClass(BuildContext context, Function(UMLClass cls) f) {
    final wasEmpty = _umlClass.isEmpty;
    f(_umlClass);
    final model = Provider.of<Model>(context, listen: false);
    if (_umlClass.isEmpty != wasEmpty) {
      if (wasEmpty) {
        model.umlModel.addClass(_umlClass);
      } else {
        model.umlModel.removeClass(_umlClass);
      }
    }
    model.notify();
  }

  void _deleteClass(BuildContext context) {
    if (!_umlClass.isEmpty) {
      final model = Provider.of<Model>(context, listen: false);
      model.umlModel.removeClass(_umlClass);
      model.notify();
    }
    Navigator.pop(context);
  }
}
