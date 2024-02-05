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
          content: Scrollbar(
            scrollbarOrientation: ScrollbarOrientation.right,
            thumbVisibility: true,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
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
                            : const CircularProgressIndicator(),
                      );
                    }),
              ),
            ),
          ),
        ),
      );
    },
  );
}
