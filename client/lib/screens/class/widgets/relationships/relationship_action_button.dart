import 'package:client/widgets/menu_item.dart';
import 'package:flutter/material.dart';

typedef RelationshipActionFunction = void Function(int);

class RelationshipActionButton extends StatelessWidget {
  final RelationshipActionFunction onAction;

  RelationshipActionButton(this.onAction);

  @override
  Widget build(BuildContext context) => PopupMenuButton<int>(
        itemBuilder: (_) => [
          MenuItem(Icons.delete, 'Delete', -1, isDestructive: true),
        ],
        onSelected: onAction,
      );
}
