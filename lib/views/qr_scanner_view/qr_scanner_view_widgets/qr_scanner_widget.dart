import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

class QRScannerWidget extends StatefulWidget {
  const QRScannerWidget({super.key});

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.black,
        child: ReaderWidget(
          showFlashlight: false,
          showGallery: false,
          showToggleCamera: false,
          codeFormat: Format.qrCode,
          cropPercent: 0.70,
          scannerOverlay: const FixedScannerOverlay(
            borderColor: Colors.white,
            borderWidth: 2.2,
          ),
          onScan: _onQrCaptured,
        ),
      );

  void _onQrCaptured(Code qrCode) {
    if (!mounted) return;
    Navigator.of(context).maybePop(qrCode.text);
  }
}
