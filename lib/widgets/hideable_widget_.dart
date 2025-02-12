import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../model/tokens/otp_token.dart';
import '../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';

class HideableWidget extends ConsumerWidget {
  final OTPToken token;
  final bool isHidden;
  final Widget child;
  const HideableWidget({
    required this.child,
    required this.token,
    required this.isHidden,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return token.isLocked && isHidden
        ? IconButton(
            tooltip: AppLocalizations.of(context)!.authenticateToShowOtp,
            onPressed: () async => ref.read(tokenProvider.notifier).showToken(token),
            icon: const Icon(Icons.remove_red_eye_outlined),
          )
        : child;
  }
}
