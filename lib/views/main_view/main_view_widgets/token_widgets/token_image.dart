/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TokenImage extends StatefulWidget {
  final String? tokenImage;
  const TokenImage({super.key, this.tokenImage});

  @override
  State<TokenImage> createState() => _TokenImageState();
}

class _TokenImageState extends State<TokenImage> {
  static final tokenImages = <String?, Uint8List?>{};
  late bool hasImage;
  Image? tokenImage;

  Future<Uint8List?> getTokenImageBytesAsync(String? tokenImageUrl) async {
    if (tokenImages.containsKey(tokenImageUrl)) {
      return tokenImages[tokenImageUrl]!;
    } else {
      if (tokenImageUrl == null || tokenImageUrl.isEmpty || Uri.tryParse(tokenImageUrl) == null) {
        tokenImages[tokenImageUrl] = null;
        return null;
      }
      final uri = Uri.parse(tokenImageUrl);
      if (uri.host == '') {
        tokenImages[tokenImageUrl] = null;
        return null;
      }
      http.Response response = await http.get(Uri.parse(tokenImageUrl));
      final newTokenImage = response.bodyBytes;
      tokenImages[tokenImageUrl] = newTokenImage;
      return newTokenImage;
    }
  }

  Uint8List? getTokenImageBytesSync(String? tokenImageUrl) {
    final bytes = tokenImages[tokenImageUrl];
    if (bytes != null) return bytes;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadImage());
    return null;
  }

  void _updateImageWidget() {
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

  @override
  void initState() {
    super.initState();
    _updateImageWidget();
  }

  @override
  void didUpdateWidget(TokenImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tokenImage != widget.tokenImage) {
      _updateImageWidget();
    }
  }

  void _loadImage() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final uint8List = await getTokenImageBytesAsync(widget.tokenImage);
      if (!mounted) return;
      if (uint8List == null) {
        setState(() => hasImage = false);
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
                  child: CircularProgressIndicator.adaptive(),
                ),
          ))
      : const SizedBox();
}
