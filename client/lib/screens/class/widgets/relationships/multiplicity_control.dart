import 'package:client/model/uml/uml_relationship_multiplicity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef MultiplicityChangedFunction = void Function(
    UMLRelationshipMultiplicity);

class MultiplicityControl extends StatelessWidget {
  final UMLRelationshipMultiplicity multiplicity;
  final MultiplicityChangedFunction onMultiplicityChanged;

  MultiplicityControl(this.multiplicity, this.onMultiplicityChanged);

  @override
  Widget build(BuildContext context) {
    const multiTextFieldDecoration = InputDecoration(
        border: InputBorder.none,
        hintText: '_',
        hintStyle: TextStyle(color: Colors.grey));
    // TODO: check validity
    return Row(
      children: [
        SizedBox(
          width: 12,
          child: TextFormField(
            autocorrect: false,
            decoration: multiTextFieldDecoration,
            initialValue:
                UMLRelationshipMultiplicity.componentString(multiplicity.lower),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9]'))
            ],
            textAlign: TextAlign.center,
            onChanged: (value) {
              multiplicity.lower =
                  UMLRelationshipMultiplicity.parseComponent(value);
              onMultiplicityChanged(multiplicity);
            },
          ),
        ),
        const SizedBox(width: 2),
        const Text('..'),
        const SizedBox(width: 2),
        SizedBox(
          width: 12,
          child: TextFormField(
            autocorrect: false,
            decoration: multiTextFieldDecoration,
            initialValue:
                UMLRelationshipMultiplicity.componentString(multiplicity.upper),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(
                  '[0-9]')) // TODO: custom formatter that allows numbers OR *
            ],
            textAlign: TextAlign.center,
            onChanged: (value) {
              multiplicity.upper =
                  UMLRelationshipMultiplicity.parseComponent(value);
              onMultiplicityChanged(multiplicity);
            },
          ),
        ),
      ],
    );
  }
}
