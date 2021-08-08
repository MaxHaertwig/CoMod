import 'package:client/extensions.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_attribute.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:client/screens/edit_class/widgets/attribute_action_button.dart';
import 'package:client/screens/edit_class/widgets/data_type_button.dart';
import 'package:client/screens/edit_class/widgets/visibility_button.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditAttributeRow extends StatefulWidget {
  final UMLClass _umlClass;
  final UMLAttribute _attribute;

  EditAttributeRow(this._umlClass, this._attribute, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _EditAttributeRowState(_attribute.name);
}

class _EditAttributeRowState extends State<EditAttributeRow> {
  final _textEditingController = TextEditingController();

  _EditAttributeRowState(String name) {
    _textEditingController.text = name;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Selector<Model, UMLAttribute>(
        selector: (_, model) =>
            (model.umlModel.classes[widget._umlClass.id] ?? widget._umlClass)
                .attributes[widget._attribute.id] ??
            widget._attribute,
        shouldRebuild: (previous, next) => next != previous,
        builder: (context, attribute, __) => Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              VisibilityButton(
                attribute.visibility,
                onChanged: (v) => _editAttribute(
                  context,
                  (attribute) => attribute.visibility = v,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                // TODO: limit allowed characters
                child: TextField(
                  autocorrect: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Attribute name',
                  ),
                  controller: _textEditingController,
                  onChanged: (value) => _editAttribute(
                    context,
                    (attribute) => attribute.name = value.trim(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(':'),
              const SizedBox(width: 8),
              DataTypeButton(
                attribute.dataType,
                onChanged: (dt) => _editAttribute(
                  context,
                  (attribute) => attribute.dataType = dt,
                ),
              ),
              const SizedBox(width: 8),
              AttributeActionButton(
                  (action) => _attributeAction(context, action)),
            ],
          ),
        ),
      );

  void _editAttribute(
      BuildContext context, Function(UMLAttribute attribute) f) {
    f(widget._attribute);
    Provider.of<Model>(context, listen: false).didChange();
  }

  void _attributeAction(BuildContext context, Either<MoveType, int> action) {
    if (action.isLeft) {
      widget._umlClass.moveAttribute(widget._attribute, action.left);
    } else {
      widget._umlClass.removeAttribute(widget._attribute);
    }
    Provider.of<Model>(context, listen: false).didChange();
  }
}
