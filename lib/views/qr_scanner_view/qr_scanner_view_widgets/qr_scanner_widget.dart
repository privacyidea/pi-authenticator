/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2025 NetKnights GmbH
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
import 'package:flutter_zxing/flutter_zxing.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../../l10n/app_localizations.dart';

class QRScannerWidget extends StatefulWidget {
  /// Opens the gallery; replaceable in tests.
  final Future<XFile?> Function() pickImage;

  /// Reads a QR code from a picked image; replaceable in tests.
  final Future<Code> Function(XFile image) readQrCode;

  const QRScannerWidget({
    super.key,
    this.pickImage = _pickFromGallery,
    this.readQrCode = _readQrCode,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

Future<XFile?> _pickFromGallery() =>
    ImagePicker().pickImage(source: ImageSource.gallery);

Future<Code> _readQrCode(XFile image) => zx.readBarcodeImagePath(
  image,
  DecodeParams(imageFormat: ImageFormat.rgb, format: Format.qrCode),
);

class _QRScannerWidgetState extends State<QRScannerWidget> {
  bool isInitialized = false;

  /// True while the gallery picker is open. Opening it again cancels the
  /// pending call (iOS: multiple_request, Android: already_active), so a tap
  /// in that time is ignored.
  bool _isPickingImage = false;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.black,
    child: Semantics(
      label: isInitialized
          ? AppLocalizations.of(context)!.a11yScanQrCodeViewActive
          : AppLocalizations.of(context)!.a11yScanQrCodeViewInactive,
      child: Builder(
        builder: (context) {
          ErrorWidget.builder = (details) {
            return const SizedBox.shrink();
          };
          return ReaderWidget(
            onControllerCreated: (controller, _) {
              if (!mounted) return;
              setState(() => isInitialized = controller != null);
            },
            actionButtonsAlignment: Alignment.bottomRight,
            flashOnIcon: Semantics(
              label: AppLocalizations.of(
                context,
              )!.a11yScanQrCodeViewFlashlightOn,
              child: const Icon(Icons.flash_on),
            ),
            flashOffIcon: Semantics(
              label: AppLocalizations.of(
                context,
              )!.a11yScanQrCodeViewFlashlightOff,
              child: const Icon(Icons.flash_off),
            ),
            // The library's own gallery button opens a second picker on a
            // second tap, so the scanner brings its own button.
            showGallery: false,
            onActionSecondButton: _onGalleryButtonTapped,
            actionSecondButtonIcon: Semantics(
              label: AppLocalizations.of(context)!.a11yScanQrCodeViewGallery,
              child: const Icon(Icons.image, color: Colors.white),
            ),
            showToggleCamera: false,
            codeFormat: Format.qrCode,
            cropPercent: 0.70,
            scannerOverlay: ScannerOverlayBorder(
              overlayColor: Colors.black54,
              borderWidth: 6,
              cutOutSize: MediaQuery.of(context).size.width * 0.7,
            ),
            onScan: _onQrCaptured,
          );
        },
      ),
    ),
  );

  void _onQrCaptured(Code qrCode) {
    if (!mounted) return;
    Navigator.of(context).maybePop(qrCode.text);
  }

  Future<void> _onGalleryButtonTapped() async {
    if (_isPickingImage) return;
    _isPickingImage = true;
    try {
      final image = await widget.pickImage();
      if (image == null) return;
      final qrCode = await widget.readQrCode(image);
      if (qrCode.isValid) _onQrCaptured(qrCode);
    } finally {
      _isPickingImage = false;
    }
  }
}
