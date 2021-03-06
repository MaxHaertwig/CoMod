import 'package:client/extensions.dart';
import 'package:client/logic/formatters/diff_text_input_formatter.dart';
import 'package:client/logic/named_element_state.dart';
import 'package:client/model/constants.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:client/model/uml/uml_operation_parameter.dart';
import 'package:client/screens/class/widgets/data_type_button.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'operation_action_button.dart';

typedef EditParameterFunction = void Function(UMLOperationParameter);

class OperationParameterRow extends StatefulWidget {
  final UMLType umlType;
  final UMLOperation operation;
  final UMLOperationParameter parameter;
  final VoidCallback onAddParameter;
  final FocusNode? focusNode;

  OperationParameterRow(
      {required this.umlType,
      required this.operation,
      required this.parameter,
      required this.onAddParameter,
      Key? key,
      this.focusNode})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _OperationParameterRowState(parameter);
}

class _OperationParameterRowState
    extends NamedElementState<OperationParameterRow> {
  _OperationParameterRowState(UMLOperationParameter parameter)
      : super(parameter);

  @override
  Widget build(BuildContext context) => Selector<Model, UMLOperationParameter>(
      selector: (_, model) =>
          ((model.umlModel.types[widget.umlType.id] ?? widget.umlType)
                      .operations[widget.operation.id] ??
                  widget.operation)
              .parameters[widget.parameter.id] ??
          widget.parameter,
      shouldRebuild: (previous, next) => next != previous,
      builder: (context, parameter, __) => Container(
            margin: EdgeInsets.only(left: 48),
            child: Row(
              children: [
                const Text('???', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Flexible(
                  child: TextField(
                    autocorrect: false,
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'Parameter name'),
                    controller: nameTextEditingController,
                    focusNode: widget.focusNode,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(identifierCharactersRegex)),
                      DiffTextInputFormatter((f) => _editParameter(context, f)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(':'),
                const SizedBox(width: 8),
                DataTypeButton(
                  dataType: parameter.type,
                  onChanged: (dt) => _editParameter(
                      context, (parameter) => parameter.type = dt),
                ),
                const SizedBox(width: 8),
                OperationActionButton(
                    widget.operation.parameters.moveTypes(parameter.id),
                    (action) => _parameterAction(context, action)),
              ],
            ),
          ));

  void _editParameter(BuildContext context, EditParameterFunction f) =>
      f(widget.parameter);

  void _parameterAction(BuildContext context, Either<MoveType, int> action) {
    if (action.isLeft) {
      widget.operation.moveParameter(widget.parameter, action.left);
    } else if (action.right == 0) {
      widget.onAddParameter(); // TODO: index
    } else {
      widget.operation.removeParameter(widget.parameter);
    }
  }
}
