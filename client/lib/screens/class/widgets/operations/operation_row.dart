import 'package:client/extensions.dart';
import 'package:client/logic/diff_text_input_formatter.dart';
import 'package:client/logic/named_element_state.dart';
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
  final UMLType umlType;
  final UMLOperation operation;
  final FocusNode? focusNode;

  OperationRow(
      {required this.umlType,
      required this.operation,
      Key? key,
      this.focusNode})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _OperationRowState(operation);
}

class _OperationRowState extends NamedElementState<OperationRow> {
  final _focusNodes = Map<String, FocusNode>();

  _OperationRowState(UMLOperation operation) : super(operation);

  @override
  void dispose() {
    _focusNodes.values.forEach((node) => node.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Selector<Model, UMLOperation>(
        selector: (_, model) =>
            (model.umlModel.types[widget.umlType.id] ?? widget.umlType)
                .operations[widget.operation.id] ??
            widget.operation,
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
                      controller: nameTextEditingController,
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
                    dataType: operation.returnType,
                    isReturnType: true,
                    onChanged: (dt) => _editOperation(
                        context, (operation) => operation.returnType = dt),
                  ),
                  const SizedBox(width: 8),
                  OperationActionButton(
                      widget.umlType.operations.moveTypes(operation.id),
                      (action) => _operationAction(context, action)),
                ],
              ),
              if (widget.operation.parameters.isNotEmpty) Divider(height: 0),
              ...widget.operation.parameters.values
                  .map((parameter) => OperationParameterRow(
                        umlType: widget.umlType,
                        operation: widget.operation,
                        parameter: parameter,
                        onAddParameter: _addParameter,
                        key: Key(parameter.id),
                        focusNode: _focusNodes[parameter.id],
                      )),
            ],
          ),
        ),
      );

  void _editOperation(BuildContext context, EditOperationFunction f) =>
      f(widget.operation);

  void _operationAction(BuildContext context, Either<MoveType, int> action) {
    if (action.isLeft) {
      widget.umlType.moveOperation(widget.operation, action.left);
    } else if (action.right == 0) {
      _addParameter();
    } else {
      widget.umlType.removeOperation(widget.operation);
    }
  }

  void _addParameter() {
    // TODO: add at location
    final newParameter = UMLOperationParameter();
    widget.operation.addParameter(newParameter);
    final focusNode = FocusNode();
    _focusNodes[newParameter.id] = focusNode;
    focusNode.requestFocus();
  }
}
