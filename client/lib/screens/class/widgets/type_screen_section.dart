import 'package:flutter/material.dart';

class TypeScreenSection extends StatelessWidget {
  final String title, addButtonTitle;
  final List<Widget> children;
  final VoidCallback onAddButtonPressed;

  TypeScreenSection(this.title, this.addButtonTitle,
      {required this.children, required this.onAddButtonPressed});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...children,
          TextButton(
            child: Text(addButtonTitle, textAlign: TextAlign.center),
            onPressed: onAddButtonPressed,
          ),
        ],
      );
}
