import 'package:flutter/material.dart';
import 'dart:math';

class GeneratorLoadingIndicator extends StatefulWidget {
  const GeneratorLoadingIndicator({super.key});

  @override
  State<GeneratorLoadingIndicator> createState() =>
      _GeneratorLoadingIndicatorState();
}

class _GeneratorLoadingIndicatorState extends State<GeneratorLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const int dotCount = 10;
  static const double orbitRadius = 35;

  final List<Color> dotColors = [
    Colors.yellowAccent,
    Colors.lightBlueAccent,
    Colors.amberAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildOrbitingDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle =
            (_controller.value * 2 * pi) + (index * 2 * pi / dotCount);
        final x = cos(angle) * orbitRadius;
        final y = sin(angle) * orbitRadius;

        final wave = sin((_controller.value * 2 * pi) + (index * pi / 5));
        final scale = 0.7 + 0.3 * wave;
        final opacity = 0.5 + 0.5 * wave;

        final color = dotColors[index % dotColors.length];

        return Transform.translate(
          offset: Offset(x, y),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.6),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCenterCore() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Colors.amber, Colors.blueAccent],
          center: Alignment.center,
          radius: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 6,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.flash_on, size: 16, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(dotCount, _buildOrbitingDot),
            _buildCenterCore(),
          ],
        ),
      ),
    );
  }
}
