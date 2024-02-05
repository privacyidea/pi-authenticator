import 'package:flutter/material.dart';

class SettingsListTileButton extends StatelessWidget {
  final void Function() onPressed;
  final Widget? title;
  final Widget? icon;

  const SettingsListTileButton({super.key, this.title, this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: SizedBox(
              height: 40,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (title != null) title!,
                  if (icon != null)
                    IconButton(
                      onPressed: onPressed,
                      splashRadius: 26,
                      icon: icon!,
                    )
                ],
              ),
            ),
          ),
        ),
      );
}
