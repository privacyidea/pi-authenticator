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
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';

import '../../../utils/view_utils.dart';

class SendDeviceInfosDialog extends StatelessWidget {
  const SendDeviceInfosDialog({super.key});

  static Future<bool?> showDialog() => showAsyncDialog<bool>(
        builder: (context) => SendDeviceInfosDialog(),
        barrierDismissible: false,
      );

  @override
  Widget build(BuildContext context) => DefaultDialog(
        title: Text('Send Device Info'),
        content: Text(
          'Would you like to tell the publisher of the container which device you are using? This may be useful later if you have problems with your second factor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      );
}
