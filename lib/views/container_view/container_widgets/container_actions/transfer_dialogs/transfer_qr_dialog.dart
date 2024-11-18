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

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/token_container.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';
import 'transfer_delete_dontainer_dialog.dart';

class TransferQrDialog extends ConsumerWidget {
  final String qrData;
  final TokenContainerFinalized container;

  const TransferQrDialog({super.key, required this.qrData, required this.container});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = AppLocalizations.of(context)!;
    return DefaultDialog(
      title: Text(appLocalizations.transferContainerDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(appLocalizations.transferContainerScanQrCode),
          SizedBox(height: 8),
          generateQrCodeImage(data: qrData),
          SizedBox(height: 8),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(
              barrierDismissible: false,
              useRootNavigator: false,
              context: context,
              builder: (_) => TransferDeleteContainerDialog(
                container: container,
              ),
            );
          },
          child: Text(appLocalizations.cancel),
        ),
      ],
    );
  }
}
