import 'package:client/extensions.dart';
import 'package:client/model/constants.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:client/model/uml/uml_operation.dart';
import 'package:client/model/uml/uml_operation_parameter.dart';
import 'package:client/screens/class/widgets/data_type_button.dart';
import 'package:client/screens/class/widgets/operation_parameter_row.dart';
import 'package:client/screens/class/widgets/visibility_button.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'operation_action_button.dart';

typedef EditOperationFunction = void Function(UMLOperation);

class OperationRow extends StatefulWidget {
  final UMLClass _umlClass;
  final UMLOperation _operation;

  OperationRow(this._umlClass, this._operation, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OperationRowState(_operation.name);
}

class _OperationRowState extends State<OperationRow> {
  final _textEditingController = TextEditingController();

  _OperationRowState(String name) {
    _textEditingController.text = name;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Selector<Model, UMLOperation>(
        selector: (_, model) =>
            (model.umlModel.classes[widget._umlClass.id] ?? widget._umlClass)
                .operations[widget._operation.id] ??
            widget._operation,
        shouldRebuild: (previous, next) => next != previous,
        builder: (context, attribute, __) => Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Row(
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
                        hintText: 'Operation name',
                      ),
                      controller: _textEditingController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(identifierCharactersRegex))
                      ],
                      onChanged: (value) => _editOperation(context,
                          (operation) => operation.name = value.trim()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(':'),
                  const SizedBox(width: 8),
                  DataTypeButton(
                    attribute.returnType,
                    onChanged: (dt) => _editOperation(
                        context, (operation) => operation.returnType = dt),
                  ),
                  const SizedBox(width: 8),
                  OperationActionButton(
                      (action) => _operationAction(context, action)),
                ],
              ),
              if (widget._operation.parameters.isNotEmpty) Divider(height: 0),
              ...widget._operation.parameters.values
                  .map((parameter) => OperationParameterRow(
                        widget._umlClass,
                        widget._operation,
                        parameter,
                        key: Key(parameter.id),
                      )),
            ],
          ),
        ),
      );

  void _editOperation(BuildContext context, EditOperationFunction f) =>
      f(widget._operation);

  void _operationAction(BuildContext context, Either<MoveType, int> action) {
    if (action.isLeft) {
      widget._umlClass.moveOperation(widget._operation, action.left);
    } else if (action.right == 0) {
      // TODO: add at location
      widget._operation.addParameter(UMLOperationParameter());
      // TODO: set keyboard focus
    } else {
      widget._umlClass.removeOperation(widget._operation);
    }
  }
}
