import 'package:client/model/constants.dart';
import 'package:client/model/uml/uml_visibility.dart';
import 'package:flutter/material.dart';

typedef OnChangedFunction = void Function(UMLVisibility);

class VisibilityButton extends StatelessWidget {
  final UMLVisibility visibility;
  final OnChangedFunction? onChanged;

  VisibilityButton(this.visibility, {this.onChanged});

  @override
  Widget build(BuildContext context) => PopupMenuButton(
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Text(
              visibility.symbol,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: appColor),
            ),
          ),
        ),
        tooltip: 'Visibility',
        itemBuilder: (_) => UMLVisibility.values
            .map((v) => PopupMenuItem(
                  value: v,
                  child: Text(v.stringRepresentation),
                ))
            .toList(),
        onSelected: onChanged,
      );
}
