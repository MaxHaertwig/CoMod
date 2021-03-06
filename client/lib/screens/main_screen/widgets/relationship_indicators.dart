import 'package:client/model/uml/uml_model.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/screens/main_screen/widgets/relationship_indicator.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

typedef OnTapFunction = void Function(UMLType);

/// Shows a type's relationships in a horizontally scrolling list.
class RelationshipIndicators extends StatelessWidget {
  final UMLType type;
  final UMLModel umlModel;
  final OnTapFunction onTap;

  RelationshipIndicators(
      {required this.type, required this.umlModel, required this.onTap});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: type.relationships
              .map((rel) => Tuple2(
                  rel,
                  umlModel
                      .types[rel.fromID == type.id ? rel.toID : rel.fromID]))
              .where((tuple) => tuple.item2 != null)
              .map((tuple) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  child: RelationshipIndicator(
                      relationship: tuple.item1,
                      target: tuple.item2!,
                      associationClass: tuple.item1.associationClassID.isEmpty
                          ? null
                          : umlModel.types[tuple.item1.associationClassID],
                      onTap: onTap)))
              .toList(),
        ),
      );
}
