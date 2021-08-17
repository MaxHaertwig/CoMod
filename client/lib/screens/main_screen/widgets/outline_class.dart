import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_class.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OutlineClass extends StatelessWidget {
  final UMLClass _umlClass;

  OutlineClass(this._umlClass, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Selector<Model, UMLClass>(
        selector: (_, model) =>
            model.umlModel.classes[_umlClass.id] ?? _umlClass,
        builder: (_, umlClass, __) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          elevation: 2,
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    umlClass.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(color: Colors.grey),
                if (umlClass.attributes.isEmpty)
                  const Text(
                    'No attributes',
                    style: TextStyle(color: Colors.grey),
                  ),
                ...umlClass.attributes.values
                    .map((attribute) =>
                        Text(attribute.stringRepresentation)) // TODO: monospace
                    .toList(),
                if (umlClass.operations.isNotEmpty)
                  const Divider(color: Colors.grey),
                if (umlClass.operations.isNotEmpty)
                  ...umlClass.operations.values
                      .map((operation) => Text(
                          operation.stringRepresentation)) // TODO: monospace
                      .toList(),
              ],
            ),
          ),
        ),
      );
}
