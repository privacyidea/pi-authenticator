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
import 'package:privacyidea_authenticator/model/extensions/token_list_extension.dart';

import '../../../../../model/token_container.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../../../utils/view_utils.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';

class TransferDeleteContainerDialog extends ConsumerStatefulWidget {
  final TokenContainerFinalized container;

  const TransferDeleteContainerDialog(this.container, {super.key});

  static Future<bool?> showDialog(TokenContainerFinalized container) =>
      showAsyncDialog(
        builder: (context) => TransferDeleteContainerDialog(container),
      );

  @override
  ConsumerState<TransferDeleteContainerDialog> createState() =>
      _TransferDeleteContainerDialogState();
}

class _TransferDeleteContainerDialogState
    extends ConsumerState<TransferDeleteContainerDialog> {
  bool? isUnlinked;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tokenState = await ref.read(tokenProvider.future);
      if (!ref.context.mounted) return;
      final failedContainers = await ref
          .read(tokenContainerProvider.notifier)
          .syncContainers(
            tokenState: tokenState,
            containersToSync: [widget.container],
            isManually: false,
          );
      if (!context.mounted) return;
      if (failedContainers.keys.contains(3002)) {
        setState(() => isUnlinked = true);
      } else {
        setState(() => isUnlinked = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return switch (isUnlinked) {
      null => DefaultDialog(
        title: Text(appLocalizations.transferContainerDialogTitle),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(flex: 2, child: SizedBox()),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            Expanded(flex: 2, child: SizedBox()),
          ],
        ),
      ),
      true => DefaultDialog(
        title: Text(appLocalizations.transferContainerDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(appLocalizations.transferContainerSuccessDialogContent1),
            SizedBox(height: 8),
            Text(appLocalizations.transferContainerSuccessDialogContent2),
          ],
        ),
        actions: [
          DialogAction(
            label: appLocalizations.cancel,
            intent: DialogActionIntent.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
          DialogAction(
            label: appLocalizations.containerTransferDeleteTokensButtonText,
            intent: DialogActionIntent.destructive,
            onPressed: () => confirmDeleteLocaly(context),
          ),
        ],
      ),
      false => DefaultDialog(
        title: Text(appLocalizations.transferContainerDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                appLocalizations.containerTransferDialogContentAborted,
              ),
            ),
          ],
        ),
        actions: [
          DialogAction(
            label: appLocalizations.ok,
            intent: DialogActionIntent.neutral,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    };
  }

  Future<void> confirmDeleteLocaly(BuildContext context) async {
    final containerTokens = (await ref.read(
      tokenProvider.future,
    )).containerTokens(widget.container.serial);
    await ref
        .read(tokenProvider.notifier)
        .removeTokens(containerTokens.noOffline);
    await ref
        .read(tokenContainerProvider.notifier)
        .deleteContainer(widget.container);
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    showSuccessStatusMessage(
      message: (l) => l.containerTransferDeleteTokensSuccessMessage,
    );
  }
}
