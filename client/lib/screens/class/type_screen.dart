import 'package:client/logic/diff_text_input_formatter.dart';
import 'package:client/model/constants.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_attribute.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:client/screens/class/widgets/attribute_row.dart';
import 'package:client/screens/class/widgets/operation_row.dart';
import 'package:client/screens/class/widgets/supertypes_button.dart';
import 'package:client/screens/class/widgets/type_screen_section.dart';
import 'package:client/screens/class/widgets/type_type_button.dart';
import 'package:client/widgets/expanded_row.dart';
import 'package:client/widgets/menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

typedef EditTypeFunction = void Function(UMLType);

class TypeScreen extends StatefulWidget {
  final UMLType umlType;
  final bool isNewType;

  TypeScreen(this.umlType, this.isNewType);

  @override
  State<StatefulWidget> createState() => _TypeScreenState(umlType.name);
}

class _TypeScreenState extends State<TypeScreen> {
  final _nameTextEditingController = TextEditingController();
  final _focusNodes = Map<String, FocusNode>();

  _TypeScreenState(String name) {
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
          title: const Text('Edit Type'),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete type',
              itemBuilder: (_) => [
                MenuItem(Icons.delete, 'Delete type', 0, isDestructive: true),
              ],
              onSelected: (_) => _deleteType(context),
            ),
          ],
        ),
        body: Selector<Model, UMLModel>(
            selector: (_, model) => model.umlModel,
            shouldRebuild: (_, __) =>
                true, // Flutter doesn't pick up the changes in type.attributes and type.operations, because lists/maps aren't immutable. Possible workarounds: whenever something inside the type changes: 1. add an incrementing counter, 2. create a new list, 3. invent some kind of box/container for the list. Returning true for now, because at most one EditClassScreem can be on screen at the same time.
            builder: (_, umlModel, __) {
              final umlType =
                  umlModel.types[widget.umlType.id] ?? widget.umlType;
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Name',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        autofocus: widget.isNewType,
                        decoration: InputDecoration(hintText: 'Enter name'),
                        controller: _nameTextEditingController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(identifierCharactersRegex)),
                          DiffTextInputFormatter((f) => _editType(context, f)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ExpandedRow(
                        flex: [1, 2],
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Type',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TypeTypeButton(umlType),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Supertypes',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SupertypesButton(umlType, umlModel),
                              if (umlType.hasInheritanceCycle())
                                const Text('Inheritance cycle!',
                                    style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TypeScreenSection('Attributes', 'Add attribute',
                          children: widget.umlType.attributes.values
                              .map((attribute) => AttributeRow(
                                  widget.umlType, attribute,
                                  key: Key(attribute.id),
                                  focusNode: _focusNodes[attribute.id]))
                              .toList(),
                          onAddButtonPressed: _addAttribute),
                      TypeScreenSection('Operations', 'Add operation',
                          children: widget.umlType.operations.values
                              .map((operation) => OperationRow(
                                    widget.umlType,
                                    operation,
                                    key: Key(operation.id),
                                    focusNode: _focusNodes[operation.id],
                                  ))
                              .toList(),
                          onAddButtonPressed: _addOperation),
                    ],
                  ),
                ),
              );
            }),
      );

  void _addAttribute() {
    final newAttribute = UMLAttribute();
    _editType(context, (cls) => cls.addAttribute(newAttribute));
    final focusNode = FocusNode();
    _focusNodes[newAttribute.id] = focusNode;
    focusNode.requestFocus();
  }

  void _addOperation() {
    final newOperation = UMLOperation();
    _editType(context, (cls) => cls.addOperation(newOperation));
    final focusNode = FocusNode();
    _focusNodes[newOperation.id] = focusNode;
    focusNode.requestFocus();
  }

  void _editType(BuildContext context, EditTypeFunction f) {
    final wasEmpty = widget.umlType.isEmpty;
    f(widget.umlType);
    final model = Provider.of<Model>(context, listen: false);
    if (widget.umlType.isEmpty != wasEmpty) {
      if (wasEmpty) {
        model.umlModel.addType(widget.umlType);
      } else {
        model.umlModel.removeType(widget.umlType);
      }
    }
  }

  void _deleteType(BuildContext context) {
    if (!widget.umlType.isEmpty) {
      final model = Provider.of<Model>(context, listen: false);
      model.umlModel.removeType(widget.umlType);
    }
    Navigator.pop(context);
  }
}
