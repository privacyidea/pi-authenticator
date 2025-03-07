/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2025 NetKnights GmbH
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

import '../../../../l10n/app_localizations.dart';
import '../../../../utils/logger.dart';
import '../send_error_dialog.dart';
import 'errorlog_button.dart';

class SendErrorLogButton extends StatelessWidget {
  const SendErrorLogButton({super.key});

  @override
  Widget build(BuildContext context) => ErrorlogButton(
        onPressed: () => _pressSendErrorLog(context),
        text: AppLocalizations.of(context)!.send,
      );
}

void _pressSendErrorLog(BuildContext context) {
  if (Logger.instance.logfileHasContent) {
    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (context) => const SendErrorDialog(),
    );
  } else {
    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (context) => const NoLogDialog(),
    );
  }
}
