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
import 'package:privacyidea_authenticator/utils/view_utils.dart';

import '../../../../../../../l10n/app_localizations.dart';
import '_widgets/reader_widget.dart';

class QRScannerWidget extends StatefulWidget {
  const QRScannerWidget({super.key});

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  bool isInitialized = false;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.black,
        child: Semantics(
          label: isInitialized ? AppLocalizations.of(context)!.a11yScanQrCodeViewActive : AppLocalizations.of(context)!.a11yScanQrCodeViewInactive,
          child: ReaderWidget(
            onQrCaptured: (barcode) {
              if (!mounted) return;
              Navigator.of(context).maybePop(barcode.code);
            },
            onQrInvalid: () {
              if (!mounted) return;
              showErrorStatusMessage(
                message: (l) => l.qrFileDecodeError,
              );
            },
          ),
        ),
      );
}
