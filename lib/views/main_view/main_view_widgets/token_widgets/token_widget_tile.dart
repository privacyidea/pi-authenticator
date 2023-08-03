import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../widgets/custom_trailing.dart';

final disableCopyOtpProvider = StateProvider<bool>((ref) => false);

class TokenWidgetTile extends StatefulWidget {
  final Widget? title;
  final List<String> subtitles;
  final Widget? leading;
  final Widget? trailing;
  final Visibility? overlay;
  final Function()? onTap;
  final bool tokenIsLocked;
  final String? tokenImage;

  const TokenWidgetTile({
    this.leading,
    this.title,
    this.subtitles = const [],
    this.trailing,
    this.overlay,
    this.onTap,
    super.key,
    this.tokenIsLocked = false,
    this.tokenImage,
  });

  @override
  State<TokenWidgetTile> createState() => _TokenWidgetTileState();
}

class _TokenWidgetTileState extends State<TokenWidgetTile> {
  late bool hasImage;

  @override
  void initState() {
    super.initState();
    hasImage = widget.tokenImage != null;
  }

  Image? _loadImage() => widget.tokenImage != null
      ? Image.network(
          widget.tokenImage!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                hasImage = false;
              });
            });
            return const SizedBox();
          },
        )
      : null;

  @override
  Widget build(BuildContext context) {
    var image = _loadImage();
    return Stack(
      children: [
        Column(
          children: [
            ListTile(
              horizontalTitleGap: 8.0,
              leading: (widget.leading != null || hasImage)
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasImage)
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: image,
                          ),
                        if (widget.leading != null) widget.leading!,
                      ],
                    )
                  : null,
              onTap: widget.onTap,
              title: widget.title,
              style: ListTileStyle.list,
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (String subtitle in widget.subtitles) Text(subtitle),
                ],
              ),
              trailing: CustomTrailing(
                child: widget.trailing ?? Container(),
              ),
            ),
          ],
        ),
        if (widget.overlay != null) widget.overlay!
      ],
    );
  }
}
