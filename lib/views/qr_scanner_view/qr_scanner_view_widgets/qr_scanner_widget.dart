import 'package:flutter/material.dart';
import 'package:zxing_scanner/zxing_scanner.dart';

import 'qr_code_scanner_overlay.dart';

class QRScannerWidget extends StatefulWidget {
  const QRScannerWidget({super.key});

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  void _navigatorReturn(String qrCode) {
    if (!mounted) return;
    Navigator.of(context).maybePop(qrCode);
  }

  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            ScanView(
              autoStart: false,
              onResult: (p0) {
                if (p0.isEmpty) return;
                _navigatorReturn(p0.first.text);
              },
            ),
            Container(
              decoration: const ShapeDecoration(shape: ScannerOverlayShape()),
            )
          ],
        ),
      );
}
