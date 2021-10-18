import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Displays a child flipped horizontally.
class Flipped extends StatelessWidget {
  final bool flipped;
  final Widget child;

  Flipped({required this.flipped, required this.child});

  @override
  Widget build(BuildContext context) => flipped
      ? Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(math.pi),
          child: child,
        )
      : child;
}
