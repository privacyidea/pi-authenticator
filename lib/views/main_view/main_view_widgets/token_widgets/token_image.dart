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
  static final tokenImages = <String, Uint8List?>{};
  late bool hasImage;
  Image? tokenImage;

  Future<Uint8List?> _getTokenImageBytesAsync(String? tokenImageUrl) async {
    if (tokenImageUrl == null) return null;
    if (tokenImages.containsKey(tokenImageUrl)) {
      return tokenImages[tokenImageUrl];
    }
    final uri = Uri.tryParse(tokenImageUrl);
    if (uri == null) {
      tokenImages[tokenImageUrl] = null;
      return null;
    }
    try {
      http.Response response = await http.get(Uri.parse(tokenImageUrl));
      final newTokenImage = response.bodyBytes;
      _createImage(newTokenImage);
      tokenImages[tokenImageUrl] = newTokenImage;
      return newTokenImage;
    } catch (e) {
      tokenImages[tokenImageUrl] = null;
      return null;
    }
  }

  Uint8List? _getTokenImageBytesSync(String? tokenImageUrl) {
    final bytes = tokenImages[tokenImageUrl];
    if (bytes != null) return bytes;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadImage());
    return null;
  }

  void _updateImageWidget() {
    hasImage = widget.tokenImage != null && widget.tokenImage!.isNotEmpty;
    final imageBytes = _getTokenImageBytesSync(widget.tokenImage);
    if (imageBytes != null) {
      tokenImage = _createImage(imageBytes);
    } else {
      _loadImage();
    }
  }

  Image _createImage(Uint8List uint8List) => Image.memory(
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
      final uint8List = await _getTokenImageBytesAsync(widget.tokenImage);
      if (!mounted) return;
      if (uint8List == null) {
        setState(() => hasImage = false);
        return;
      }
      setState(() {
        tokenImage = _createImage(uint8List);
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
