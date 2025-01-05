import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback pressed;
  final Color backgroundColor;
  final Color iconColor;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.pressed,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: pressed,
      icon: Icon(icon, color: Colors.black87),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        fixedSize: MaterialStateProperty.all(const Size(50, 50)),
      ),
    );
  }
}
