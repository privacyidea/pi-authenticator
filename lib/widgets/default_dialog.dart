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
        child: Center(
          child: AlertDialog(
            scrollable: scrollable ?? false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
            buttonPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            titlePadding: const EdgeInsets.all(12),
            contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            elevation: 0,
            title: title,
            actions: actions,
            content: content,
          ),
        ),
      );
}
