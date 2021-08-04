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
        appBar: AppBar(title: const Text('Edit class')),
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
                      _editClass(context, () => _umlClass.name = value),
                ),
              ],
            ),
          ),
        ),
      );

  void _editClass(BuildContext context, Function() f) {
    final wasEmpty = _umlClass.isEmpty;
    f();
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
}
