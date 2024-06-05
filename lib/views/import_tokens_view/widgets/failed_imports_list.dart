import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class FailedImportsList extends StatelessWidget {
  final List<String> failedImports;

  const FailedImportsList({
    super.key,
    required this.failedImports,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            AppLocalizations.of(context)!.importFailedToken(failedImports.length),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        for (var i = 0; i < failedImports.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Text(
                    '${i + 1}.',
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: Text(
                    '${failedImports[i]}',
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
