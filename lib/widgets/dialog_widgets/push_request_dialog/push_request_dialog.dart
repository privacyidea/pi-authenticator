/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token.dart';
import 'package:privacyidea_authenticator/widgets/dialog_widgets/push_request_dialog/widgets/push_action_button.dart';

import '../../../../model/push_request/push_requests.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/api_results/pi_server_results/pi_server_result_detail.dart';
import '../../../model/api_results/pi_server_results/pi_server_result_value.dart';
import '../../../utils/customization/theme_extentions/push_request_theme.dart';
import '../../../utils/lock_auth.dart';
import '../../../utils/logger.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import '../../../utils/utils.dart';
import '../../../utils/view_utils.dart';
import '../../padded_row.dart';
import '../default_dialog.dart';
import 'widgets/push_decline_confirm_dialog.dart';
import 'widgets/push_request_base_info.dart';
import 'widgets/push_request_header.dart';

part 'push_choice_dialog.dart';
part 'push_code_to_phone_dialog.dart';
part 'push_default_dialog.dart';

class PushRequestDialog extends StatelessWidget with PushDialogMixin {
  @override
  final PushRequest pushRequest;
  @override
  final PushToken token;

  const PushRequestDialog({
    required this.pushRequest,
    required this.token,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return switch (pushRequest) {
      PushChoiceRequest choice => PushChoiceDialog(
        pushRequest: choice,
        token: token,
      ),
      PushCodeToPhoneRequest codeReq => PushCodeToPhoneDialog(
        pushRequest: codeReq,
        token: token,
      ),
      PushDefaultRequest simple => PushDefaultDialog(
        pushRequest: simple,
        token: token,
      ),
      _ => throw UnimplementedError(
        'No dialog implemented for push request type: ${pushRequest.runtimeType}',
      ),
    };
  }
}

mixin PushDialogMixin {
  PushToken get token;
  PushRequest get pushRequest;

  Future<void> handleAccept<
    T extends PiServerResultValue,
    D extends PiServerResultDetail
  >(BuildContext context, WidgetRef ref, {String? answer}) async {
    if (token.isLocked &&
        !await lockAuth(
          reason: (l10n) => l10n.authToAcceptPushRequest,
          localization: AppLocalizations.of(context)!,
        )) {
      return;
    }

    final response = await ref
        .read(pushRequestProvider.notifier)
        .accept<BooleanResultValue, CodeToPhoneResultDetail>(
          token,
          pushRequest,
          selectedAnswer: answer,
        );

    if (!context.mounted || response == null) {
      return;
    }

    if (response.detail != null) {
      _handleCodeToPhoneResultDetail(context, response.detail!);
    }

    final settings = ref.read(settingsProvider).value;
    if (settings?.autoCloseAppAfterAcceptingPushRequest == true) {
      SystemNavigator.pop();
    }
    _onHandled(context);
  }

  Future<void> handleDecline(BuildContext context, WidgetRef ref) async {
    if (token.isLocked &&
        !await lockAuth(
          reason: (l10n) => l10n.authToDeclinePushRequest,
          localization: AppLocalizations.of(context)!,
        )) {
      return;
    }
    await ref.read(pushRequestProvider.notifier).decline(token, pushRequest);
    if (context.mounted) {
      _onHandled(context);
    }
  }

  Future<void> handleDiscard(BuildContext context, WidgetRef ref) async {
    if (token.isHidden &&
        !await lockAuth(
          reason: (l10n) => l10n.authToDiscardPushRequest,
          localization: AppLocalizations.of(context)!,
        )) {
      return;
    }
    await ref.read(pushRequestProvider.notifier).remove(pushRequest);
    if (context.mounted) {
      _onHandled(context);
    }
  }

  void _onHandled(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _handleCodeToPhoneResultDetail(
    BuildContext context,
    CodeToPhoneResultDetail codeToPhoneResultDetail,
  ) {
    Logger.debug('Handling CodeToPhoneResultDetail: $codeToPhoneResultDetail');
  }
}
