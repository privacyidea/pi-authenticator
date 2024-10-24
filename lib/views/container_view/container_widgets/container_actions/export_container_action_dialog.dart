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
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';
import 'package:privacyidea_authenticator/widgets/button_widgets/cooldown_button.dart';

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
      builder: (_) => TransferQrDialog(qrData: qrData),
    );
  }
}

class TransferQrDialog extends StatelessWidget {
  final String qrData;

  const TransferQrDialog({super.key, required this.qrData});

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    );
  }
}
