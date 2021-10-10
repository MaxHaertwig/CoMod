import 'package:flutter/material.dart';

class CollaborationDialog extends StatelessWidget {
  final VoidCallback onCancel;

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
