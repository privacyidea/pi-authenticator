import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/tokens/push_token.dart';
import '../../../utils/customizations.dart';
import '../../../utils/lock_auth.dart';
import '../../../utils/riverpod_providers.dart';
import '../../../widgets/default_dialog.dart';
import '../../../widgets/press_button.dart';

class PushRequestListener extends ConsumerStatefulWidget {
  final Widget child;
  const PushRequestListener({required this.child, super.key});

  @override
  ConsumerState<PushRequestListener> createState() => _PushRequestListenerState();
}

class _PushRequestListenerState extends ConsumerState<PushRequestListener> {
  PushToken? lastPushToken;

  void _closePushRequestDialog() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokenWithPushRequest = ref.watch(tokenWithPushRequestProvider);
    if (tokenWithPushRequest != null && tokenWithPushRequest != lastPushToken) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => _pushRequestDialog(tokenWithPushRequest),
          useRootNavigator: false,
          barrierDismissible: false,
        );
      });
    }
    lastPushToken = tokenWithPushRequest;
    return widget.child;
  }

  Widget _pushRequestDialog(PushToken tokenWithPushRequest) => DefaultDialog(
        title: Center(child: Text(' ${tokenWithPushRequest.label}', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge!)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tokenWithPushRequest.pushRequests.peek()?.title ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                tokenWithPushRequest.pushRequests.peek()?.question ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  flex: 6,
                  child: PressButton(
                    onPressed: () async {
                      if (tokenWithPushRequest.isLocked && await lockAuth(localizedReason: AppLocalizations.of(context)!.authToAcceptPushRequest) == false)
                        return;
                      globalRef?.read(pushRequestProvider.notifier).acceptPop(tokenWithPushRequest);
                      _closePushRequestDialog();
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.accept.padRight(AppLocalizations.of(context)!.decline.length),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const Flexible(
                            child: Icon(Icons.check_outlined),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Expanded(child: SizedBox()),
                Expanded(
                  flex: 6,
                  child: PressButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.errorContainer)),
                      onPressed: () async {
                        if (tokenWithPushRequest.isLocked && await lockAuth(localizedReason: AppLocalizations.of(context)!.authToDeclinePushRequest) == false) {
                          return;
                        }
                        _showConfirmationDialog(tokenWithPushRequest);
                      },
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.decline.padRight(AppLocalizations.of(context)!.accept.length),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const Flexible(
                              flex: 1,
                              child: Icon(Icons.close_outlined),
                            ),
                          ],
                        ),
                      )),
                ),
              ],
            ),
          ],
        ),
      );

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
                                  _closePushRequestDialog();
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
                                  _closePushRequestDialog();
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
