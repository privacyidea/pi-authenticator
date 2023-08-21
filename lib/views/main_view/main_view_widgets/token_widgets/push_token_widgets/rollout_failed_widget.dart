import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../model/tokens/push_token.dart';
import '../../../../../utils/customizations.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../utils/utils.dart';
import '../../../../../widgets/press_button.dart';

class RolloutFailedWidget extends StatelessWidget {
  final PushToken token;

  const RolloutFailedWidget({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rolloutMsg(token.rolloutState, context),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.35,
                child: PressButton(
                  onPressed: () => globalRef?.read(tokenProvider.notifier).rolloutPushToken(token),
                  child: Text(
                    AppLocalizations.of(context)!.retryRollout,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: width * 0.35,
                child: PressButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.errorContainer)),
                  onPressed: () => _showDialog(),
                  child: Text(
                    AppLocalizations.of(context)!.delete,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDialog() => showDialog(
      context: globalNavigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: Text(
            AppLocalizations.of(context)!.confirmDeletion,
          ),
          content: Text(AppLocalizations.of(context)!.confirmDeletionOf(token.label)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
            TextButton(
              onPressed: () {
                globalRef?.read(tokenProvider.notifier).removeToken(token);
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.delete,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
          ],
        );
      });
}
