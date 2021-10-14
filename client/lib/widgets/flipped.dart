import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Displays a child flipped around its y-axis.
class Flipped extends StatelessWidget {
  final Widget child;

  Flipped(this.child);

  @override
  Widget build(BuildContext context) => Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(math.pi),
        child: child,
      );
}
