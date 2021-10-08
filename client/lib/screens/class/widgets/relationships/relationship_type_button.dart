import 'dart:ui';

import 'package:client/model/uml/uml_relationship_type.dart';
import 'package:flutter/material.dart';

typedef OnSelectedFunction = void Function(UMLRelationshipType);

class RelationshipTypeButton extends StatelessWidget {
  final UMLRelationshipType type;
  final OnSelectedFunction onSelected;

  RelationshipTypeButton(this.type, this.onSelected);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) => PopupMenuButton(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: CustomPaint(
                  size: Size(constraints.maxWidth, 10),
                  painter: _RelationshipTypePainter(type)),
            ),
            tooltip: 'Relationship target',
            itemBuilder: (_) => UMLRelationshipType.values
                .map((type) => PopupMenuItem(
                    value: type,
                    child: Row(children: [
                      CustomPaint(
                          size: Size(20, 10),
                          painter: _RelationshipTypePainter(type)),
                      const SizedBox(width: 12),
                      Text(type.stringRepresentation),
                    ])))
                .toList(),
            onSelected: onSelected,
          ));
}

class _RelationshipTypePainter extends CustomPainter {
  final UMLRelationshipType type;

  _RelationshipTypePainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final diamondWidth = size.height * 1.5;
    canvas.drawLine(
        Offset(type == UMLRelationshipType.association ? 0 : diamondWidth,
            size.height / 2),
        Offset(size.width, size.height / 2),
        Paint()..strokeWidth = 1);
    if (type != UMLRelationshipType.association) {
      final path = Path()
        ..moveTo(0, size.height / 2)
        ..lineTo(diamondWidth / 2, 0)
        ..lineTo(diamondWidth, size.height / 2)
        ..lineTo(diamondWidth / 2, size.height)
        ..close();
      canvas.drawPath(
          path,
          type == UMLRelationshipType.aggregation
              ? (Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1)
              : Paint());
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
