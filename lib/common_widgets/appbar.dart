
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double font_size;

  const CustomAppBar({Key? key, required this.title,this.font_size=36}) : super(key: key);  // Named parameter for 'title'

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.deepPurple[400],
      toolbarHeight: 80,
      titleTextStyle:  TextStyle(
        fontSize: font_size,
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
