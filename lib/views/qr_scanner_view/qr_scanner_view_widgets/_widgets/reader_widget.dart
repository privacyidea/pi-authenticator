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
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart' as zxing;
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mutex/mutex.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:universal_io/io.dart';

class ReaderWidget extends StatefulWidget {
  final Function(Barcode) onQrCaptured;
  final Function()? onQrInvalid;

  /// The size of the QR code scanner widget.
  /// 1.0 means the full screen, 0.5 means half the screen, etc.
  final double cutOutSize;
  const ReaderWidget({
    required this.onQrCaptured,
    this.onQrInvalid,
    this.cutOutSize = 0.7,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ReaderWidgetState();
}

class _ReaderWidgetState extends State<ReaderWidget> {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR-Scanner');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildQrView(context),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder(
                    future: controller?.getFlashStatus(),
                    builder: (context, snapshot) => IconButton(
                      onPressed: () async {
                        await controller?.toggleFlash();
                        setState(() {});
                      },
                      icon: Icon(
                        snapshot.data == true ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _onGalleryButtonTapped,
                    icon: const Icon(
                      Icons.image,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    final width = MediaQuery.of(context).size.width * widget.cutOutSize;
    final height = MediaQuery.of(context).size.height * widget.cutOutSize;
    final isPortrait = width < height;
    var scanArea = isPortrait ? width : height;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(borderColor: Colors.white, borderRadius: 10, borderLength: 30, borderWidth: 6, cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      widget.onQrCaptured(scanData);
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  final _imagePickerMutex = Mutex();
  Future<void> _onGalleryButtonTapped() => _imagePickerMutex.protect(() async {
        final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (file == null) return;
        final DecodeParams params = DecodeParams(
          imageFormat: zxing.ImageFormat.rgb,
          format: zxing.Format.any,
          tryHarder: true,
          tryInverted: true,
          isMultiScan: false,
        );
        final Code result = await zx.readBarcodeImagePath(file, params);
        if (!result.isValid || result.text == null || result.text!.isEmpty) {
          widget.onQrInvalid?.call();
          return;
        }

        // final barcodeFormat = BarcodeFormat.values[result.format ?? 0];
        final Barcode barcode = Barcode(
          result.text!,
          BarcodeFormat.unknown,
          result.rawBytes,
        );
        widget.onQrCaptured(barcode);
      });
}
