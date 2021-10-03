import 'package:client/model/constants.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_attribute.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:client/screens/class/widgets/attribute_row.dart';
import 'package:client/screens/class/widgets/operation_row.dart';
import 'package:client/widgets/expanded_row.dart';
import 'package:client/widgets/menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

typedef EditClassFunction = void Function(UMLClass);

class ClassScreen extends StatefulWidget {
  final UMLClass umlClass;
  final bool isNewClass;

  ClassScreen(this.umlClass, this.isNewClass);

  @override
  State<StatefulWidget> createState() => _ClassScreenState(umlClass.name);
}

class _ClassScreenState extends State<ClassScreen> {
  final _nameTextEditingController = TextEditingController();
  final _focusNodes = Map<String, FocusNode>();

  _ClassScreenState(String name) {
    _nameTextEditingController.text = name;
  }

  @override
  void dispose() {
    _nameTextEditingController.dispose();
    _focusNodes.values.forEach((node) => node.dispose());
    super.dispose();
  }

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
              model.umlModel.classes[widget.umlClass.id] ?? widget.umlClass,
          shouldRebuild: (_, __) =>
              true, // Flutter doesn't pick up the changes in class.attributes and class.operations, because lists/maps aren't immutable. Possible workarounds: whenever something inside the class changes: 1. add an incrementing counter, 2. create a new list, 3. invent some kind of box/container for the list. Returning true for now, because at most one EditClassScreem can be on screen at the same time.
          builder: (_, umlClass, __) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Name',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    autofocus: widget.isNewClass,
                    decoration: InputDecoration(hintText: 'Enter name'),
                    controller: _nameTextEditingController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(identifierCharactersRegex))
                    ],
                    onChanged: (value) =>
                        _editClass(context, (cls) => cls.name = value.trim()),
                  ),
                  const SizedBox(height: 24),
                  ExpandedRow(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Extends',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          PopupMenuButton(
                            child: Container(
                              height: 48,
                              alignment: Alignment.centerLeft,
                              child: Text('None',
                                  style: const TextStyle(color: Colors.blue)),
                            ),
                            itemBuilder: (_) => ['None'] // TODO: classes
                                .map((value) => PopupMenuItem(
                                    value: value, child: Text(value)))
                                .toList(),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Abstract',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Switch(
                              value: umlClass.isAbstract,
                              onChanged: (value) =>
                                  umlClass.isAbstract = value),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Attributes',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...widget.umlClass.attributes.values
                      .map((attribute) => AttributeRow(
                            widget.umlClass,
                            attribute,
                            key: Key(attribute.id),
                            focusNode: _focusNodes[attribute.id],
                          ))
                      .toList(),
                  TextButton(
                    child: const Text('Add attribute',
                        textAlign: TextAlign.center),
                    onPressed: () {
                      final newAttribute = UMLAttribute();
                      _editClass(
                          context, (cls) => cls.addAttribute(newAttribute));
                      final focusNode = FocusNode();
                      _focusNodes[newAttribute.id] = focusNode;
                      focusNode.requestFocus();
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text('Operations',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...widget.umlClass.operations.values
                      .map((operation) => OperationRow(
                            widget.umlClass,
                            operation,
                            key: Key(operation.id),
                            focusNode: _focusNodes[operation.id],
                          )),
                  TextButton(
                    child: const Text('Add operation',
                        textAlign: TextAlign.center),
                    onPressed: () {
                      final newOperation = UMLOperation();
                      _editClass(
                          context, (cls) => cls.addOperation(newOperation));
                      final focusNode = FocusNode();
                      _focusNodes[newOperation.id] = focusNode;
                      focusNode.requestFocus();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  void _editClass(BuildContext context, EditClassFunction f) {
    final wasEmpty = widget.umlClass.isEmpty;
    f(widget.umlClass);
    final model = Provider.of<Model>(context, listen: false);
    if (widget.umlClass.isEmpty != wasEmpty) {
      if (wasEmpty) {
        model.umlModel.addClass(widget.umlClass);
      } else {
        model.umlModel.removeClass(widget.umlClass);
      }
    }
  }

  void _deleteClass(BuildContext context) {
    if (!widget.umlClass.isEmpty) {
      final model = Provider.of<Model>(context, listen: false);
      model.umlModel.removeClass(widget.umlClass);
    }
    Navigator.pop(context);
  }
}
