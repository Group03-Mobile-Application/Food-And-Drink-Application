import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback pressed;
  final Color? iconColor; // Add optional iconColor

  const MyIconButton({super.key,
    required this.icon,
    required this.pressed,
    this.iconColor,  // add to constructor
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: pressed,
        icon: Icon(
          icon,
          color: iconColor ?? Colors.black, // Use provided color or default
        ));
  }
}