import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double font_size;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.font_size = 36,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.deepPurple[400],
      toolbarHeight: 80,
      titleTextStyle: TextStyle(
        fontSize: font_size,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 2,
      ),
      iconTheme: const IconThemeData(color: Colors.white, size: 36),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
