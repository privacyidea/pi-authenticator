import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens/token.dart';
import 'package:privacyidea_authenticator/utils/lock_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HideableWidget extends StatelessWidget {
  final Token token;
  final ValueNotifier<bool> isHiddenNotifier;
  final Widget child;
  const HideableWidget({
    required this.child,
    required this.token,
    required this.isHiddenNotifier,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return token.isLocked && isHiddenNotifier.value
        ? IconButton(
            onPressed: () async {
              if (await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.authenticateToShowOtp)) {
                isHiddenNotifier.value = false;
              }
            },
            icon: Icon(Icons.remove_red_eye_outlined),
          )
        : child;
  }
}
