import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../widgets/custom_trailing.dart';

class TokenWidgetTile extends ConsumerWidget {
  final Widget? title;
  final List<String> subtitles;
  final Widget? leading;
  final Widget? trailing;
  final Visibility? overlay;
  final List<Visibility> trailingWidgets;
  final Function()? onTap;
  final bool tokenIsLocked;

  const TokenWidgetTile({
    this.leading,
    this.title,
    this.subtitles = const [],
    this.trailing,
    this.overlay,
    this.trailingWidgets = const [],
    this.onTap,
    super.key,
    this.tokenIsLocked = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Column(
          children: [
            ListTile(
              horizontalTitleGap: 8.0,
              leading: leading,
              onTap: () => onTap?.call(),
              title: title,
              style: ListTileStyle.list,
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (String subtitle in subtitles) Text(subtitle),
                ],
              ),
              trailing: CustomTrailing(
                child: trailing ?? Container(),
              ),
            ),
            for (Visibility widget in trailingWidgets) widget,
          ],
        ),
        if (overlay != null) overlay!
      ],
    );
  }
}
