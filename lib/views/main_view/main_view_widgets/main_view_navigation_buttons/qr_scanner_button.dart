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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../model/processor_result.dart';
import '../../../../utils/globals.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../../../utils/utils.dart';
import '../../../../utils/view_utils.dart';
import '../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../qr_scanner_view/qr_scanner_view.dart';

class QrScannerButton extends ConsumerWidget {
  const QrScannerButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => FloatingActionButton(
        onPressed: () async {
          if (await Permission.camera.isPermanentlyDenied) {
            showAsyncDialog(
              builder: (_) => DefaultDialog(
                title: Text(AppLocalizations.of(context)!.grantCameraPermissionDialogTitle),
                content: Text(AppLocalizations.of(context)!.grantCameraPermissionDialogPermanentlyDenied),
              ),
            );
            return;
          }
          if (globalNavigatorKey.currentContext == null) return;

          /// Open the QR-code scanner and call `handleQrCode`, with the scanned code as the argument.
          Navigator.pushNamed(globalNavigatorKey.currentContext!, QRScannerView.routeName).then((qrCode) {
            final resultHandlers = <ResultHandler>[
              ref.read(tokenProvider.notifier),
              ref.read(tokenContainerProvider.notifier),
            ];
            if (qrCode == null || !context.mounted) return;
            scanQrCode(context: context, resultHandlerList: resultHandlers, qrCode: qrCode);
          });
        },
        tooltip: AppLocalizations.of(context)!.scanQrCode,
        child: const Icon(Icons.qr_code_scanner_outlined),
      );
}
