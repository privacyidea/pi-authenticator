import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../model/tokens/token.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/logger.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../token_action.dart';

class DefaultLockAction extends TokenAction {
  final Token token;

  const DefaultLockAction({required this.token});

  @override
  void handle(BuildContext context) async {
    Logger.info('Changing lock status of token.', name: 'token_widgets.dart#_changeLockStatus');
    if (await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.authenticateToUnLockToken) == false) {
      return;
    }

    globalRef?.read(tokenProvider.notifier).updateToken(token, (p0) => p0.copyWith(isLocked: !token.isLocked));
  }
}
