import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../utils/logger.dart';
import 'errorlog_button.dart';

class DeleteErrorlogButton extends StatelessWidget {
  const DeleteErrorlogButton({super.key});

  @override
  Widget build(BuildContext context) => ErrorlogButton(
        onPressed: () => _pressClearErrorLog(context),
        text: AppLocalizations.of(context)!.clearErrorLog,
      );

  void _pressClearErrorLog(BuildContext context) {
    Navigator.pop(context);
    Logger.clearErrorLog();
  }
}
