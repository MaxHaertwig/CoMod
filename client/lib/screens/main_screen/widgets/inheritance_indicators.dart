import 'package:client/model/uml/uml_type.dart';
import 'package:client/screens/main_screen/widgets/inheritance_indicator.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

typedef OnTapFunction = void Function(UMLType);

// TODO: opt. show hierarchy up to root
class InheritanceIndicators extends StatelessWidget {
  final UMLType umlType;
  final List<UMLType> supertypes;
  final OnTapFunction onTap;

  InheritanceIndicators(this.umlType, this.supertypes, this.onTap);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: supertypes
              .map((supertype) =>
                  Tuple2(supertype, umlType.inheritanceRelationTo(supertype)))
              .where((tuple) => tuple.item2 != null)
              .map((tuple) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    child: InheritanceIndicator(
                        tuple.item1, tuple.item2!, () => onTap(tuple.item1)),
                  ))
              .toList(),
        ),
      );
}
