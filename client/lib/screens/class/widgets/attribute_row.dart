import 'package:client/extensions.dart';
import 'package:client/model/constants.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_attribute.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:client/screens/class/widgets/attribute_action_button.dart';
import 'package:client/screens/class/widgets/data_type_button.dart';
import 'package:client/screens/class/widgets/visibility_button.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

typedef EditAttributeFunction = void Function(UMLAttribute);

class AttributeRow extends StatefulWidget {
  final UMLClass _umlClass;
  final UMLAttribute _attribute;

  AttributeRow(this._umlClass, this._attribute, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AttributeRowState(_attribute.name);
}

class _AttributeRowState extends State<AttributeRow> {
  final _textEditingController = TextEditingController();

  _AttributeRowState(String name) {
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
                onChanged: (v) => attribute.visibility = v,
              ),
              Flexible(
                child: TextField(
                  autocorrect: false,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Attribute name',
                  ),
                  controller: _textEditingController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(identifierCharactersRegex))
                  ],
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

  void _editAttribute(BuildContext context, EditAttributeFunction f) =>
      f(widget._attribute);

  void _attributeAction(BuildContext context, Either<MoveType, int> action) {
    if (action.isLeft) {
      widget._umlClass.moveAttribute(widget._attribute, action.left);
    } else {
      widget._umlClass.removeAttribute(widget._attribute);
    }
  }
}
