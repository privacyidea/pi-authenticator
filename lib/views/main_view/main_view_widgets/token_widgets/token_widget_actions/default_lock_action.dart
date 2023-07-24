import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/appCustomizer.dart';
import 'package:privacyidea_authenticator/utils/lock_auth.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_actions/token_action.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DefaultLockAction extends TokenAction {
  final Token token;

  DefaultLockAction({required this.token, Key? key}) : super(key: key);
  @override
  SlidableAction build(BuildContext context) {
    return SlidableAction(
      label: token.isLocked ? AppLocalizations.of(context)!.unlock : AppLocalizations.of(context)!.lock,
      backgroundColor: Theme.of(context).brightness == Brightness.light ? ApplicationCustomizer.lockColorLight : ApplicationCustomizer.lockColorDark,
      foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
      icon: token.isLocked ? Icons.lock_open : Icons.lock_outline,
      onPressed: (context) async {
        Logger.info('Changing lock status of token ${token.label}.', name: 'token_widgets.dart#_changeLockStatus');

        if (await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.authenticateToUnLockToken)) {
          globalRef?.read(tokenProvider.notifier).updateToken(token.copyWith(isLocked: !token.isLocked));
        }
      },
    );
  }
}
