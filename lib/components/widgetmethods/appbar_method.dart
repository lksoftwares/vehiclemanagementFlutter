import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double fontSize;
  final FontWeight fontWeight;
  final Color fontColor;
  final VoidCallback? onLogout;

  @override
  final Size preferredSize;

  CustomAppBar({
    Key? key,
    this.title = 'My App',
    this.fontSize = 24.0,
    this.fontWeight = FontWeight.bold,
    this.fontColor = Colors.white,
    this.onLogout,  // Initialize onLogout
  }) : preferredSize = Size.fromHeight(56.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: fontColor,
        ),
      ),
      backgroundColor: Colors.blueAccent,
      actions: [
        if (onLogout != null)
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: onLogout,
            color: Colors.white,
          ),
      ],
    );
  }
}
