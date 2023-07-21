import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token/push_token.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/category_widgets/add_token_category.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/main_view_tokens_list.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/category_widgets/token_categorys_list.dart';

class MainViewBody extends StatelessWidget {
  final List<Token> tokens;

  const MainViewBody(this.tokens, {super.key});

  @override
  Widget build(BuildContext context) {
    bool allowManualRefresh = tokens.any((t) => t is PushToken && t.url != null);

    /// Builds the body of the screen. If any tokens supports polling,
    /// returns a list wrapped in a RefreshIndicator to manually poll.
    /// If not returns the list only.

    final child = SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: MainViewTokensList(tokens)),
          TokenCategorysList(),
          AddTokenCategory(),
          SizedBox(height: 120), // To make sure the last token is not hidden by the Floating Action Button
        ],
      ),
    );

    return allowManualRefresh
        ? RefreshIndicator(
            child: child,
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
        : child;
  }
}
