import 'package:flutter/material.dart';

class AppBarItem extends StatelessWidget {
  const AppBarItem({Key? key, required this.onPressed, required this.icon}) : super(key: key);

  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(0),
      splashRadius: 0.1,
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 24,
      ),
    );
  }
}
