import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/model/uml/uml_type_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TypeCard extends StatelessWidget {
  final UMLType _umlType;

  TypeCard(this._umlType, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Selector<Model, UMLType>(
        selector: (_, model) => model.umlModel.types[_umlType.id] ?? _umlType,
        builder: (_, umlType, __) => Card(
          margin: const EdgeInsets.all(0),
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    umlType.name,
                    style: TextStyle(
                      fontStyle: umlType.type == UMLTypeType.abstractClass
                          ? FontStyle.italic
                          : FontStyle.normal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(color: Colors.grey),
                if (umlType.attributes.isEmpty)
                  const Text('No attributes',
                      style: TextStyle(color: Colors.grey)),
                ...umlType.attributes.values
                    .map((attribute) =>
                        Text(attribute.stringRepresentation)) // TODO: monospace
                    .toList(),
                if (umlType.operations.isNotEmpty)
                  const Divider(color: Colors.grey),
                if (umlType.operations.isNotEmpty)
                  ...umlType.operations.values
                      .map((operation) => Text(
                          operation.stringRepresentation)) // TODO: monospace
                      .toList(),
              ],
            ),
          ),
        ),
      );
}
