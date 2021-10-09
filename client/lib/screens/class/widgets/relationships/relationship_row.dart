import 'package:client/logic/diff_text_input_formatter.dart';
import 'package:client/model/model.dart';
import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_relationship.dart';
import 'package:client/model/uml/uml_relationship_type.dart';
import 'package:client/screens/class/widgets/relationships/multiplicity_control.dart';
import 'package:client/screens/class/widgets/relationships/relationship_action_button.dart';
import 'package:client/screens/class/widgets/relationships/relationship_type_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

typedef EditRelationshipFunction = void Function(UMLRelationship);

class RelationshipRow extends StatelessWidget {
  final UMLRelationship relationship;

  const RelationshipRow(this.relationship, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Selector<Model, UMLModel>(
      selector: (_, model) => model.umlModel,
      shouldRebuild: (previous, next) => next != previous,
      builder: (context, umlModel, __) {
        final isAssociationWithClass =
            relationship.type == UMLRelationshipType.associationWithClass;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const SizedBox(width: 12),
              MultiplicityControl(
                  relationship.fromMultiplicity,
                  (multiplicity) =>
                      relationship.fromMultiplicity = multiplicity),
              Expanded(
                child: Container(
                  height: isAssociationWithClass ? 40 : 36,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          width: 80,
                          height: 20,
                          child: isAssociationWithClass
                              ? PopupMenuButton(
                                  child: Text(
                                      umlModel
                                          .types[
                                              relationship.associationClassID]!
                                          .name,
                                      textAlign: TextAlign.center,
                                      style:
                                          const TextStyle(color: Colors.blue)),
                                  itemBuilder: (_) => umlModel.types.values
                                      .map((type) => PopupMenuItem(
                                          value: type.id,
                                          child: Text(type.name)))
                                      .toList(),
                                  onSelected: (String id) =>
                                      relationship.associationClassID = id,
                                )
                              : TextFormField(
                                  autocorrect: false,
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'label',
                                      hintStyle: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                  initialValue: relationship.name,
                                  inputFormatters: [
                                    DiffTextInputFormatter(
                                        (f) => f(relationship))
                                  ],
                                ),
                        ),
                      ),
                      RelationshipTypeButton(
                          relationship.type,
                          (newType) => relationship.setType(
                              newType,
                              newType ==
                                      UMLRelationshipType.associationWithClass
                                  ? umlModel.types.values.first.id
                                  : '')),
                    ],
                  ),
                ),
              ),
              MultiplicityControl(relationship.toMultiplicity,
                  (multiplicity) => relationship.toMultiplicity = multiplicity),
              const SizedBox(width: 8),
              PopupMenuButton(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.all(8),
                  child: Center(
                    child: Text(
                      umlModel.types[relationship.toID]!.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                tooltip: 'Relationship target',
                itemBuilder: (_) => umlModel.types.values
                    .map((type) =>
                        PopupMenuItem(value: type.id, child: Text(type.name)))
                    .toList(),
                onSelected: (String id) => relationship.toID = id,
              ),
              RelationshipActionButton(
                  (_) => umlModel.removeRelationship(relationship)),
            ],
          ),
        );
      });
}
