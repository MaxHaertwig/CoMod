import 'package:client/logic/formatters/upper_multiplicity_text_input_formatter.dart';
import 'package:client/model/uml/uml_relationship.dart';
import 'package:client/model/uml/uml_relationship_multiplicity.dart';
import 'package:client/model/uml/uml_relationship_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef MultiplicityChangedFunction = void Function(
    UMLRelationshipMultiplicity);

class MultiplicityControl extends StatefulWidget {
  final UMLRelationship relationship;
  final bool isFromMultiplicity;
  final MultiplicityChangedFunction onMultiplicityChanged;

  MultiplicityControl(
      {required this.relationship,
      required this.isFromMultiplicity,
      required this.onMultiplicityChanged});

  @override
  State<StatefulWidget> createState() =>
      _MultiplicityControlState(relationship, isFromMultiplicity);
}

class _MultiplicityControlState extends State<MultiplicityControl> {
  final _lowerTextEditingController = TextEditingController();
  final _upperTextEditingController = TextEditingController();

  _MultiplicityControlState(
      UMLRelationship relationship, bool isFromMultiplicty) {
    final multiplicity = isFromMultiplicty
        ? relationship.fromMultiplicity
        : relationship.toMultiplicity;
    _lowerTextEditingController.text =
        UMLRelationshipMultiplicity.componentString(multiplicity.lower);
    _upperTextEditingController.text =
        UMLRelationshipMultiplicity.componentString(multiplicity.upper);
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
    final enabled =
        widget.relationship.type != UMLRelationshipType.qualifiedAssociation ||
            !widget.isFromMultiplicity;
    if (!enabled) {
      // Workaround
      _lowerTextEditingController.text = '';
      _upperTextEditingController.text = '';
    }
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: TextField(
            autocorrect: false,
            controller: _lowerTextEditingController,
            decoration: multiTextFieldDecoration,
            enabled: enabled,
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
                color: !multiplicity.isValid
                    ? Colors.red
                    : enabled
                        ? Colors.black
                        : Colors.grey)),
        const SizedBox(width: 2),
        SizedBox(
          width: 20,
          child: TextField(
            autocorrect: false,
            controller: _upperTextEditingController,
            decoration: multiTextFieldDecoration,
            enabled: enabled,
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
