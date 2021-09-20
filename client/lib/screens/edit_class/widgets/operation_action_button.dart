import 'package:client/extensions.dart';
import 'package:client/widgets/menu_item.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';

typedef OperationAction = Either<MoveType, int>;

class OperationActionButton extends StatelessWidget {
  final Function(OperationAction) onAction;

  OperationActionButton(this.onAction);

  @override
  Widget build(BuildContext context) => PopupMenuButton<OperationAction>(
        itemBuilder: (_) => [
          MenuItem(Icons.add, 'Add Parameter', Right(0)),
          PopupMenuDivider(),
          // TODO: hide move options when it's the only operation
          MenuItem(Icons.vertical_align_top, 'Move to top',
              Left(MoveType.moveToTop)),
          MenuItem(Icons.arrow_upward, 'Move up', Left(MoveType.moveUp)),
          MenuItem(Icons.arrow_downward, 'Move down', Left(MoveType.moveDown)),
          MenuItem(Icons.vertical_align_bottom, 'Move to bottom',
              Left(MoveType.moveToBottom)),
          PopupMenuDivider(),
          MenuItem(Icons.delete, 'Delete', Right(-1), isDestructive: true),
        ],
        onSelected: onAction,
      );
}
