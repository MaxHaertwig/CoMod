import 'package:client/model/uml/uml_type.dart';
import 'package:client/screens/main_screen/widgets/inheritance_indicator.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class InheritanceIndicators extends StatelessWidget {
  final UMLType _umlType;
  final List<UMLType> _supertypes;

  InheritanceIndicators(UMLType umlType, List<UMLType> supertypes)
      : _umlType = umlType,
        _supertypes = supertypes;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _supertypes
              .map((supertype) =>
                  Tuple2(supertype, _umlType.inheritanceRelationTo(supertype)))
              .where((tuple) => tuple.item2 != null)
              .map((tuple) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 3),
                    child: InheritanceIndicator(tuple.item1, tuple.item2!),
                  ))
              .toList(),
        ),
      );
}
