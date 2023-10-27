import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class NoTokenScreen extends StatelessWidget {
  const NoTokenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Wrap(
          children: [
            FittedBox(
              child: Text(
                AppLocalizations.of(context)!.noResultTitle,
                style: Theme.of(context).textTheme.headlineSmall,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.noResultText1,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            const Icon(Icons.qr_code_scanner_outlined),
            Text(
              AppLocalizations.of(context)!.noResultText2,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.fade,
              softWrap: false,
            )
          ],
        ),
      ),
    );
  }
}
