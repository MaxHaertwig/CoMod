import 'package:client/extensions.dart';
import 'package:client/logic/diff_text_input_formatter.dart';
import 'package:client/model/constants.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_attribute.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/screens/class/widgets/attribute_action_button.dart';
import 'package:client/screens/class/widgets/data_type_button.dart';
import 'package:client/screens/class/widgets/visibility_button.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

typedef EditAttributeFunction = void Function(UMLAttribute);

class AttributeRow extends StatefulWidget {
  final UMLType _umlType;
  final UMLAttribute _attribute;
  final FocusNode? focusNode;

  AttributeRow(this._umlType, this._attribute, {Key? key, this.focusNode})
      : super(key: key);

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
            (model.umlModel.types[widget._umlType.id] ?? widget._umlType)
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
                      border: InputBorder.none, hintText: 'Attribute name'),
                  controller: _textEditingController,
                  focusNode: widget.focusNode,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(identifierCharactersRegex)),
                    DiffTextInputFormatter((f) => _editAttribute(context, f)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(':'),
              const SizedBox(width: 8),
              DataTypeButton(
                attribute.dataType,
                onChanged: (dt) => _editAttribute(
                    context, (attribute) => attribute.dataType = dt),
              ),
              const SizedBox(width: 8),
              AttributeActionButton(
                  widget._umlType.attributes.moveTypes(attribute.id),
                  (action) => _attributeAction(context, action)),
            ],
          ),
        ),
      );

  void _editAttribute(BuildContext context, EditAttributeFunction f) =>
      f(widget._attribute);

  void _attributeAction(BuildContext context, Either<MoveType, int> action) {
    if (action.isLeft) {
      widget._umlType.moveAttribute(widget._attribute, action.left);
    } else {
      widget._umlType.removeAttribute(widget._attribute);
    }
  }
}
