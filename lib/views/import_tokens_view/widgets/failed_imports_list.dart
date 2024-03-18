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
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.importFailedToken(failedImports.length),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < failedImports.length; i++)
            Text(
              '${i + 1}. ${failedImports[i]}',
            ),
        ],
      ),
    );
  }
}
