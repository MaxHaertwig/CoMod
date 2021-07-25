import 'package:client/model/uml/uml_class.dart';
import 'package:flutter/material.dart';

class OutlineClass extends StatelessWidget {
  final UMLClass umlClass;

  OutlineClass(this.umlClass);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(umlClass.name,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Divider(color: Colors.grey),
            // TODO: monospace
            ...umlClass.attributes
                .map((attribute) => Text(attribute.stringRepresentation))
                .toList(),
            if (!umlClass.operations.isEmpty) Divider(color: Colors.grey),
            // TODO: monospace
            if (!umlClass.operations.isEmpty)
              ...umlClass.operations
                  .map((operation) => Text(operation.stringRepresentation))
                  .toList(),
          ],
        ),
      ),
    );
  }
}
