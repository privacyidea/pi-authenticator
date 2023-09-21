import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/utils/app_customizer.dart';
import 'package:privacyidea_authenticator/utils/customizations.dart';
import 'package:privacyidea_authenticator/utils/lock_auth.dart';
import 'package:privacyidea_authenticator/widgets/default_dialog.dart';
import 'package:privacyidea_authenticator/widgets/press_button.dart';

import '../../../model/tokens/push_token.dart';
import '../../../utils/riverpod_providers.dart';

class PushRequestOverlay extends StatelessWidget {
  final PushToken tokenWithPushRequest;
  const PushRequestOverlay(this.tokenWithPushRequest, {super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      title: Text(' ${tokenWithPushRequest.label}', style: Theme.of(context).textTheme.titleLarge!),
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
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      Theme.of(context).brightness == Brightness.light ? ApplicationCustomizer.acceptColorLight : ApplicationCustomizer.acceptColorDark,
                    ),
                  ),
                  onPressed: () async {
                    if (tokenWithPushRequest.isLocked &&
                        await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.authToAcceptPushRequest) == false) return;
                    final pr = tokenWithPushRequest.pushRequests.peek();
                    if (pr != null) {
                      globalRef?.read(pushRequestProvider.notifier).accept(pr);
                    }
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
                        Flexible(
                          child: Icon(
                            Icons.check_outlined,
                            color: Theme.of(context).brightness == Brightness.light
                                ? ApplicationCustomizer.onAcceptColorLight
                                : ApplicationCustomizer.onAcceptColorDark,
                          ),
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
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).brightness == Brightness.light ? ApplicationCustomizer.declineColorDark : ApplicationCustomizer.declineColorDark,
                      ),
                    ),
                    onPressed: () async {
                      if (tokenWithPushRequest.isLocked &&
                          await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.authToDeclinePushRequest) == false) {
                        return;
                      }
                      _showDialog(tokenWithPushRequest);
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
                          Flexible(
                            flex: 1,
                            child: Icon(Icons.close_outlined,
                                color: Theme.of(context).brightness == Brightness.light
                                    ? ApplicationCustomizer.onDeclineColorLight
                                    : ApplicationCustomizer.onDeclineColorDark),
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
  }
}

void _showDialog(PushToken token) => showDialog(
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
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).brightness == Brightness.light
                                      ? ApplicationCustomizer.acceptColorLight
                                      : ApplicationCustomizer.acceptColorDark,
                                ),
                              ),
                              onPressed: () {
                                final pr = token.pushRequests.peek();
                                if (pr != null) {
                                  globalRef?.read(pushRequestProvider.notifier).decline(pr);
                                }
                                Navigator.of(context).pop();
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
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).brightness == Brightness.light
                                      ? ApplicationCustomizer.declineColorDark
                                      : ApplicationCustomizer.declineColorDark,
                                ),
                              ),
                              onPressed: () {
                                //TODO: Notify issuer
                                final pr = token.pushRequests.peek();
                                if (pr != null) {
                                  globalRef?.read(pushRequestProvider.notifier).decline(pr);
                                }
                                Navigator.of(context).pop();
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
