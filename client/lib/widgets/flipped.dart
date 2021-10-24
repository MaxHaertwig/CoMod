import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Displays a child flipped along an axis.
class Flipped extends StatelessWidget {
  final Axis? axis;
  final Widget child;

  Flipped({required this.axis, required this.child});

  @override
  Widget build(BuildContext context) => axis == Axis.horizontal
      ? Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(math.pi),
          child: child,
        )
      : axis == Axis.vertical
          ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationX(math.pi),
              child: child,
            )
          : child;
}
