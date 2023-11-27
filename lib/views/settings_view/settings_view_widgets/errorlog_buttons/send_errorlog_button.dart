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
        text: AppLocalizations.of(context)!.sendErrorLog,
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
