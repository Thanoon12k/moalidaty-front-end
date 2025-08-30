import 'package:flutter/material.dart';

class GeneratorLoadingIndicator extends StatefulWidget {
  const GeneratorLoadingIndicator({super.key});

  @override
  State<GeneratorLoadingIndicator> createState() =>
      _GeneratorLoadingIndicatorState();
}

class _GeneratorLoadingIndicatorState extends State<GeneratorLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 240,
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left moving block
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final moveAnimation = Tween<double>(begin: -60, end: 0).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
                  ),
                );
                return Transform.translate(
                  offset: Offset(moveAnimation.value, 0),
                  child: Container(
                    width: 40,
                    height: 20,
                    color: Colors.blueGrey.shade300,
                  ),
                );
              },
            ),
            // Right moving block
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final moveAnimation = Tween<double>(begin: 60, end: 0).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
                  ),
                );
                return Transform.translate(
                  offset: Offset(moveAnimation.value, 0),
                  child: Container(
                    width: 40,
                    height: 20,
                    color: Colors.blueGrey.shade300,
                  ),
                );
              },
            ),
            // Center spinning part (the "generator")
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final spinAnimation = Tween<double>(
                  begin: 0,
                  end: 2 * 3.14,
                ).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(0.5, 1.0, curve: Curves.linear),
                  ),
                );
                return Transform.rotate(
                  angle: spinAnimation.value,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleWaiting extends StatelessWidget {
  const SimpleWaiting({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 240,
        height: 120,
        child: const Text("جاري التحميل..."),
      ),
    );
  }
}
