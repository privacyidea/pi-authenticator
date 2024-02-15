import 'dart:ui';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../model/tokens/push_token.dart';
import '../../utils/globals.dart';
import '../../utils/lock_auth.dart';
import '../../utils/riverpod_providers.dart';
import '../press_button.dart';
import 'default_dialog.dart';

class PushRequestDialog extends StatefulWidget {
  final PushToken tokenWithPushRequest;

  const PushRequestDialog(this.tokenWithPushRequest, {super.key});

  @override
  State<PushRequestDialog> createState() => _PushRequestDialogState();
}

class _PushRequestDialogState extends State<PushRequestDialog> {
  bool isHandled = false;

  @override
  Widget build(BuildContext context) {
    final lineHeight = Theme.of(context).textTheme.titleLarge!.fontSize!;
    return isHandled
        ? const SizedBox()
        : Container(
            color: Colors.transparent,
            child: DefaultDialog(
              title: Text(
                widget.tokenWithPushRequest.label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge!,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: lineHeight,
                    child: Text(
                      widget.tokenWithPushRequest.pushRequests.peek()?.title ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: lineHeight,
                    child: Text(
                      widget.tokenWithPushRequest.pushRequests.peek()?.question ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: lineHeight * 0.5),
                  SizedBox(
                    height: lineHeight * 3,
                    child: PressButton(
                      onPressed: () async {
                        if (widget.tokenWithPushRequest.isLocked &&
                            await lockAuth(localizedReason: AppLocalizations.of(context)!.authToAcceptPushRequest) == false) return;
                        globalRef?.read(pushRequestProvider.notifier).acceptPop(widget.tokenWithPushRequest);
                        if (mounted) setState(() => isHandled = true);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Expanded(flex: 2, child: SizedBox()),
                          Expanded(
                            flex: 4,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                AppLocalizations.of(context)!.accept,
                                textAlign: TextAlign.left,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: lineHeight * 1.2),
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          Expanded(
                            flex: 2,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Icon(
                                Icons.check_outlined,
                                size: lineHeight * 1.5,
                              ),
                            ),
                          ),
                          const Expanded(flex: 2, child: SizedBox()),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: lineHeight * 0.5),
                  SizedBox(
                    height: lineHeight * 2,
                    child: PressButton(
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.errorContainer)),
                        onPressed: () async {
                          if (widget.tokenWithPushRequest.isLocked &&
                              await lockAuth(localizedReason: AppLocalizations.of(context)!.authToDeclinePushRequest) == false) {
                            return;
                          }
                          _showConfirmationDialog(widget.tokenWithPushRequest);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(flex: 2, child: SizedBox()),
                            Expanded(
                              flex: 4,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  AppLocalizations.of(context)!.decline,
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: lineHeight * 1.2),
                                ),
                              ),
                            ),
                            const Expanded(
                              child: SizedBox(),
                            ),
                            Expanded(
                              flex: 2,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Icon(
                                  Icons.close_outlined,
                                  size: lineHeight * 1.5,
                                ),
                              ),
                            ),
                            const Expanded(flex: 2, child: SizedBox()),
                          ],
                        )),
                  ),
                ],
              ),
            ),
          );
  }

  void _showConfirmationDialog(PushToken token) => showDialog(
      useRootNavigator: false,
      context: globalNavigatorKey.currentContext!,
      builder: (BuildContext context) {
        return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 0, 16.0),
                              child: Column(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.requestTriggerdByUserQuestion,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 60,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.close, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: PressButton(
                                onPressed: () {
                                  globalRef?.read(pushRequestProvider.notifier).declinePop(token);
                                  Navigator.of(context).pop();
                                  if (mounted) setState(() => isHandled = true);
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.yes,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        AppLocalizations.of(context)!.butDiscardIt,
                                        style: Theme.of(context).textTheme.bodySmall,
                                        textAlign: TextAlign.center,
                                        softWrap: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            Expanded(
                              flex: 3,
                              child: PressButton(
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.errorContainer)),
                                onPressed: () {
                                  //TODO: Notify issuer
                                  globalRef?.read(pushRequestProvider.notifier).declinePop(token);
                                  Navigator.of(context).pop();
                                  if (mounted) setState(() => isHandled = true);
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.no,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    FittedBox(
                                      child: Text(
                                        AppLocalizations.of(context)!.declineIt,
                                        style: Theme.of(context).textTheme.bodySmall,
                                        textAlign: TextAlign.center,
                                        softWrap: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ));
      });
}
