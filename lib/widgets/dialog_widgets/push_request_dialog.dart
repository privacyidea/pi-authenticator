import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../model/extensions/color_extension.dart';
import '../../model/push_request.dart';
import '../../model/tokens/push_token.dart';
import '../../utils/globals.dart';
import '../../utils/lock_auth.dart';
import '../../utils/riverpod_providers.dart';
import '../press_button.dart';
import 'default_dialog.dart';

class PushRequestDialog extends ConsumerStatefulWidget {
  final PushRequest pushRequest;

  const PushRequestDialog(this.pushRequest, {super.key});

  @override
  ConsumerState<PushRequestDialog> createState() => _PushRequestDialogState();
}

class _PushRequestDialogState extends ConsumerState<PushRequestDialog> {
  static const titleScale = 1.35;
  static const questionScale = 1.1;
  double get lineHeight => Theme.of(context).textTheme.titleLarge?.fontSize ?? 16;

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
    final lineHeight = this.lineHeight;
    final question = widget.pushRequest.question;
    final token = ref.watch(tokenProvider).getTokenBySerial(widget.pushRequest.serial);
    if (token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          ref.read(pushRequestProvider.notifier).remove(widget.pushRequest);
        }
      });
    }
    return isHandled || token == null
        ? const SizedBox()
        : Container(
            color: Colors.transparent,
            child: DefaultDialog(
              title: Text(
                AppLocalizations.of(context)!.authenticationRequest,
                style: Theme.of(context).textTheme.titleLarge!,
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(titleScale),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalizations.of(context)!.requestInfo(
                      token.issuer,
                      token.label,
                    ),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: Theme.of(context).textTheme.titleMedium?.fontSize),
                    textScaler: const TextScaler.linear(questionScale),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: lineHeight),
                  ...[
                    Text(
                      question,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: Theme.of(context).textTheme.titleMedium?.fontSize),
                      textScaler: const TextScaler.linear(questionScale),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: lineHeight),
                  ],
                  SizedBox(
                    // Accept button
                    height: lineHeight * titleScale * 2 + 16,
                    child: PressButton(
                      onPressed: () async {
                        if (token.isLocked && await lockAuth(localizedReason: AppLocalizations.of(context)!.authToAcceptPushRequest) == false) {
                          return;
                        }
                        globalRef?.read(pushRequestProvider.notifier).accept(token, widget.pushRequest);
                        if (mounted) setState(() => isHandled = true);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.accept,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                            textScaler: const TextScaler.linear(titleScale),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                          Icon(
                            Icons.check_outlined,
                            size: lineHeight * titleScale,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: lineHeight * 0.5),
                  SizedBox(
                    // Decline button
                    height: lineHeight * titleScale + 16,
                    child: PressButton(
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.errorContainer)),
                        onPressed: () async {
                          if (token.isLocked && await lockAuth(localizedReason: AppLocalizations.of(context)!.authToDeclinePushRequest) == false) {
                            return;
                          }
                          dialogIsOpen = true;
                          await _showConfirmationDialog(token);
                          dialogIsOpen = false;
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.decline,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                              textScaler: const TextScaler.linear(titleScale),
                              textAlign: TextAlign.center,
                            ),
                            Icon(Icons.close_outlined, size: lineHeight * titleScale),
                          ],
                        )),
                  ),
                ],
              ),
            ),
          );
  }

  Future<void> _showConfirmationDialog(PushToken pushToken) => showDialog(
      useRootNavigator: false,
      context: globalNavigatorKey.currentContext!,
      builder: (BuildContext context) {
        final lineHeight = this.lineHeight;
        return DefaultDialog(
          title: Text(
            AppLocalizations.of(context)!.authenticationRequest,
            style: Theme.of(context).textTheme.titleLarge!,
            textAlign: TextAlign.center,
            textScaler: const TextScaler.linear(titleScale),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLocalizations.of(context)!.requestTriggerdByUserQuestion,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: Theme.of(context).textTheme.titleMedium?.fontSize),
                textScaler: const TextScaler.linear(questionScale),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: lineHeight),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Expanded(child: SizedBox()),
                  Expanded(
                    flex: 6,
                    child: PressButton(
                      onPressed: () {
                        globalRef?.read(pushRequestProvider.notifier).decline(pushToken, widget.pushRequest);
                        Navigator.of(context).pop();
                        if (mounted) setState(() => isHandled = true);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.yes,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                            textScaler: const TextScaler.linear(titleScale),
                            textAlign: TextAlign.center,
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              AppLocalizations.of(context)!.butDiscardIt,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimary.mixWith(Colors.grey.shade800),
                                  ),
                              textAlign: TextAlign.center,
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(flex: 2, child: SizedBox()),
                  Expanded(
                    flex: 6,
                    child: PressButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.errorContainer)),
                      onPressed: () {
                        //TODO: Notify issuer
                        globalRef?.read(pushRequestProvider.notifier).decline(pushToken, widget.pushRequest);
                        Navigator.of(context).pop();
                        if (mounted) setState(() => isHandled = true);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.no,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                            textScaler: const TextScaler.linear(titleScale),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            AppLocalizations.of(context)!.declineIt,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary.mixWith(Colors.grey.shade800)),
                            textAlign: TextAlign.center,
                            softWrap: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        );
      });
}
