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
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/default_dialog.dart';

import '../../../../../utils/view_utils.dart';

class ContainerTokenIndelibleDialog extends StatelessWidget {
  static Future<void> showDialog() => showAsyncDialog(builder: (context) => ContainerTokenIndelibleDialog());

  const ContainerTokenIndelibleDialog({super.key});

  @override
  Widget build(BuildContext context) => DefaultDialog(
        title: Text(AppLocalizations.of(context)!.indelibleTokenTitle),
        content: Text(AppLocalizations.of(context)!.indelibleTokenContent),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
}
