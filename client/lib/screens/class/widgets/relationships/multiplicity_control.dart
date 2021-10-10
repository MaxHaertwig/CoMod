import 'package:client/logic/upper_multiplicity_text_input_formatter.dart';
import 'package:client/model/uml/uml_relationship.dart';
import 'package:client/model/uml/uml_relationship_multiplicity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef MultiplicityChangedFunction = void Function(
    UMLRelationshipMultiplicity);

class MultiplicityControl extends StatefulWidget {
  final UMLRelationship relationship;
  final bool isFromMultiplicity;
  final MultiplicityChangedFunction onMultiplicityChanged;

  MultiplicityControl(
      this.relationship, this.isFromMultiplicity, this.onMultiplicityChanged);

  @override
  State<StatefulWidget> createState() =>
      _MultiplicityControlState(relationship, isFromMultiplicity);
}

class _MultiplicityControlState extends State<MultiplicityControl> {
  final _lowerTextEditingController = TextEditingController();
  final _upperTextEditingController = TextEditingController();

  _MultiplicityControlState(
      UMLRelationship relationship, bool isFromMultiplicty) {
    final block = (multiplicity) {
      _lowerTextEditingController.text =
          UMLRelationshipMultiplicity.componentString(multiplicity.lower);
      _upperTextEditingController.text =
          UMLRelationshipMultiplicity.componentString(multiplicity.upper);
    };
    if (isFromMultiplicty) {
      relationship.onFromMultiplicityChanged = block;
    } else {
      relationship.onToMultiplicityChanged = block;
    }
  }

  @override
  void dispose() {
    _lowerTextEditingController.dispose();
    _upperTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const multiTextFieldDecoration = InputDecoration(
        border: InputBorder.none,
        hintText: '_',
        hintStyle: TextStyle(color: Colors.grey));
    final multiplicity = widget.isFromMultiplicity
        ? widget.relationship.fromMultiplicity
        : widget.relationship.toMultiplicity;
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: TextField(
            autocorrect: false,
            controller: _lowerTextEditingController,
            decoration: multiTextFieldDecoration,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9]'))
            ],
            style: TextStyle(
                color: multiplicity.isValid ? Colors.black : Colors.red),
            textAlign: TextAlign.center,
            onChanged: (value) => widget.onMultiplicityChanged(
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
          child: TextField(
            autocorrect: false,
            controller: _upperTextEditingController,
            decoration: multiTextFieldDecoration,
            inputFormatters: [UpperMultiplicityTextInputFormatter()],
            style: TextStyle(
                color: multiplicity.isValid ? Colors.black : Colors.red),
            textAlign: TextAlign.center,
            onChanged: (value) => widget.onMultiplicityChanged(
                UMLRelationshipMultiplicity(multiplicity.lower,
                    UMLRelationshipMultiplicity.parseComponent(value))),
          ),
        ),
      ],
    );
  }
}
