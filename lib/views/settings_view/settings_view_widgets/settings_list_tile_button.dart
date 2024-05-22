import 'package:flutter/material.dart';

class SettingsListTileButton extends StatelessWidget {
  final void Function() onPressed;
  final Widget title;
  final Widget? icon;
  static const double tileHeight = 40;

  const SettingsListTileButton({super.key, required this.title, this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: SizedBox(
              height: tileHeight,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(child: title),
                  if (icon != null)
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minHeight: tileHeight, minWidth: tileHeight),
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
