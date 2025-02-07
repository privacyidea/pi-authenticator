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
import '../../../../widgets/dialog_widgets/default_dialog.dart';
import '../send_error_dialog.dart';
import 'errorlog_button.dart';

class ShowErrorLogButton extends StatelessWidget {
  const ShowErrorLogButton({super.key});

  @override
  Widget build(BuildContext context) => ErrorlogButton(
        onPressed: () => _pressShowErrorLog(context),
        text: AppLocalizations.of(context)!.showErrorLog,
      );
}

void _pressShowErrorLog(BuildContext context) {
  if (Logger.instance.logfileHasContent == false) {
    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (context) => const NoLogDialog(),
    );
    return;
  }
  showDialog(
    context: context,
    builder: (context) {
      final size = MediaQuery.of(context).size;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: size.height * 0.085),
        child: DefaultDialog(
          title: Text(AppLocalizations.of(context)!.errorLogTitle),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)!.dismiss),
            )
          ],
          content: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: FutureBuilder<Object>(
                future: Logger.getErrorLog(),
                builder: (context, errorLog) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: errorLog.data != null
                        ? Text(
                            errorLog.data.toString(),
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 8),
                          )
                        : const CircularProgressIndicator.adaptive(),
                  );
                }),
          ),
        ),
      );
    },
  );
}
