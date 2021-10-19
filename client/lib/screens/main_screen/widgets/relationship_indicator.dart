import 'package:client/model/uml/uml_relationship.dart';
import 'package:client/model/uml/uml_relationship_type.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/screens/main_screen/widgets/type_link.dart';
import 'package:flutter/material.dart';

typedef OnTapFunction = void Function(UMLType);

/// Indicates a relationship to another type.
class RelationshipIndicator extends StatelessWidget {
  final UMLRelationship relationship;
  final UMLType target;
  final UMLType? associationClass;
  final OnTapFunction onTap;

  RelationshipIndicator(
      {required this.relationship,
      required this.target,
      required this.associationClass,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final reversed = relationship.fromID == target.id &&
        relationship.fromID != relationship.toID;
    return Column(
      children: [
        Row(
          children: [
            _MultiplicityColumn(reversed: reversed, relationship: relationship),
            if (relationship.fromMultiplicity.isNotEmpty ||
                relationship.toMultiplicity.isNotEmpty)
              const SizedBox(width: 3),
            associationClass != null
                ? Row(
                    children: [
                      CustomPaint(
                          size: const Size(1, 40),
                          painter: _VerticalLinePainter()),
                      CustomPaint(
                          size: const Size(15, 1),
                          painter: _DashedLinePainter()),
                      TypeLink(associationClass!, TypeLinkSize.small, false,
                          () => onTap(associationClass!)),
                    ],
                  )
                : CustomPaint(
                    size: const Size(10, 40),
                    painter:
                        relationship.type == UMLRelationshipType.association
                            ? _VerticalLinePainter()
                            : _AggregationCompositionPainter(
                                relationship.type, reversed)),
            if (associationClass != null) const SizedBox(width: 3),
            if (associationClass == null)
              Text(relationship.name, style: const TextStyle(fontSize: 10)),
          ],
        ),
        TypeLink(target, TypeLinkSize.regular, false, () => onTap(target)),
      ],
    );
  }
}

class _MultiplicityColumn extends StatelessWidget {
  final bool reversed;
  final UMLRelationship relationship;

  _MultiplicityColumn({required this.reversed, required this.relationship});

  @override
  Widget build(BuildContext context) => Column(
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
      );
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

/// Paints a dashed horizontal line along the middle axis of its canvas.
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(0, size.height / 2),
        Offset(size.width * 0.2, size.height / 2), Paint());
    canvas.drawLine(Offset(size.width * 0.4, size.height / 2),
        Offset(size.width * 0.6, size.height / 2), Paint());
    canvas.drawLine(Offset(size.width * 0.8, size.height / 2),
        Offset(size.width, size.height / 2), Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate is _AggregationCompositionPainter && type != oldDelegate.type;
}
