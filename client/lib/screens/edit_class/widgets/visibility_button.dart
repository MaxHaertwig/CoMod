import 'package:client/model/uml/uml_visibility.dart';
import 'package:flutter/material.dart';

class VisibilityButton extends StatelessWidget {
  final UMLVisibility visibility;
  final Function(UMLVisibility)? onChanged;

  VisibilityButton(this.visibility, {this.onChanged});

  @override
  Widget build(BuildContext context) => PopupMenuButton(
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Text(
              visibility.stringRepresentation,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
          ),
        ),
        tooltip: 'Visibility',
        itemBuilder: (_) => UMLVisibility.values
            .map((v) => PopupMenuItem(
                  value: v,
                  child: Text(v.longStringRepresentation),
                ))
            .toList(),
        onSelected:
            onChanged != null ? (UMLVisibility v) => onChanged!(v) : null,
      );
}
