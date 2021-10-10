import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_data_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef OnChangedFunction = void Function(UMLDataType);

class DataTypeButton extends StatelessWidget {
  final UMLDataType dataType;
  final bool isReturnType;
  final OnChangedFunction? onChanged;

  DataTypeButton(this.dataType, {this.isReturnType = false, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final umlModel = Provider.of<Model>(context, listen: false).umlModel;
    return PopupMenuButton(
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Text(
            dataType.stringRepresentation(umlModel),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.blue),
          ),
        ),
      ),
      tooltip: isReturnType ? 'Return type' : 'Data type',
      itemBuilder: (_) =>
          UMLDataType.primitiveDataTypes(isReturnType)
              .map((v) => PopupMenuItem(
                  value: v, child: Text(v.stringRepresentation(umlModel))))
              .toList() +
          (umlModel.types.values.toList()
                ..sort((a, b) => a.name.compareTo(b.name)))
              .map((type) => PopupMenuItem(
                  value: UMLDataType.type(type.id), child: Text(type.name)))
              .toList(),
      onSelected: onChanged,
    );
  }
}
