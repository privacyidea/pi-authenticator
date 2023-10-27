import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'qr_code_scanner_overlay.dart';

class QRScannerWidget extends StatefulWidget {
  // final _key = GlobalKey<QrCameraState>();
  const QRScannerWidget({super.key});

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  bool alreadyDetected = false;
  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            MobileScanner(
              fit: BoxFit.contain,
              controller: MobileScannerController(
                // facing: CameraFacing.back,
                // torchEnabled: false,
                returnImage: false,
              ),
              onDetect: (capture) {
                if (alreadyDetected) return;
                alreadyDetected = true;
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  debugPrint('Barcode found! ${barcode.rawValue}');
                }

                Navigator.pop(context, barcodes.first.rawValue);
              },
            ),
            Container(
              decoration: const ShapeDecoration(shape: ScannerOverlayShape()),
            )
          ],
        ),
      );
}
