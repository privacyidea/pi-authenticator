/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/tokens/token.dart';
import '../../../../../utils/encryption/token_encryption.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/app_constraints_notifier.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';

class ShowQrCodeDialog extends ConsumerWidget {
  final Token token;
  const ShowQrCodeDialog({required this.token, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appConstraits = ref.watch(appConstraintsNotifierProvider)!;
    final qrSize = min(appConstraits.maxWidth, appConstraits.maxHeight) * 0.85;
    final qrImage = Image.memory(_generateQrCodeImage(data: TokenEncryption.generateExportUri(token: token).toString()));
    return DefaultDialog(
      title: Text(AppLocalizations.of(context)!.asQrCode),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.scanThisQrWithNewDevice),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: qrSize, maxHeight: qrSize, minHeight: qrSize, minWidth: qrSize),
                child: GestureDetector(
                  onTap: () => _showQrMaximized(context, qrImage),
                  child: Image.memory(_generateQrCodeImage(data: TokenEncryption.generateExportUri(token: token).toString())),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.oneMore),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(AppLocalizations.of(context)!.done),
        ),
      ],
    );
  }

  void _showQrMaximized(BuildContext context, Image qrImage) {
    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(child: qrImage),
      ),
    );
  }

  static Uint8List _generateQrCodeImage({required String data}) {
    final qrcode = Encoder.encode(
      data,
      ErrorCorrectionLevel.l,
      hints: EncodeHints()..put<CharacterSetECI>(EncodeHintType.characterSet, CharacterSetECI.ASCII),
    );
    final matrix = qrcode.matrix!;
    const scale = 4;
    const padding = 1;

    var image = img.Image(
      width: (matrix.width + padding + padding) * scale,
      height: (matrix.height + padding + padding) * scale,
      numChannels: 4,
    );
    img.fill(image, color: img.ColorRgba8(0xFF, 0xFF, 0xFF, 0xFF));

    for (var x = 0; x < matrix.width; x++) {
      for (var y = 0; y < matrix.height; y++) {
        if (matrix.get(x, y) == 1) {
          img.fillRect(
            image,
            x1: (x + padding) * scale,
            y1: (y + padding) * scale,
            x2: (x + padding) * scale + scale - 1,
            y2: (y + padding) * scale + scale - 1,
            color: img.ColorRgba8(0, 0, 0, 0xFF),
          );
        }
      }
    }
    return img.encodePng(image);
  }
}
