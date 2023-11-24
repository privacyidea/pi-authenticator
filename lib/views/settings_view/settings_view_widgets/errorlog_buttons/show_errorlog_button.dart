import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../utils/logger.dart';
import '../../../../widgets/default_dialog.dart';
import '../send_error_dialog.dart';

class ShowErrorLogButton extends StatelessWidget {
  const ShowErrorLogButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        title: ElevatedButton(
          onPressed: () => _pressShowErrorLog(context),
          child: const Text(
            'Fehlerprotokoll anzeigen', // 'Show Error Log', //TODO: Localize
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
      ),
    );
  }
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
