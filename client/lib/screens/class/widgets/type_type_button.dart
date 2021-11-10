import 'package:client/model/constants.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/model/uml/uml_type_type.dart';
import 'package:flutter/material.dart';

class TypeTypeButton extends StatelessWidget {
  final UMLType _umlType;

  TypeTypeButton(UMLType umlType) : _umlType = umlType;

  @override
  Widget build(BuildContext context) => PopupMenuButton(
        tooltip: 'Type',
        child: Container(
          height: 44,
          alignment: Alignment.centerLeft,
          child: Text(_umlType.type.stringRepresentation,
              style: TextStyle(color: appColor)),
        ),
        itemBuilder: (_) => UMLTypeType.values
            .map((type) => PopupMenuItem(
                value: type, child: Text(type.stringRepresentation)))
            .toList(),
        onSelected: (UMLTypeType type) => _umlType.type = type,
      );
}
