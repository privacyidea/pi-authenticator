import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../widgets/custom_trailing.dart';

final disableCopyOtpProvider = StateProvider<bool>((ref) => false);

class TokenWidgetTile extends StatefulWidget {
  final Widget? title;
  final List<String> subtitles;
  final Widget? leading;
  final Widget? trailing;
  final Function()? onTap;
  final bool tokenIsLocked;
  final String? tokenImage;

  const TokenWidgetTile({
    this.leading,
    this.title,
    this.subtitles = const [],
    this.trailing,
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
    return ListTile(
      horizontalTitleGap: 8.0,
      leading: (widget.leading != null) ? widget.leading! : null,
      onTap: widget.onTap,
      title: widget.title,
      style: ListTileStyle.list,
      subtitle: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 2, right: 4),
              child: SizedBox(
                height: 50,
                width: 50,
                child: image,
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (String subtitle in widget.subtitles) Text(subtitle),
              ],
            ),
          ),
        ],
      ),
      trailing: CustomTrailing(
        child: widget.trailing ?? const SizedBox(),
      ),
    );
  }
}
