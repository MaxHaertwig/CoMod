import 'package:client/extensions.dart';
import 'package:client/widgets/menu_item.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';

typedef AttributeAction = Either<MoveType, int>;

class AttributeActionButton extends StatelessWidget {
  final Set<MoveType> _moveActions;
  final Function(AttributeAction) onAction;

  AttributeActionButton(this._moveActions, this.onAction);

  @override
  Widget build(BuildContext context) => PopupMenuButton<AttributeAction>(
        itemBuilder: (_) => [
          if (_moveActions.contains(MoveType.moveToTop))
            MenuItem(Icons.vertical_align_top, 'Move to top',
                Left(MoveType.moveToTop)),
          if (_moveActions.contains(MoveType.moveUp))
            MenuItem(Icons.arrow_upward, 'Move up', Left(MoveType.moveUp)),
          if (_moveActions.contains(MoveType.moveDown))
            MenuItem(
                Icons.arrow_downward, 'Move down', Left(MoveType.moveDown)),
          if (_moveActions.contains(MoveType.moveToBottom))
            MenuItem(Icons.vertical_align_bottom, 'Move to bottom',
                Left(MoveType.moveToBottom)),
          if (_moveActions.isNotEmpty) PopupMenuDivider(),
          MenuItem(Icons.delete, 'Delete', Right(-1), isDestructive: true),
        ],
        onSelected: onAction,
      );
}
