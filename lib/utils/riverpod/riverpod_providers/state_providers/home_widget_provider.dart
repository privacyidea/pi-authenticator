import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/tokens/otp_token.dart';
import '../../../home_widget_utils.dart';
import '../../../logger.dart';
import '../state_notifier_providers/token_provider.dart';

final homeWidgetProvider = StateProvider<Map<String, OTPToken>>(
  (ref) {
    Logger.info("New homeWidgetProvider created", name: 'homeWidgetProvider');
    ref.listen(tokenProvider, (previous, next) {
      HomeWidgetUtils().updateTokensIfLinked(next.lastlyUpdatedTokens);
    });
    return {};
  },
);
