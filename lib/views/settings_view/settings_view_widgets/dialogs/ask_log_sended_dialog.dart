import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../utils/logger.dart';
import '../../../../widgets/dialog_widgets/default_dialog.dart';

/// A dialog that asks the user if they sended the log. Clear logs if he did.
class AskLogSendedDialog extends StatelessWidget {
  const AskLogSendedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      title: Text(
        AppLocalizations.of(context)!.confirmation,
        overflow: TextOverflow.fade,
        softWrap: false,
      ),
      content: SingleChildScrollView(
        controller: ScrollController(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                AppLocalizations.of(context)!.askLogSendedDescription,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            AppLocalizations.of(context)!.no,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
            Logger.clearErrorLog();
          },
          child: Text(
            AppLocalizations.of(context)!.yes,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        )
      ],
    );
  }
}
