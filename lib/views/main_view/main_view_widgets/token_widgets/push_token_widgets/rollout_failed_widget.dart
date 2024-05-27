import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/extensions/enums/push_token_rollout_state_extension.dart';
import '../../../../../model/tokens/push_token.dart';
import '../../../../../utils/globals.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../widgets/dialog_widgets/default_dialog.dart';
import '../../../../../widgets/press_button.dart';

class RolloutFailedWidget extends StatelessWidget {
  final PushToken token;

  const RolloutFailedWidget({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: FittedBox(
              child: Text(
                token.rolloutState.rolloutMsg(localizations),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.35,
                child: PressButton(
                  onPressed: () => globalRef?.read(tokenProvider.notifier).rolloutPushToken(token),
                  child: Text(
                    localizations.retryRollout,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: width * 0.35,
                child: PressButton(
                  style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.errorContainer)),
                  onPressed: () => _showDialog(),
                  child: Text(
                    localizations.delete,
                    style: Theme.of(context).textTheme.bodyMedium,
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
      useRootNavigator: false,
      context: globalNavigatorKey.currentContext!,
      builder: (BuildContext context) {
        final localizations = AppLocalizations.of(context)!;
        return DefaultDialog(
          scrollable: true,
          title: Text(
            localizations.confirmDeletion,
          ),
          content: Text(localizations.confirmDeletionOf(token.label)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                localizations.cancel,
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
                localizations.delete,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
          ],
        );
      });
}
