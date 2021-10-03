import 'package:flutter/material.dart';

class ExpandedRow extends StatelessWidget {
  final List<Widget> children;

  ExpandedRow({required this.children});

  @override
  Widget build(BuildContext context) =>
      Row(children: children.map((widget) => Expanded(child: widget)).toList());
}
