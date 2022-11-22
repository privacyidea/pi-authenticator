import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NoTokenScreen extends StatelessWidget {
  const NoTokenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          height: 150,
          width: 300,
          child: Center(
            child: Wrap(
              children: [
                Text(
                  AppLocalizations.of(context)!.noResultTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(AppLocalizations.of(context)!.noResultText1,
                    style: Theme.of(context).textTheme.subtitle1),
                Icon(Icons.qr_code_scanner_outlined),
                Text(AppLocalizations.of(context)!.noResultText2,
                    style: Theme.of(context).textTheme.subtitle1)
              ],
            ),
          )),
    );
  }
}
