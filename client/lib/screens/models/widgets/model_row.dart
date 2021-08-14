import 'package:client/model/model.dart';
import 'package:client/widgets/menu_item.dart';
import 'package:flutter/material.dart';

enum ModelRowAction { rename, delete }

typedef OnTapFunction = void Function();
typedef OnActionFunction = void Function(ModelRowAction);

class ModelRow extends StatelessWidget {
  final Model model;
  final OnTapFunction onTap;
  final OnActionFunction onAction;

  ModelRow(this.model, {required this.onTap, required this.onAction});

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(
          model.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(model.uuid, style: const TextStyle(fontSize: 10)),
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
          onSelected: onAction,
        ),
        onTap: onTap,
      );
}
