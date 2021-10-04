import 'package:client/model/uml/uml_class.dart';
import 'package:flutter/material.dart';

class InheritanceIndicator extends StatelessWidget {
  final UMLClass umlClass;

  InheritanceIndicator(this.umlClass);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Card(
            margin: EdgeInsets.only(top: 0, bottom: 2),
            elevation: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(umlClass.name,
                  style: TextStyle(
                      fontStyle: umlClass.isAbstract
                          ? FontStyle.italic
                          : FontStyle.normal)),
            ),
          ),
          CustomPaint(size: Size(18, 24), painter: _InheritancePainter()),
        ],
      );
}

class _InheritancePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final middle = size.width / 2;
    final offset = size.width / 2;
    final path = Path()
      ..moveTo(middle, 0)
      ..lineTo(0, offset)
      ..lineTo(size.width, offset)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
    canvas.drawPath(path, Paint()..style = PaintingStyle.stroke);
    canvas.drawLine(
        Offset(middle, offset), Offset(middle, size.height), Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
