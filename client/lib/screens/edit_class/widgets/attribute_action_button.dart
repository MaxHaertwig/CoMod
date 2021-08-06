import 'package:client/extensions.dart';
import 'package:client/widgets/menu_item.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';

typedef AttributeAction = Either<MoveType, int>;

class AttributeActionButton extends StatelessWidget {
  final Function(AttributeAction) onAction;

  AttributeActionButton(this.onAction);

  @override
  Widget build(BuildContext context) => PopupMenuButton<AttributeAction>(
        itemBuilder: (_) => [
          // TODO: hide move options when it's the only attribute
          MenuItem(Icons.vertical_align_top, 'Move to top',
              Left(MoveType.moveToTop)),
          MenuItem(Icons.arrow_upward, 'Move up', Left(MoveType.moveUp)),
          MenuItem(Icons.arrow_downward, 'Move down', Left(MoveType.moveDown)),
          MenuItem(Icons.vertical_align_bottom, 'Move to bottom',
              Left(MoveType.moveToBottom)),
          PopupMenuDivider(),
          MenuItem(Icons.delete, 'Delete', Right(0), isDestructive: true),
        ],
        onSelected: (AttributeAction action) => onAction(action),
      );
}
