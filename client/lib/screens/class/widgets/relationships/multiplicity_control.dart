import 'package:client/logic/upper_multiplicity_text_input_formatter.dart';
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
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: TextFormField(
            autocorrect: false,
            decoration: multiTextFieldDecoration,
            initialValue:
                UMLRelationshipMultiplicity.componentString(multiplicity.lower),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9]'))
            ],
            style: TextStyle(
                color: multiplicity.isValid ? Colors.black : Colors.red),
            textAlign: TextAlign.center,
            onChanged: (value) => onMultiplicityChanged(
                UMLRelationshipMultiplicity(
                    UMLRelationshipMultiplicity.parseComponent(value),
                    multiplicity.upper)),
          ),
        ),
        const SizedBox(width: 2),
        Text('..',
            style: TextStyle(
                color: multiplicity.isValid ? Colors.black : Colors.red)),
        const SizedBox(width: 2),
        SizedBox(
          width: 20,
          child: TextFormField(
            autocorrect: false,
            decoration: multiTextFieldDecoration,
            initialValue:
                UMLRelationshipMultiplicity.componentString(multiplicity.upper),
            inputFormatters: [UpperMultiplicityTextInputFormatter()],
            style: TextStyle(
                color: multiplicity.isValid ? Colors.black : Colors.red),
            textAlign: TextAlign.center,
            onChanged: (value) => onMultiplicityChanged(
                UMLRelationshipMultiplicity(multiplicity.lower,
                    UMLRelationshipMultiplicity.parseComponent(value))),
          ),
        ),
      ],
    );
  }
}
