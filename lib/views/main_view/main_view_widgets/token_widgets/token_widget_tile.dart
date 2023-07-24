import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TokenWidgetTile extends ConsumerWidget {
  final Widget? title;
  final List<String> subtitles;
  final Widget? leading;
  final Widget? trailing;
  final Visibility? overlay;
  final List<Visibility> trailingWidgets;
  final Function()? onTap;

  const TokenWidgetTile({
    this.leading,
    this.title,
    this.subtitles = const [],
    this.trailing,
    this.overlay,
    this.trailingWidgets = const [],
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRect(
      child: Stack(
        children: [
          Column(
            children: [
              ListTile(
                horizontalTitleGap: 8.0,
                leading: leading,
                onTap: () => onTap?.call(),
                title: title,
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (String subtitle in subtitles) Text(subtitle),
                  ],
                ),
                trailing: Container(
                  margin: EdgeInsets.only(right: 20.0),
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: MediaQuery.of(context).size.width * 0.15,
                  child: trailing,
                ),
              ),
              for (Visibility widget in trailingWidgets) widget,
            ],
          ),
          if (overlay != null) overlay!
        ],
      ),
    );
  }
}
