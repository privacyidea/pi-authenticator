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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';

import '../../../../../../../model/token_container.dart';
import '../../../../../../../utils/view_utils.dart';
import '../../../../../../../widgets/button_widgets/cooldown_button.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../widgets/dialog_widgets/default_dialog.dart';
import 'transfer_dialogs/transfer_offline_token_dialog.dart';
import 'transfer_dialogs/transfer_qr_dialog.dart';

class TransferContainerDialog extends ConsumerStatefulWidget {
  final TokenContainerFinalized container;

  const TransferContainerDialog({super.key, required this.container});

  @override
  ConsumerState<TransferContainerDialog> createState() => _TransferContainerDialogState();
}

class _TransferContainerDialogState extends ConsumerState<TransferContainerDialog> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return DefaultDialog(
      title: Text(appLocalizations.transferContainerDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(appLocalizations.transferContainerDialogContent1),
          SizedBox(height: 8),
          Text(appLocalizations.transferContainerDialogContent2),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        CooldownButton(
          onPressed: () => _startTransfer(widget.container),
          child: Text(appLocalizations.startTransferButtonText),
        ),
      ],
    );
  }

  Future<void> _startTransfer(TokenContainerFinalized container) async {
    final String qrData;
    final hasOfflineToken = ref.read(tokenProvider).containerTokens(container.serial).where((token) => token.isOffline);
    if (hasOfflineToken.isNotEmpty) {
      final continueTransfer = await showDialog(context: context, builder: (_) => TransferOfflineTokenDialog(hasOfflineToken.length));
      if (continueTransfer != true) return;
    }
    try {
      qrData = await ref.read(tokenContainerProvider.notifier).getRolloverQrData(container);
    } catch (e) {
      if (!mounted) return;
      return showErrorStatusMessage(
        message: (localization) => localization.transferContainerFailed,
        details: (_) => e.toString(),
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (_) => TransferQrDialog(qrData: qrData, container: container),
    );
  }
}
