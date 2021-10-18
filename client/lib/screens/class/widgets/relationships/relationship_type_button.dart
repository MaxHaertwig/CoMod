import 'dart:ui';

import 'package:client/model/uml/uml_relationship_type.dart';
import 'package:client/widgets/flipped.dart';
import 'package:flutter/material.dart';

typedef OnSelectedFunction = void Function(UMLRelationshipType);

class RelationshipTypeButton extends StatelessWidget {
  final UMLRelationshipType type;
  final bool reversed;
  final OnSelectedFunction onSelected;

  RelationshipTypeButton(
      {required this.type, required this.reversed, required this.onSelected});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) => PopupMenuButton(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Flipped(
                  flipped: reversed,
                  child: CustomPaint(
                      size: Size(constraints.maxWidth, 10),
                      painter: _RelationshipTypePainter(type))),
            ),
            tooltip: 'Relationship target',
            itemBuilder: (_) => UMLRelationshipType.values
                .map((type) => PopupMenuItem(
                    value: type,
                    child: Row(children: [
                      Flipped(
                          flipped: reversed,
                          child: CustomPaint(
                              size: Size(20, 10),
                              painter: _RelationshipTypePainter(type))),
                      const SizedBox(width: 12),
                      Text(type.stringRepresentation),
                    ])))
                .toList(),
            onSelected: onSelected,
          ));
}

class _RelationshipTypePainter extends CustomPainter {
  static final strokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  final UMLRelationshipType type;

  _RelationshipTypePainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case UMLRelationshipType.association:
        canvas.drawLine(Offset(0, size.height / 2),
            Offset(size.width, size.height / 2), strokePaint);
        break;
      case UMLRelationshipType.associationWithClass:
        _drawAssociationWithClass(canvas, size);
        break;
      default:
        _drawAggregationOrComposition(canvas, size);
        break;
    }
  }

  void _drawAssociationWithClass(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, 0), Offset(size.width, 0), strokePaint);
    canvas.drawLine(Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height / 2), strokePaint);
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(size.width / 2, size.height * 0.75),
            width: size.height,
            height: size.height / 2),
        strokePaint);
  }

  void _drawAggregationOrComposition(Canvas canvas, Size size) {
    final diamondWidth = size.height * 1.5;
    canvas.drawLine(Offset(diamondWidth, size.height / 2),
        Offset(size.width, size.height / 2), strokePaint);
    if (type != UMLRelationshipType.association) {
      final path = Path()
        ..moveTo(0, size.height / 2)
        ..lineTo(diamondWidth / 2, 0)
        ..lineTo(diamondWidth, size.height / 2)
        ..lineTo(diamondWidth / 2, size.height)
        ..close();
      canvas.drawPath(path,
          type == UMLRelationshipType.aggregation ? strokePaint : Paint());
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
