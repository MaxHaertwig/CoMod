import 'package:client/extensions.dart';
import 'package:client/logic/diff_text_input_formatter.dart';
import 'package:client/model/constants.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:client/model/uml/uml_operation_parameter.dart';
import 'package:client/screens/class/widgets/data_type_button.dart';
import 'package:client/screens/class/widgets/operations/operation_parameter_row.dart';
import 'package:client/screens/class/widgets/visibility_button.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'operation_action_button.dart';

typedef EditOperationFunction = void Function(UMLOperation);

class OperationRow extends StatefulWidget {
  final UMLType _umlType;
  final UMLOperation _operation;
  final FocusNode? focusNode;

  OperationRow(this._umlType, this._operation, {Key? key, this.focusNode})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _OperationRowState(_operation.name);
}

class _OperationRowState extends State<OperationRow> {
  final _textEditingController = TextEditingController();
  final _focusNodes = Map<String, FocusNode>();

  _OperationRowState(String name) {
    _textEditingController.text = name;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNodes.values.forEach((node) => node.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Selector<Model, UMLOperation>(
        selector: (_, model) =>
            (model.umlModel.types[widget._umlType.id] ?? widget._umlType)
                .operations[widget._operation.id] ??
            widget._operation,
        shouldRebuild: (previous, next) => next != previous,
        builder: (context, operation, __) => Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Row(
                children: [
                  VisibilityButton(
                    operation.visibility,
                    onChanged: (v) => operation.visibility = v,
                  ),
                  Flexible(
                    child: TextField(
                      autocorrect: false,
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: 'Operation name'),
                      controller: _textEditingController,
                      focusNode: widget.focusNode,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(identifierCharactersRegex)),
                        DiffTextInputFormatter(
                            (f) => _editOperation(context, f)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(':'),
                  const SizedBox(width: 8),
                  DataTypeButton(
                    operation.returnType,
                    onChanged: (dt) => _editOperation(
                        context, (operation) => operation.returnType = dt),
                  ),
                  const SizedBox(width: 8),
                  OperationActionButton(
                      widget._umlType.operations.moveTypes(operation.id),
                      (action) => _operationAction(context, action)),
                ],
              ),
              if (widget._operation.parameters.isNotEmpty) Divider(height: 0),
              ...widget._operation.parameters.values
                  .map((parameter) => OperationParameterRow(
                        widget._umlType,
                        widget._operation,
                        parameter,
                        _addParameter,
                        key: Key(parameter.id),
                        focusNode: _focusNodes[parameter.id],
                      )),
            ],
          ),
        ),
      );

  void _editOperation(BuildContext context, EditOperationFunction f) =>
      f(widget._operation);

  void _operationAction(BuildContext context, Either<MoveType, int> action) {
    if (action.isLeft) {
      widget._umlType.moveOperation(widget._operation, action.left);
    } else if (action.right == 0) {
      _addParameter();
    } else {
      widget._umlType.removeOperation(widget._operation);
    }
  }

  void _addParameter() {
    // TODO: add at location
    final newParameter = UMLOperationParameter();
    widget._operation.addParameter(newParameter);
    final focusNode = FocusNode();
    _focusNodes[newParameter.id] = focusNode;
    focusNode.requestFocus();
  }
}
