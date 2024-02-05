import 'dart:ui';

import 'package:flutter/material.dart';

class DefaultDialog extends StatelessWidget {
  final bool? scrollable;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? content;

  const DefaultDialog({
    this.scrollable,
    this.title,
    this.actions,
    this.content,
    super.key,
  });

  @override
  Widget build(BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          scrollable: scrollable ?? false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
          buttonPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          insetPadding: const EdgeInsets.fromLTRB(16, 32, 16, 12),
          titlePadding: const EdgeInsets.all(12),
          contentPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          elevation: 2,
          title: title,
          actions: actions,
          content: content,
        ),
      );
}
