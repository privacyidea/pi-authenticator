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
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import 'package:privacyidea_authenticator/widgets/elevated_delete_button.dart';

import '../../../../../../../model/token_container.dart';
import '../../../../../../../utils/view_utils.dart';
import '../../../../../../../widgets/button_widgets/cooldown_button.dart';
import '../../../../utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/dialog_widgets/default_dialog.dart';

class TransferContainerDialog extends ConsumerStatefulWidget {
  final TokenContainerFinalized container;

  const TransferContainerDialog({super.key, required this.container});

  @override
  ConsumerState<TransferContainerDialog> createState() => _TransferContainerDialogState();
}

class _TransferContainerDialogState extends ConsumerState<TransferContainerDialog> {
  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      title: Text('Transfer Container'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('When the container is transferred successfully to another device, it will be removed from this device with all its tokens.'),
          SizedBox(height: 8),
          Text('For the process is an internet connection required.'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
        CooldownButton(
          onPressed: () => _startTransfer(widget.container),
          child: Text('Start Transfer'),
        ),
      ],
    );
  }

  Future<void> _startTransfer(TokenContainerFinalized container) async {
    final String qrData;
    try {
      qrData = await ref.read(tokenContainerProvider.notifier).getTransferQrData(container);
    } catch (e) {
      return showStatusMessage(
        message: 'Failed to start transfer.',
        subMessage: e.toString(),
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

class TransferQrDialog extends ConsumerWidget {
  final String qrData;
  final TokenContainerFinalized container;

  const TransferQrDialog({super.key, required this.qrData, required this.container});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultDialog(
      title: Text('Transfer Container'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Scan the QR code with the new device to transfer the container.'),
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
              builder: (_) => DeleteContainerAfterTransferDialog(
                container: container,
              ),
            );
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}

class DeleteContainerAfterTransferDialog extends ConsumerStatefulWidget {
  final TokenContainerFinalized container;

  const DeleteContainerAfterTransferDialog({
    super.key,
    required this.container,
  });

  @override
  ConsumerState<DeleteContainerAfterTransferDialog> createState() => _DeleteContainerAfterTransferDialogState();
}

class _DeleteContainerAfterTransferDialogState extends ConsumerState<DeleteContainerAfterTransferDialog> {
  bool? isUnlinked;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tokenState = ref.read(tokenProvider);
      final failedContainers = await ref.read(tokenContainerProvider.notifier).syncTokens(
            tokenState,
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
    return switch (isUnlinked) {
      null => DefaultDialog(
          title: Text('Transfer Container'),
          content: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 32, maxHeight: 32, minHeight: 32, minWidth: 32),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      true => DefaultDialog(
          title: Text('Transfer Container'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('The container has been transferred successfully to another device.'),
              SizedBox(height: 8),
              Text('Do you want to delete the container and its corrosponding tokens from this device?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedDeleteButton(
              text: 'Remove from this device',
              onPressed: () => onConfirm(context),
            ),
          ],
        ),
      false => DefaultDialog(
          title: Text('Transfer Container'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Transfer aborted.'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Ok'),
            ),
          ],
        ),
    };
  }

  void onConfirm(BuildContext context) async {
    final containerTokens = ref.read(tokenProvider).containerTokens(widget.container.serial);
    await ref.read(tokenProvider.notifier).removeTokens(containerTokens);
    await ref.read(tokenContainerProvider.notifier).deleteContainer(widget.container);
    if (!context.mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    showStatusMessage(message: 'Container and corresponding tokens successfully removed from this device.');
  }
}
