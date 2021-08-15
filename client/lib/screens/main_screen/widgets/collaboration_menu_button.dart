import 'package:client/widgets/menu_item.dart';
import 'package:flutter/material.dart';

typedef OnSelectedFunction = void Function(int);

class CollaborationMenuButton extends StatelessWidget {
  final bool isSessionInProgress;
  final OnSelectedFunction onSelected;

  CollaborationMenuButton(this.isSessionInProgress, {required this.onSelected});

  // Icon choices: group_add, person_add, group_work, people, compass_calibration, device_hub, record_voice_over
  @override
  Widget build(BuildContext context) => isSessionInProgress
      ? PopupMenuButton(
          icon: const Icon(Icons.group),
          tooltip: 'Collaboration',
          itemBuilder: (_) => [
            MenuItem(Icons.cancel_outlined, 'Stop collaborating', 0),
          ],
          onSelected: onSelected,
        )
      : PopupMenuButton(
          icon: const Icon(Icons.group_add),
          tooltip: 'Collaboration',
          itemBuilder: (_) => [
            MenuItem(Icons.group_add, 'Collaborate', 0),
          ],
          onSelected: onSelected,
        );
}
