import 'package:flutter/material.dart';
import 'package:moalidaty1/constants/global_constants.dart';

class CustomTextBox extends StatelessWidget {
  final String title;
  final Color color;
  final double size;

  const CustomTextBox({
    super.key,
    required this.title,
    this.color = Colors.black,
    this.size = 24,
  });
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: size,
        // 24 is base size for 480 width
        color: color,
        // fontWeight: FontWeight.bold,
      ),
    );
  }
}
