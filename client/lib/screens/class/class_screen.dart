import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_attribute.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:client/screens/class/widgets/attribute_row.dart';
import 'package:client/screens/class/widgets/operation_row.dart';
import 'package:client/screens/class/widgets/named_text_field.dart';
import 'package:client/widgets/menu_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef EditClassFunction = void Function(UMLClass);

class ClassScreen extends StatelessWidget {
  final UMLClass _umlClass;
  final bool _isNewClass;

  ClassScreen(this._umlClass, this._isNewClass);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Edit class'),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete class',
              itemBuilder: (_) => [
                MenuItem(Icons.delete, 'Delete class', 0, isDestructive: true),
              ],
              onSelected: (_) => _deleteClass(context),
            ),
          ],
        ),
        body: Selector<Model, UMLClass>(
          selector: (_, model) =>
              model.umlModel.classes[_umlClass.id] ?? _umlClass,
          shouldRebuild: (_, __) =>
              true, // Flutter doesn't pick up the changes in class.attributes and class.operations, because lists/maps aren't immutable. Possible workarounds: whenever something inside the class changes: 1. add an incrementing counter, 2. create a new list, 3. invent some kind of box/container for the list. Returning true for now, because at most one EditClassScreem can be on screen at the same time.
          builder: (_, umlClass, __) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // TODO: escape string
                  NamedTextField(
                    'Name',
                    initialValue: umlClass.name,
                    autofocus: _isNewClass,
                    onChanged: (value) => _editClass(
                      context,
                      (cls) => cls.name = value.trim(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Attributes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._umlClass.attributes.values
                      .map((attribute) => AttributeRow(
                            _umlClass,
                            attribute,
                            key: Key(attribute.id),
                          ))
                      .toList(),
                  TextButton(
                    child: const Text(
                      'Add attribute',
                      textAlign: TextAlign.center,
                    ),
                    // TODO: focus new text field
                    onPressed: () => _editClass(
                      context,
                      (cls) => cls.addAttribute(UMLAttribute()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Operations',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._umlClass.operations.values.map((operation) =>
                      OperationRow(_umlClass, operation,
                          key: Key(operation.id))),
                  TextButton(
                    child: const Text(
                      'Add operation',
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () => _editClass(
                        context, (cls) => cls.addOperation(UMLOperation())),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  void _editClass(BuildContext context, EditClassFunction f) {
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
  }

  void _deleteClass(BuildContext context) {
    if (!_umlClass.isEmpty) {
      final model = Provider.of<Model>(context, listen: false);
      model.umlModel.removeClass(_umlClass);
    }
    Navigator.pop(context);
  }
}
