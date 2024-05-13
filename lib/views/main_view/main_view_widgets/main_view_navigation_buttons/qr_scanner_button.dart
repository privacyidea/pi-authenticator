import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../mains/main_customizer.dart';
import '../../../../utils/globals.dart';
import '../../../../utils/riverpod_providers.dart';
import '../../../../utils/view_utils.dart';
import '../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../qr_scanner_view/qr_scanner_view.dart';

class QrScannerButton extends ConsumerWidget {
  const QrScannerButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            useRootNavigator: false,
            routeSettings: const RouteSettings(name: QRScannerView.routeName),
            builder: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
          );
          if (await Permission.camera.isPermanentlyDenied) {
            showAsyncDialog(
              builder: (_) => DefaultDialog(
                title: Text(AppLocalizations.of(context)!.grantCameraPermissionDialogTitle),
                content: Text(AppLocalizations.of(context)!.grantCameraPermissionDialogPermanentlyDenied),
              ),
            );
            return;
          }
          if (globalNavigatorKey.currentContext == null) return;

          /// Open the QR-code scanner and call `handleQrCode`, with the scanned code as the argument.
          Navigator.pushNamed(globalNavigatorKey.currentContext!, QRScannerView.routeName).then((qrCode) {
            if (qrCode != null) ref.read(tokenProvider.notifier).handleQrCode(qrCode);
          });
        },
        tooltip: '${AppLocalizations.of(context)!.scanQrCode} (Counter: $globalCounter)',
        child: const Icon(Icons.qr_code_scanner_outlined),
      );
}
