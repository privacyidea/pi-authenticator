import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/push_request.dart';
import '../../../model/tokens/push_token.dart';
import '../../../utils/globals.dart';
import '../../../utils/lock_auth.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/settings_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../padded_row.dart';
import '../default_dialog.dart';
import 'push_request_dialog_widgets/push_accept_button.dart';
import 'push_request_dialog_widgets/push_decline_confirm_button.dart';
import 'push_request_dialog_widgets/push_presence_button_row.dart';

class PushRequestDialog extends ConsumerStatefulWidget {
  static WidgetStateProperty<OutlinedBorder?> getButtonShape(BuildContext context) => WidgetStateProperty.all(
    Theme.of(context).elevatedButtonTheme.style?.shape?.resolve({})?.copyWith(side: BorderSide(color: Theme.of(context).colorScheme.onPrimary, width: 2.5)),
  );

  static double buttonHeight = 36;

  final PushRequest pushRequest;

  const PushRequestDialog({required this.pushRequest, super.key});

  @override
  ConsumerState<PushRequestDialog> createState() => _PushRequestDialogState();
}

class _PushRequestDialogState extends ConsumerState<PushRequestDialog> {
  bool isHandled = false;
  bool dialogIsOpen = false;

  @override
  void dispose() {
    if (dialogIsOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        int popCount = 0;
        Navigator.of(await globalContext).popUntil((route) {
          popCount++;
          return route.isFirst || popCount > 1;
        });
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokenState = ref.watch(tokenProvider).value;
    final token = ref.watch(tokenProvider).value?.getTokenBySerial(widget.pushRequest.serial);
    final localizations = AppLocalizations.of(context)!;
    final title = widget.pushRequest.title == 'privacyIDEA' ? localizations.authentication : widget.pushRequest.title;
    if (token == null || tokenState == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) ref.read(pushRequestProvider.notifier).remove(widget.pushRequest);
      });
    }

    return isHandled || token == null
        ? const SizedBox()
        : Container(
            color: Colors.transparent,
            child: DefaultDialog(
              scrollable: false,
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Text(localizations.requestInfo(token.label, token.issuer), style: Theme.of(context).textTheme.bodyLarge!, textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  Text(widget.pushRequest.question, style: Theme.of(context).textTheme.bodyLarge!, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  PaddedRow(
                    peddingPercent: 0.33,
                    child: widget.pushRequest.possibleAnswers == null
                        ? PushAcceptButton(height: PushRequestDialog.buttonHeight, onAccept: () => _onAccept(token))
                        : RequirePresenceButtonRow(
                            rowHeight: PushRequestDialog.buttonHeight,
                            possibleAnswers: widget.pushRequest.possibleAnswers!,
                            onAccept: (answer) => _onAccept(token, answer: answer),
                          ),
                  ),
                  const SizedBox(height: 8),
                  PaddedRow(
                    peddingPercent: 0.33,
                    child: PushDeclineConfirmButton(
                      height: PushRequestDialog.buttonHeight,
                      onDiscard: () => _onDiscard(token),
                      onDecline: () => _onDecline(token),
                      confirmationTitle: title,
                      expirationDate: widget.pushRequest.expirationDate,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Future<void> _onAccept(PushToken token, {String? answer}) async {
    if (token.isLocked && !await lockAuth(reason: (localization) => localization.authToAcceptPushRequest, localization: AppLocalizations.of(context)!)) {
      return;
    }
    final success = await ref.read(pushRequestProvider.notifier).accept(token, widget.pushRequest, selectedAnswer: answer);
    if (!mounted) return;

    if (success && ref.read(settingsProvider).value?.autoCloseAppAfterAcceptingPushRequest == true) {
      SystemNavigator.pop();
    }
    setState(() => isHandled = true);
  }

  Future<void> _onDiscard(PushToken token) async {
    if (token.isLocked && !await lockAuth(reason: (localization) => localization.authToDiscardPushRequest, localization: AppLocalizations.of(context)!)) {
      return;
    }
    await ref.read(pushRequestProvider.notifier).remove(widget.pushRequest);
    if (mounted) setState(() => isHandled = true);
  }

  Future<void> _onDecline(PushToken token) async {
    if (token.isLocked && !await lockAuth(reason: (localization) => localization.authToDeclinePushRequest, localization: AppLocalizations.of(context)!)) {
      return;
    }
    await ref.read(pushRequestProvider.notifier).decline(token, widget.pushRequest);
    if (mounted) setState(() => isHandled = true);
  }
}
