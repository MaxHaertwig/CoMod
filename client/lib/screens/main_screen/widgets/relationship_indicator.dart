import 'package:client/model/uml/uml_relationship.dart';
import 'package:client/model/uml/uml_relationship_type.dart';
import 'package:client/model/uml/uml_type.dart';
import 'package:client/screens/main_screen/widgets/type_link.dart';
import 'package:client/widgets/flipped.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
    final qualified =
        relationship.type == UMLRelationshipType.qualifiedAssociation;
    final reversed = relationship.fromID == target.id &&
        relationship.fromID != relationship.toID;
    return Column(
      children: [
        Row(
          children: [
            if (!qualified)
              _MultiplicityColumn(
                  reversed: reversed, relationship: relationship),
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
                : qualified
                    ? _QualifiedRelationshipIndicator(
                        name: relationship.name,
                        multiplicity:
                            relationship.toMultiplicity.xmlRepresentation,
                        reversed: reversed)
                    : Flipped(
                        axis: reversed ? Axis.vertical : null,
                        child: CustomPaint(
                            size: const Size(10, 40),
                            painter: relationship.type ==
                                    UMLRelationshipType.association
                                ? _VerticalLinePainter()
                                : _AggregationCompositionPainter(
                                    relationship.type))),
            if (associationClass != null) const SizedBox(width: 3),
            if (associationClass == null &&
                relationship.name.isNotEmpty &&
                !qualified)
              Column(
                children: [
                  if (relationship.type == UMLRelationshipType.association &&
                      reversed)
                    Container(
                        height: 12,
                        child: const Icon(Icons.arrow_drop_up, size: 16)),
                  Text(relationship.name, style: const TextStyle(fontSize: 10)),
                ],
              ),
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

  _AggregationCompositionPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final middle = size.width / 2;
    final diamondHeight = size.width * 1.5;
    canvas.drawLine(Offset(middle, diamondHeight),
        Offset(middle, size.height - 0), Paint());
    final path = Path()
      ..moveTo(middle, 0)
      ..lineTo(0, diamondHeight / 2)
      ..lineTo(middle, diamondHeight)
      ..lineTo(size.width, diamondHeight / 2)
      ..close();
    canvas.drawPath(
        path,
        type == UMLRelationshipType.aggregation
            ? (Paint()..color = Colors.white)
            : Paint());
    if (type == UMLRelationshipType.aggregation) {
      canvas.drawPath(path, Paint()..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      oldDelegate is _AggregationCompositionPainter && type != oldDelegate.type;
}

class _QualifiedRelationshipIndicator extends StatelessWidget {
  final String name, multiplicity;
  final bool reversed;

  _QualifiedRelationshipIndicator(
      {required this.name, required this.multiplicity, required this.reversed});

  @override
  Widget build(BuildContext context) {
    const thinBlack = BorderSide(width: 0);
    const thinGrey = BorderSide(width: 0, color: Colors.grey);
    return Column(
      verticalDirection:
          reversed ? VerticalDirection.up : VerticalDirection.down,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: reversed ? thinBlack : thinGrey,
                left: thinBlack,
                right: thinBlack,
                bottom: reversed ? thinGrey : thinBlack,
              )),
          child: Text(name.isEmpty ? '   ' : name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10)),
        ),
        multiplicity.isEmpty
            ? CustomPaint(
                size: const Size(1, 27), painter: _VerticalLinePainter())
            : Row(
                crossAxisAlignment: reversed
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Opacity(
                    opacity: 0,
                    child: Text(multiplicity,
                        style: const TextStyle(fontSize: 10)),
                  ),
                  CustomPaint(
                      size: const Size(1, 27), painter: _VerticalLinePainter()),
                  const SizedBox(width: 2),
                  Text(multiplicity, style: const TextStyle(fontSize: 10)),
                ],
              ),
      ],
    );
  }
}
