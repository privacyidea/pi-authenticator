import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'push_request_dialog_widgets/push_decline_confirm_button.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/push_request.dart';
import '../../../model/tokens/push_token.dart';
import '../../../utils/globals.dart';
import '../../../utils/lock_auth.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/push_request_provider.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../default_dialog.dart';
import 'push_request_dialog_widgets/push_accept_button.dart';
import 'push_request_dialog_widgets/push_presence_button_row.dart';

class PushRequestDialog extends ConsumerStatefulWidget {
  static WidgetStateProperty<OutlinedBorder?> getButtonShape(BuildContext context) => WidgetStateProperty.all(
        Theme.of(context).elevatedButtonTheme.style?.shape?.resolve({})?.copyWith(
          side: BorderSide(color: Theme.of(context).colorScheme.onPrimary, width: 2.5),
        ),
      );

  static double buttonHeight = 36;

  final PushRequest pushRequest;

  const PushRequestDialog({
    required this.pushRequest,
    super.key,
  });

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
    final token = ref.watch(tokenProvider).getTokenBySerial(widget.pushRequest.serial);
    final localizations = AppLocalizations.of(context)!;
    final title = widget.pushRequest.title == 'privacyIDEA' ? localizations.authentication : widget.pushRequest.title;
    if (token == null) {
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
              title: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium!,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    localizations.requestInfo(token.issuer, token.label),
                    style: Theme.of(context).textTheme.bodyLarge!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.pushRequest.question,
                    style: Theme.of(context).textTheme.bodyLarge!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  PaddedRow(
                    peddingPercent: 0.33,
                    child: widget.pushRequest.possibleAnswers == null
                        ? PushAcceptButton(
                            height: PushRequestDialog.buttonHeight,
                            onAccept: () => _onAccept(token),
                          )
                        : RequirePresenceButtonRow(
                            rowHeight: PushRequestDialog.buttonHeight,
                            possibleAnswers: widget.pushRequest.possibleAnswers!,
                            onAccept: (answer) => _onAccept(token, answer: answer),
                          ),
                  ),
                  PaddedRow(
                    peddingPercent: 0.33,
                    child: PushDeclineConfirmButton(
                      height: PushRequestDialog.buttonHeight,
                      onDecline: () => _onDecline(token),
                      onDiscard: () => _onDiscard(token),
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
    if (token.isLocked && await lockAuth(localizedReason: AppLocalizations.of(context)!.authToAcceptPushRequest) == false) {
      return;
    }
    await ref.read(pushRequestProvider.notifier).accept(token, widget.pushRequest, selectedAnswer: answer);
    if (mounted) setState(() => isHandled = true);
  }

  Future<void> _onDecline(PushToken token) async {
    if (token.isLocked && await lockAuth(localizedReason: AppLocalizations.of(context)!.authToDeclinePushRequest) == false) {
      return;
    }
    await ref.read(pushRequestProvider.notifier).decline(token, widget.pushRequest);
    if (mounted) setState(() => isHandled = true);
  }

  Future<void> _onDiscard(PushToken token) async {
    if (token.isLocked && await lockAuth(localizedReason: AppLocalizations.of(context)!.authToDeclinePushRequest) == false) {
      return;
    }
    await ref.read(pushRequestProvider.notifier).remove(widget.pushRequest);
    if (mounted) setState(() => isHandled = true);
  }
}

class PaddedRow extends StatelessWidget {
  final double peddingPercent;
  final Widget child;

  /// Creates a row with padding on both sides of the child.
  /// Example with 0.25 padding:
  /// [ 0.125 | child | 0.125 ]
  ///
  /// Assert that [peddingPercent] is higher than 0 and lower than 1.
  const PaddedRow({super.key, required this.child, this.peddingPercent = 0.25}) : assert(peddingPercent > 0 && peddingPercent < 1);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            flex: (peddingPercent * 50).toInt(),
            child: const SizedBox(),
          ),
          Expanded(
            flex: 100 - (peddingPercent * 100).toInt(),
            child: child,
          ),
          Expanded(
            flex: (peddingPercent * 50).toInt(),
            child: const SizedBox(),
          ),
        ],
      );
}
