import 'package:client/extensions.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/screens/main_screen/widgets/inheritance_indicators.dart';
import 'package:client/screens/main_screen/widgets/relationship_indicators.dart';
import 'package:client/screens/main_screen/widgets/type_card.dart';
import 'package:flutter/material.dart';

typedef EditTypeFunction = void Function(BuildContext, UMLType);

/// Shows a type's UML card along with its supertypes and relationships.
class TypeSection extends StatelessWidget {
  final UMLType type;
  final UMLModel umlModel;
  final EditTypeFunction onEditType;

  const TypeSection(this.type, this.umlModel, this.onEditType, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            if (type.supertypes.isNotEmpty)
              InheritanceIndicators(
                umlType: type,
                supertypes: type.supertypes
                    .compactMap((id) => umlModel.types[id])
                    .toList(),
                onTap: (type) => onEditType(context, type),
              ),
            GestureDetector(
              child: TypeCard(type),
              onTap: () => onEditType(context, type),
            ),
            if (type.relationships.isNotEmpty)
              RelationshipIndicators(
                  type: type,
                  umlModel: umlModel,
                  onTap: (type) => onEditType(context, type)),
          ],
        ),
      );
}
