import 'package:flutter/material.dart';

class AppBarItem extends StatelessWidget {
  const AppBarItem({super.key, required this.onPressed, required this.icon});

  final VoidCallback onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(0),
      splashRadius: 20,
      onPressed: onPressed,
      color: Theme.of(context).navigationBarTheme.iconTheme?.resolve({})?.color,
      icon: SizedBox(
        height: 24,
        width: 24,
        child: FittedBox(child: icon),
      ),
    );
  }
}
