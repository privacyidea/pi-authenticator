/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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
          showFlashlight: true,
          showGallery: true,
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
