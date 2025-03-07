import 'dart:ui';

import 'package:flutter/material.dart';

class DefaultDialog extends StatelessWidget {
  final bool? scrollable;
  final Widget? title;
  final List<Widget>? actions;
  final MainAxisAlignment? actionsAlignment;
  final Widget? content;
  final bool hasCloseButton;
  final double closeButtonSize;

  const DefaultDialog({
    this.scrollable,
    this.title,
    this.actions,
    this.actionsAlignment,
    this.content,
    this.hasCloseButton = false,
    this.closeButtonSize = 22,
    super.key,
  });

  @override
  Widget build(BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          actionsAlignment: actionsAlignment ?? MainAxisAlignment.end,
          scrollable: scrollable ?? false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          buttonPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          insetPadding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
          titlePadding: const EdgeInsets.all(10),
          contentPadding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          contentTextStyle: Theme.of(context).textTheme.bodyMedium,
          elevation: 2,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.titleLarge!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  child: title ?? const SizedBox(),
                ),
              ),
              if (hasCloseButton)
                SizedBox(
                  width: closeButtonSize,
                  height: closeButtonSize,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.close, size: closeButtonSize),
                    splashRadius: closeButtonSize,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
            ],
          ),
          actions: actions,
          content: DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyLarge!,
            child: SingleChildScrollView(child: content),
          ),
        ),
      );
}
