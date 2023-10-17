import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../utils/riverpod_providers.dart';
import '../../../../utils/view_utils.dart';
import '../../../../widgets/default_dialog.dart';
import '../../../qr_scanner_view/qr_scanner_view.dart';

class QrScannerButton extends ConsumerWidget {
  const QrScannerButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => FloatingActionButton(
        onPressed: () async {
          if (await Permission.camera.isPermanentlyDenied) {
            showAsyncDialog(
              builder: (_) => DefaultDialog(
                title: Text(AppLocalizations.of(context)!.grantCameraPermissionDialogTitle),
                content: Text(AppLocalizations.of(context)!.grantCameraPermissionDialogPermanentlyDenied),
              ),
            );
            return;
          }

          /// Open the QR-code scanner and call `_handleOtpAuth`, with the scanned code as the argument.
          // ignore: use_build_context_synchronously
          Navigator.pushNamed(context, QRScannerView.routeName).then((qrCode) {
            if (qrCode != null) ref.read(tokenProvider.notifier).addTokenFromOtpAuth(otpAuth: qrCode as String);
          });
        },
        tooltip: AppLocalizations.of(context)?.scanQrCode ?? '',
        child: const Icon(Icons.qr_code_scanner_outlined),
      );
}
