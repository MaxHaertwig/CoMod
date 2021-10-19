import 'package:client/logic/diff_text_input_formatter.dart';
import 'package:client/logic/named_element_state.dart';
import 'package:client/model/constants.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_attribute.dart';
import 'package:client/model/uml/uml_relationship.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:client/screens/class/widgets/attributes/attribute_row.dart';
import 'package:client/screens/class/widgets/operations/operation_row.dart';
import 'package:client/screens/class/widgets/relationships/relationship_row.dart';
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
  State<StatefulWidget> createState() => _TypeScreenState(umlType);
}

class _TypeScreenState extends NamedElementState<TypeScreen> {
  final _focusNodes = Map<String, FocusNode>();

  _TypeScreenState(UMLType umlType) : super(umlType);

  @override
  void dispose() {
    widget.umlType.onNameChanged = null;
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
                        controller: nameTextEditingController,
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
                          children: umlType.attributes.values
                              .map((attribute) => AttributeRow(
                                    umlType: umlType,
                                    attribute: attribute,
                                    key: Key(attribute.id),
                                    focusNode: _focusNodes[attribute.id],
                                  ))
                              .toList(),
                          onAddButtonPressed: _addAttribute),
                      TypeScreenSection('Operations', 'Add operation',
                          children: umlType.operations.values
                              .map((operation) => OperationRow(
                                    umlType: umlType,
                                    operation: operation,
                                    key: Key(operation.id),
                                    focusNode: _focusNodes[operation.id],
                                  ))
                              .toList(),
                          onAddButtonPressed: _addOperation),
                      TypeScreenSection('Relationships', 'Add relationship',
                          children: umlType.relationships
                              .map((rel) => RelationshipRow(
                                  relationship: rel,
                                  reversed: rel.toID == umlType.id &&
                                      rel.toID != rel.fromID,
                                  key: Key(rel.id)))
                              .toList(),
                          onAddButtonPressed: () => _editType(
                              context,
                              (type) => type.addRelationship(UMLRelationship(
                                  fromID: type.id,
                                  toID: umlModel.types.values.first.id)))),
                    ],
                  ),
                ),
              );
            }),
      );

  void _addAttribute() {
    final newAttribute = UMLAttribute();
    _editType(context, (type) => type.addAttribute(newAttribute));
    final focusNode = FocusNode();
    _focusNodes[newAttribute.id] = focusNode;
    focusNode.requestFocus();
  }

  void _addOperation() {
    final newOperation = UMLOperation();
    _editType(context, (type) => type.addOperation(newOperation));
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
