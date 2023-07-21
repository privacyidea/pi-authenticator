import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token/push_token.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/main_view_tokens_list.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainViewBody extends StatelessWidget {
  final List<Token> tokens;

  const MainViewBody(this.tokens, {super.key});

  @override
  Widget build(BuildContext context) {
    bool allowManualRefresh = tokens.any((t) => t is PushToken && t.url != null);

    /// Builds the body of the screen. If any tokens supports polling,
    /// returns a list wrapped in a RefreshIndicator to manually poll.
    /// If not returns the list only.
    return allowManualRefresh
        ? RefreshIndicator(
            child: MainViewTokensList(tokens),
            onRefresh: () async {
              showMessage(
                message: AppLocalizations.of(context)!.pollingChallenges,
                duration: Duration(seconds: 1),
                context: context,
              );
              bool success = await PushProvider.pollForChallenges();
              if (!success) {
                showMessage(
                  message: AppLocalizations.of(context)!.pollingFailNoNetworkConnection,
                  duration: Duration(seconds: 3),
                  context: context,
                );
              }
            },
          )
        : MainViewTokensList(tokens);
  }
}
