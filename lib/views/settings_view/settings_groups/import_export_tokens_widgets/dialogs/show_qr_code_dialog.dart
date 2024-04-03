import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zxing2/qrcode.dart';
import 'package:image/image.dart' as img;

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/encryption/token_encryption.dart';
import '../../../../../model/tokens/token.dart';
import '../../../../../utils/logger.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';

class ShowQrCodeDialog extends ConsumerWidget {
  final Token token;
  const ShowQrCodeDialog({required this.token, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appConstraits = ref.watch(appConstraintsProvider)!;
    final qrSize = min(appConstraits.maxWidth, appConstraits.maxHeight) * 0.8;
    final qrImage = Image.memory(_generateQrCodeImage(data: TokenEncryption.generateQrCodeUri(token: token).toString()));
    return DefaultDialog(
      title: Text(AppLocalizations.of(context)!.asQrCode),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.scanThisQrWithNewDevice),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: qrSize, maxHeight: qrSize, minHeight: qrSize, minWidth: qrSize),
              child: GestureDetector(
                onTap: () => _showQrMaximized(context, qrImage),
                child: Image.memory(_generateQrCodeImage(data: TokenEncryption.generateQrCodeUri(token: token).toString())),
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
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(child: qrImage),
      ),
    );
  }

  static Uint8List _generateQrCodeImage({required String data}) {
    Logger.info('$data');
    final qrcode = Encoder.encode(data, ErrorCorrectionLevel.m);
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
