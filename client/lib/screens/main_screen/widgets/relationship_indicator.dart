import 'package:client/model/uml/uml_relationship.dart';
import 'package:client/model/uml/uml_relationship_type.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/model/uml/uml_type_type.dart';
import 'package:flutter/material.dart';

/// Indicates a relationship to another type.
class RelationshipIndicator extends StatelessWidget {
  final UMLRelationship relationship;
  final UMLType target;
  final VoidCallback onTap;

  RelationshipIndicator(this.relationship, this.target, this.onTap);

  @override
  Widget build(BuildContext context) {
    final reversed = relationship.fromID == target.id &&
        relationship.fromID != relationship.toID;
    return Column(
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 4),
                Text(
                    (reversed
                            ? relationship.toMultiplicity
                            : relationship.fromMultiplicity)
                        .xmlRepresentation,
                    style: const TextStyle(fontSize: 10)),
                const SizedBox(height: 10),
                Text(
                    (reversed
                            ? relationship.fromMultiplicity
                            : relationship.toMultiplicity)
                        .xmlRepresentation,
                    style: const TextStyle(fontSize: 10)),
                const SizedBox(height: 4),
              ],
            ),
            const SizedBox(width: 4),
            CustomPaint(
                size: Size(10, 40),
                painter: relationship.type == UMLRelationshipType.association
                    ? _VerticalLinePainter()
                    : _AggregationCompositionPainter(
                        relationship.type, reversed)),
            const SizedBox(width: 4),
            Text(relationship.name, style: const TextStyle(fontSize: 10)),
          ],
        ),
        GestureDetector(
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 0),
            elevation: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(target.name,
                  style: TextStyle(
                      fontStyle: target.type == UMLTypeType.abstractClass
                          ? FontStyle.italic
                          : FontStyle.normal)),
            ),
          ),
          onTap: onTap,
        ),
      ],
    );
  }
}

/// Paints an aggregation or composition relationship.
class _AggregationCompositionPainter extends CustomPainter {
  final UMLRelationshipType type;
  final bool reversed;

  _AggregationCompositionPainter(this.type, this.reversed);

  @override
  void paint(Canvas canvas, Size size) {
    final middle = size.width / 2;
    final diamondHeight = size.width * 1.5;
    canvas.drawLine(Offset(middle, reversed ? 0 : diamondHeight),
        Offset(middle, size.height - (reversed ? diamondHeight : 0)), Paint());
    final double diamondStart = reversed ? size.height - diamondHeight : 0;
    final path = Path()
      ..moveTo(middle, diamondStart)
      ..lineTo(0, diamondStart + diamondHeight / 2)
      ..lineTo(middle, diamondStart + diamondHeight)
      ..lineTo(size.width, diamondStart + diamondHeight / 2)
      ..close();
    canvas.drawPath(
        path,
        type == UMLRelationshipType.aggregation
            ? (Paint()..style = PaintingStyle.stroke)
            : Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paints a vertical line along the center axis of its canvas.
class _VerticalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height), Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
