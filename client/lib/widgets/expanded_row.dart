import 'package:flutter/material.dart';

class ExpandedRow extends StatelessWidget {
  final List<Widget> children;
  final List<int>? flex;

  ExpandedRow({required this.children, this.flex});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .asMap()
            .entries
            .map((entry) =>
                Flexible(flex: flex?[entry.key] ?? 1, child: entry.value))
            .toList(),
      );
}
