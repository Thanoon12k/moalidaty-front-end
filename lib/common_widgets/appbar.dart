
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);  // Named parameter for 'title'

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.deepPurple[400],
      toolbarHeight: 80,
      titleTextStyle: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 2,
      ),
      iconTheme: const IconThemeData(color: Colors.white, size: 36),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
