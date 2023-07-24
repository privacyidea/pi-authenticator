/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2023 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'package:flutter/material.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

import 'qr_scanner_view_widgets/qr_code_scanner_overlay.dart';

class QRScannerView extends StatelessWidget {
  static const routeName = '/qr_scanner';

  final _key = GlobalKey<QrCameraState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () {
              Navigator.pop(context, null);
            }),
      ),
      extendBodyBehindAppBar: true,
      body: SizedBox.expand(
        child: Stack(
          children: [
            QrCamera(
              fit: BoxFit.cover,
              key: _key,
              formats: [BarcodeFormats.QR_CODE],
              // Ignore other codes than qr codes
              onError: (context, _) {
                Navigator.pop(context, null);
                _key.currentState!.stop();

                // Method must return a widget, so return one that does not display anything.
                return Text('');
              },
              // We have nothing to display in these cases, overwrite default
              // behaviour with 'non-visible' content.
              child: Text(''),
              notStartedBuilder: (_) => Text(''),
              offscreenBuilder: (_) => Text(''),
              qrCodeCallback: (code) {
                Navigator.pop(context, code);
                _key.currentState!.stop();
              },
            ),
            Container(
              decoration: ShapeDecoration(shape: ScannerOverlayShape()),
            )
          ],
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
