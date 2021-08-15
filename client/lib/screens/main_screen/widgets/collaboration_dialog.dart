import 'package:flutter/material.dart';

typedef OnCancelFunction = void Function();

class CollaborationDialog extends StatelessWidget {
  final OnCancelFunction onCancel;

  CollaborationDialog({required this.onCancel});

  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Joining collaboration session...'),
        content: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: onCancel,
          ),
        ],
      );
}
