import 'package:client/extensions.dart';
import 'package:client/logic/diff_text_input_formatter.dart';
import 'package:client/logic/named_element_state.dart';
import 'package:client/model/constants.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_attribute.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/screens/class/widgets/attributes/attribute_action_button.dart';
import 'package:client/screens/class/widgets/data_type_button.dart';
import 'package:client/screens/class/widgets/visibility_button.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

typedef EditAttributeFunction = void Function(UMLAttribute);

class AttributeRow extends StatefulWidget {
  final UMLType umlType;
  final UMLAttribute attribute;
  final FocusNode? focusNode;

  AttributeRow(
      {required this.umlType,
      required this.attribute,
      Key? key,
      this.focusNode})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AttributeRowState(attribute);
}

class _AttributeRowState extends NamedElementState<AttributeRow> {
  _AttributeRowState(UMLAttribute attribute) : super(attribute);

  @override
  Widget build(BuildContext context) => Selector<Model, UMLAttribute>(
        selector: (_, model) =>
            (model.umlModel.types[widget.umlType.id] ?? widget.umlType)
                .attributes[widget.attribute.id] ??
            widget.attribute,
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
                  controller: nameTextEditingController,
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
                dataType: attribute.dataType,
                onChanged: (dt) => widget.attribute.dataType = dt,
              ),
              const SizedBox(width: 8),
              AttributeActionButton(
                  widget.umlType.attributes.moveTypes(attribute.id),
                  (action) => _attributeAction(context, action)),
            ],
          ),
        ),
      );

  void _editAttribute(BuildContext context, EditAttributeFunction f) =>
      f(widget.attribute);

  void _attributeAction(BuildContext context, Either<MoveType, int> action) {
    if (action.isLeft) {
      widget.umlType.moveAttribute(widget.attribute, action.left);
    } else {
      widget.umlType.removeAttribute(widget.attribute);
    }
  }
}
