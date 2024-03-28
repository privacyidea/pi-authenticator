import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/encryption/token_encryption.dart';
import '../../../../../model/tokens/token.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';

class ShowQrCodeDialog extends ConsumerWidget {
  final Token token;
  const ShowQrCodeDialog({required this.token, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appConstraits = ref.watch(appConstraintsProvider)!;
    final qrSize = min(appConstraits.maxWidth, appConstraits.maxHeight) * 0.8;
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
                onTap: () => _showQrMaximized(context, token, qrSize / 0.8),
                child: QrImageView(
                  data: TokenEncryption.generateQrCodeUri(token: token).toString(),
                  backgroundColor: Colors.white,
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
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

  void _showQrMaximized(BuildContext context, Token token, double qrSize) {
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: qrSize, maxHeight: qrSize, minHeight: 0, minWidth: 0),
            child: QrImageView(
              data: TokenEncryption.generateQrCodeUri(token: token).toString(),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(0),
              size: qrSize,
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
