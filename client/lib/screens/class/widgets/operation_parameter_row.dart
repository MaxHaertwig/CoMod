import 'package:client/extensions.dart';
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

typedef AddParameterFunction = void Function();
typedef EditParameterFunction = void Function(UMLOperationParameter);

class OperationParameterRow extends StatefulWidget {
  final UMLType _umlType;
  final UMLOperation _operation;
  final UMLOperationParameter _parameter;
  final AddParameterFunction _addParameterFunction;
  final FocusNode? focusNode;

  OperationParameterRow(this._umlType, this._operation, this._parameter,
      this._addParameterFunction,
      {Key? key, this.focusNode})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _OperationParameterRowState(_parameter.name);
}

class _OperationParameterRowState extends State<OperationParameterRow> {
  final _textEditingController = TextEditingController();

  _OperationParameterRowState(String name) {
    _textEditingController.text = name;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Selector<Model, UMLOperationParameter>(
      selector: (_, model) =>
          ((model.umlModel.types[widget._umlType.id] ?? widget._umlType)
                      .operations[widget._operation.id] ??
                  widget._operation)
              .parameters[widget._parameter.id] ??
          widget._parameter,
      shouldRebuild: (previous, next) => next != previous,
      builder: (context, parameter, __) => Container(
            margin: EdgeInsets.only(left: 48),
            child: Row(
              children: [
                const Text('∙', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Flexible(
                  child: TextField(
                    autocorrect: false,
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'Parameter name'),
                    controller: _textEditingController,
                    focusNode: widget.focusNode,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(identifierCharactersRegex))
                    ],
                    onChanged: (value) => _editParameter(
                        context, (parameter) => parameter.name = value.trim()),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(':'),
                const SizedBox(width: 8),
                DataTypeButton(
                  parameter.type,
                  onChanged: (dt) => _editParameter(
                      context, (parameter) => parameter.type = dt),
                ),
                const SizedBox(width: 8),
                OperationActionButton(
                    widget._operation.parameters.moveTypes(parameter.id),
                    (action) => _parameterAction(context, action)),
              ],
            ),
          ));

  void _editParameter(BuildContext context, EditParameterFunction f) =>
      f(widget._parameter);

  void _parameterAction(BuildContext context, Either<MoveType, int> action) {
    if (action.isLeft) {
      widget._operation.moveParameter(widget._parameter, action.left);
    } else if (action.right == 0) {
      widget._addParameterFunction(); // TODO: index
    } else {
      widget._operation.removeParameter(widget._parameter);
    }
  }
}
