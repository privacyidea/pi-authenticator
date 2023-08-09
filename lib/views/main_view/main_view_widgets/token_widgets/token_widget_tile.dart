import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../utils/logger.dart';
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
    this.tokenIsLocked = false,
    this.tokenImage,
    super.key,
  });

  @override
  State<TokenWidgetTile> createState() => _TokenWidgetTileState();
}

class _TokenWidgetTileState extends State<TokenWidgetTile> {
  late bool hasImage;
  Image? tokenImage;

  @override
  void initState() {
    super.initState();
    hasImage = widget.tokenImage != null && widget.tokenImage!.isNotEmpty;
    _loadImage();
  }

  void _loadImage() {
    if (!hasImage) return;
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          tokenImage = Image.network(
            widget.tokenImage!,
            fit: BoxFit.fitHeight,
            errorBuilder: (context, error, stackTrace) {
              if (!mounted) return const SizedBox();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  hasImage = false;
                });
              });
              return const SizedBox();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              //circle progress bar
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                ),
              );
            },
          );
        });
      });
    } catch (e) {
      Logger.warning('', error: e);
      Logger.warning(e.runtimeType.toString());
    }
  }

  @override
  Widget build(BuildContext context) => ListTile(
        horizontalTitleGap: 8.0,
        leading: (widget.leading != null) ? widget.leading! : null,
        onTap: widget.onTap,
        title: widget.title,
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 2, right: 4),
                child: SizedBox(
                  height: 32,
                  child: tokenImage ??
                      const SizedBox(
                        width: 32,
                        child: CircularProgressIndicator(),
                      ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    for (var line in widget.subtitles)
                      Text(
                        line,
                        style: Theme.of(context).listTileTheme.subtitleTextStyle,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        trailing: CustomTrailing(
          child: widget.trailing ?? const SizedBox(),
        ),
      );
}
