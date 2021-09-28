import 'package:client/model/uml/uml_data_type.dart';
import 'package:flutter/material.dart';

typedef OnChangedFunction = void Function(UMLDataType);

class DataTypeButton extends StatelessWidget {
  final UMLDataType dataType;
  final bool isReturnType;
  final OnChangedFunction? onChanged;

  DataTypeButton(this.dataType, {this.isReturnType = false, this.onChanged});

  @override
  Widget build(BuildContext context) => PopupMenuButton(
        child: Container(
          height: 48,
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Text(
              dataType.stringRepresentation,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ),
        tooltip: isReturnType ? 'Return type' : 'Data type',
        itemBuilder: (_) => UMLDataType.primitiveDataTypes(isReturnType)
            .map((v) => PopupMenuItem(
                  value: v,
                  child: Text(v.stringRepresentation),
                ))
            .toList(),
        onSelected: onChanged,
      );
}
