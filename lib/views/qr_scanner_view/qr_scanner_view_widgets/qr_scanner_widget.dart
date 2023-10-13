import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

import '../../../utils/logger.dart';
import '../../../utils/view_utils.dart';
import 'qr_code_scanner_overlay.dart';

class QRScannerWidget extends StatelessWidget {
  final _key = GlobalKey<QrCameraState>();
  QRScannerWidget({super.key});

  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            QrCamera(
              fit: BoxFit.cover,
              key: _key,
              formats: const [BarcodeFormats.QR_CODE],
              // Ignore other codes than qr codes
              onError: (context, e) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (e is PlatformException && e.message == 'noPermission') {
                    Logger.warning(
                      'QRScannerView: Camera permission not granted.',
                      name: 'QRScannerView#build#onError',
                      error: e,
                      stackTrace: StackTrace.current,
                    );
                    showMessage(message: 'Please grant camera permission to use the QR scanner.');
                  }
                  //   Navigator.pop(context, null);
                  // _key.currentState!.stop();

                  // Method must return a widget, so return one that does not display anything.
                });
                return const SizedBox();
              },
              // We have nothing to display in these cases, overwrite default
              // behaviour with 'non-visible' content.
              child: const SizedBox(),
              notStartedBuilder: (_) => const SizedBox(),
              offscreenBuilder: (_) => const SizedBox(),
              qrCodeCallback: (code) {
                Navigator.pop(context, code);
                _key.currentState!.stop();
              },
            ),
            Container(
              decoration: const ShapeDecoration(shape: ScannerOverlayShape()),
            )
          ],
        ),
      );
}
