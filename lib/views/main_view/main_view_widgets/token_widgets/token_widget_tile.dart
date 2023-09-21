import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../widgets/custom_trailing.dart';

final disableCopyOtpProvider = StateProvider<bool>((ref) => false);

class TokenWidgetTile extends StatelessWidget {
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
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        horizontalTitleGap: 8.0,
        leading: (leading != null) ? leading! : null,
        onTap: onTap,
        title: title,
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TokenImage(tokenImage: tokenImage),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    for (var line in subtitles)
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
          child: trailing ?? const SizedBox(),
        ),
      );
}

final tokenImages = <String?, Uint8List?>{};

Future<Uint8List?> getTokenImageBytesAsync(String? tokenImageUrl) async {
  if (tokenImages.containsKey(tokenImageUrl)) {
    return tokenImages[tokenImageUrl]!;
  } else {
    if (tokenImageUrl == null || tokenImageUrl.isEmpty || Uri.tryParse(tokenImageUrl) == null) {
      tokenImages[tokenImageUrl] = null;
      return null;
    }
    http.Response response;
    try {
      response = await http.get(Uri.parse(tokenImageUrl));
    } catch (e) {
      return null;
    }
    final newTokenImage = response.bodyBytes;
    tokenImages[tokenImageUrl] = newTokenImage;
    return newTokenImage;
  }
}

Uint8List? getTokenImageBytesSync(String? tokenImageUrl) => tokenImages[tokenImageUrl];

class TokenImage extends StatefulWidget {
  final String? tokenImage;
  const TokenImage({super.key, this.tokenImage});

  @override
  State<TokenImage> createState() => _TokenImageState();
}

class _TokenImageState extends State<TokenImage> {
  late bool hasImage;
  Image? tokenImage;

  @override
  void initState() {
    super.initState();
    hasImage = widget.tokenImage != null && widget.tokenImage!.isNotEmpty;
    final imageBytes = getTokenImageBytesSync(widget.tokenImage);
    if (imageBytes != null) {
      tokenImage = Image.memory(
        imageBytes,
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
      );
    } else {
      _loadImage();
    }
  }

  void _loadImage() {
    if (!hasImage || tokenImage != null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final uint8List = await getTokenImageBytesAsync(widget.tokenImage);
      if (uint8List == null) {
        setState(() {
          hasImage = false;
        });
        return;
      }
      setState(() {
        tokenImage = Image.memory(
          uint8List,
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
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) => hasImage
      ? Padding(
          padding: const EdgeInsets.only(left: 4, top: 2, right: 4),
          child: SizedBox(
            height: 32,
            child: tokenImage ??
                const SizedBox(
                  width: 32,
                  child: CircularProgressIndicator(),
                ),
          ))
      : const SizedBox();
}
