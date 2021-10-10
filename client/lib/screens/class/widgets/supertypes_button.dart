import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:flutter/material.dart';

class SupertypesButton extends StatelessWidget {
  final UMLType _umlType;
  final UMLModel _umlModel;

  SupertypesButton(UMLType umlType, UMLModel umlModel)
      : _umlType = umlType,
        _umlModel = umlModel;

  @override
  Widget build(BuildContext context) {
    final candidates = _umlModel.types.values.where((type) => type != _umlType);
    return PopupMenuButton(
      tooltip: 'Supertypes',
      enabled: candidates.isNotEmpty,
      child: Container(
        height: 44,
        alignment: Alignment.centerLeft,
        child: Text(
            _umlType.supertypes.isEmpty
                ? 'None'
                : _umlType.supertypesLabel, // May overflow
            style: TextStyle(
                color: candidates.isEmpty ? Colors.grey : Colors.blue)),
      ),
      itemBuilder: (_) => candidates
          .map((type) =>
              CheckedPopupMenuItem(value: type, child: Text(type.name)))
          .toList(),
      onSelected: (UMLType supertype) {
        if (_umlType.supertypes.contains(supertype.id)) {
          _umlType.removeSupertype(supertype.id);
        } else {
          _umlType.addSupertype(supertype.id);
        }
      },
    );
  }
}
