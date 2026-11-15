import 'package:flutter/material.dart';

/// Lightning bolt in a frosted rounded square — the app mark.
class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(size * 0.3),
          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        ),
        child: Icon(Icons.bolt_rounded, size: size * 0.62, color: Colors.white),
      );
}
