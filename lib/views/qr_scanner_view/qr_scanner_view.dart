/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2025 NetKnights GmbH

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
import 'package:permission_handler/permission_handler.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/logger.dart';
import '../../views/view_interface.dart';
import '../../widgets/dialog_widgets/default_dialog.dart';
import 'qr_scanner_view_widgets/qr_scanner_widget.dart';

class QRScannerView extends StatefulView {
  static const routeName = '/qr_scanner';

  const QRScannerView({super.key});

  @override
  State<QRScannerView> createState() => _QRScannerViewState();

  @override
  RouteSettings get routeSettings => const RouteSettings(name: QRScannerView.routeName);
}

class _QRScannerViewState extends State<QRScannerView> {
  Future<PermissionStatus> _requestCameraPermission() => Permission.camera.request().then(
        (value) => _cameraPermission = value,
        onError: (e) {
          Logger.warning('.then(): Error while getting camera permission: $e, name: QRScannerView#_requestCameraPermission');
          return _cameraPermission = PermissionStatus.permanentlyDenied;
        },
      ).onError((e, stackTrace) {
        Logger.warning('.onError(): Error while getting camera permission: $e, name: QRScannerView#_requestCameraPermission');
        return _cameraPermission = PermissionStatus.permanentlyDenied;
      }).catchError((e) {
        Logger.warning('.catchError(): Error while getting camera permission: $e, name: QRScannerView#_requestCameraPermission');
        return _cameraPermission = PermissionStatus.permanentlyDenied;
      });

  PermissionStatus? _cameraPermission;

  @override
  Widget build(BuildContext context) => FutureBuilder<PermissionStatus>(
        future: Future<PermissionStatus>(() async => _cameraPermission ?? await _requestCameraPermission()),
        builder: (context, isGranted) {
          if (isGranted.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          return switch (isGranted.data) {
            PermissionStatus.permanentlyDenied => DefaultDialog(
                title: Text(AppLocalizations.of(context)!.grantCameraPermissionDialogTitle),
                content: Text(AppLocalizations.of(context)!.grantCameraPermissionDialogPermanentlyDenied),
              ),
            PermissionStatus.granted => SafeArea(
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  extendBodyBehindAppBar: true,
                  body: const QRScannerWidget(),
                ),
              ),
            _ => DefaultDialog(
                title: Text(AppLocalizations.of(context)!.grantCameraPermissionDialogTitle),
                content: Text(AppLocalizations.of(context)!.grantCameraPermissionDialogContent),
                actions: [
                  TextButton(
                    child: Text(AppLocalizations.of(context)!.cancel),
                    onPressed: () {
                      Navigator.pop(context, null);
                    },
                  ),
                  ElevatedButton(
                    child: Text(AppLocalizations.of(context)!.grantCameraPermissionDialogButton),
                    onPressed: () async {
                      //Trigger the permission to request it
                      final cameraPermission = await _requestCameraPermission();
                      setState(() => _cameraPermission = cameraPermission);
                    },
                  ),
                ],
              ),
          };
        },
      );
}
