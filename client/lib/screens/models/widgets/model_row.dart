import 'package:client/widgets/menu_item.dart';
import 'package:flutter/material.dart';

enum ModelRowAction { rename, delete }

typedef OnTapFunction = void Function();
typedef OnActionFunction = void Function(ModelRowAction);

class ModelRow extends StatelessWidget {
  final String name;
  final OnTapFunction onTap;
  final OnActionFunction onAction;

  ModelRow(this.name, {required this.onTap, required this.onAction});

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(name),
        trailing: PopupMenuButton<ModelRowAction>(
          tooltip: 'Model actions',
          itemBuilder: (_) => [
            MenuItem(
              Icons.drive_file_rename_outline,
              'Rename',
              ModelRowAction.rename,
            ),
            PopupMenuDivider(),
            MenuItem(
              Icons.delete,
              'Delete',
              ModelRowAction.delete,
              isDestructive: true,
            ),
          ],
          onSelected: (ModelRowAction action) => onAction(action),
        ),
        onTap: onTap,
      );
}
