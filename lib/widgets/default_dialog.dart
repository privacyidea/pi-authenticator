import 'package:flutter/material.dart';

class DefaultDialog extends StatelessWidget {
  final bool? scrollable;
  final Widget? title;
  final List<Widget>? actions;
  final Widget? content;

  const DefaultDialog({super.key, this.scrollable, this.title, this.actions, this.content});

  @override
  Widget build(BuildContext context) => AlertDialog(
        scrollable: scrollable ?? false,
        actionsPadding: const EdgeInsets.all(0.0),
        buttonPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
        titlePadding: const EdgeInsets.all(12),
        contentPadding: const EdgeInsets.all(0),
        title: title,
        actions: actions,
        content: content,
      );
}
