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
import 'package:permission_handler/permission_handler.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/views/view_interface.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog_button.dart';

import '../../utils/logger.dart';
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
  Future<PermissionStatus?> _requestCameraPermission() async {
    try {
      return await Permission.camera.request();
    } catch (e) {
      Logger.warning('Error while getting camera permission: $e, name: QRScannerView#_requestCameraPermission');
    }
    return null;
  }

  PermissionStatus? _cameraPermission;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.value(_cameraPermission ?? _requestCameraPermission()),
      builder: (context, isGranted) {
        if (isGranted.connectionState != ConnectionState.done) return const SizedBox();
        if (isGranted.data == PermissionStatus.permanentlyDenied) {
          return DefaultDialog(
            title: Text(AppLocalizations.of(context)!.grantCameraPermissionDialogTitle),
            content: Text(AppLocalizations.of(context)!.grantCameraPermissionDialogPermanentlyDenied),
          );
        }
        if (isGranted.data != PermissionStatus.granted) {
          return DefaultDialog(
            title: Text(AppLocalizations.of(context)!.grantCameraPermissionDialogTitle),
            content: Text(AppLocalizations.of(context)!.grantCameraPermissionDialogContent),
            actions: [
              DefaultDialogButton(
                child: Text(AppLocalizations.of(context)!.grantCameraPermissionDialogButton),
                onPressed: () async {
                  //Trigger the permission to request it
                  try {
                    final cameraPermission = await _requestCameraPermission();
                    setState(() => _cameraPermission = cameraPermission);
                  } catch (e) {
                    Logger.warning('Error while getting camera permission: $e', name: 'QRScannerView#onPressed');
                  }
                },
              ),
              DefaultDialogButton(
                child: Text(AppLocalizations.of(context)!.cancel),
                onPressed: () {
                  Navigator.pop(context, null);
                },
              ),
            ],
          );
        }
        return SafeArea(
          child: Stack(
            children: [
              const QRScannerWidget(),
              Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                extendBodyBehindAppBar: true,
                body: const SizedBox(),
              ),
            ],
          ),
        );
      },
    );
  }
}
