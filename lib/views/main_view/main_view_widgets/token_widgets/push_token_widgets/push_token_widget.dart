import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../model/mixins/sortable_mixin.dart';
import '../../../../../model/tokens/push_token.dart';
import '../../../../../utils/customizations.dart';
import '../../../../../utils/identifiers.dart';
import '../../../../../utils/lock_auth.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../widgets/press_button.dart';
import '../token_widget.dart';
import '../token_widget_base.dart';
import 'actions/edit_push_token_action.dart';
import 'push_token_widget_tile.dart';
import 'rollout_failed_widget.dart';
import 'rollout_widget.dart';

class PushTokenWidget extends TokenWidget {
  final PushToken token;
  final SortableMixin? previousSortable;
  final bool withDivider;
  bool get rolloutFailed => switch (token.rolloutState) {
        PushTokenRollOutState.generatingRSAKeyPairFailed => true,
        PushTokenRollOutState.sendRSAPublicKeyFailed => true,
        PushTokenRollOutState.parsingResponseFailed => true,
        _ => false,
      };

  const PushTokenWidget(
    this.token, {
    this.withDivider = true,
    this.previousSortable,
    super.key,
  });

  @override
  TokenWidgetBase build(BuildContext context) {
    return TokenWidgetBase(
      key: Key(token.id),
      token: token,
      tile: PushTokenWidgetTile(token),
      dragIcon: Icons.notifications,
      editAction: EditPushTokenAction(token: token, key: Key('${token.id}editAction')),
      stack: [
        if (!token.isRolledOut)
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: rolloutFailed ? RolloutFailedWidget(token: token) : RolloutWidget(token: token),
              ),
            ),
          ),
        if (token.pushRequests.peek() != null)
          SizedBox(
            height: 100,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${token.pushRequests.peek()?.title ?? 'title'}\n${token.pushRequests.peek()?.question ?? 'No request'}',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Flexible(child: SizedBox()),
                        Flexible(
                          flex: 5,
                          child: PressButton(
                            onPressed: () async {
                              if (token.isLocked &&
                                  await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.authToAcceptPushRequest) == false) return;
                              final pr = token.pushRequests.peek();
                              if (pr != null) {
                                globalRef?.read(pushRequestProvider.notifier).accept(pr);
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    AppLocalizations.of(context)!.accept,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                  ),
                                ),
                                const Flexible(
                                  child: Icon(Icons.check_outlined),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Flexible(
                          flex: 2,
                          child: SizedBox(),
                        ),
                        Flexible(
                          flex: 5,
                          child: PressButton(
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.errorContainer)),
                              onPressed: () async {
                                if (token.isLocked &&
                                    await lockAuth(context: context, localizedReason: AppLocalizations.of(context)!.authToDeclinePushRequest) == false) return;
                                _showDialog();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      AppLocalizations.of(context)!.decline,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      overflow: TextOverflow.fade,
                                      softWrap: false,
                                    ),
                                  ),
                                  const Flexible(
                                    flex: 1,
                                    child: Icon(Icons.close_outlined),
                                  ),
                                ],
                              )),
                        ),
                        const Flexible(child: SizedBox()),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showDialog() => showDialog(
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
                                    'Was this request triggerd by you?',
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
                                      'Yes',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'But discard it',
                                      style: Theme.of(context).textTheme.bodySmall,
                                      textAlign: TextAlign.center,
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
                                  final pr = token.pushRequests.peek();
                                  if (pr != null) {
                                    globalRef?.read(pushRequestProvider.notifier).decline(pr);
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      'No',
                                      style: Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'Decline it',
                                      style: Theme.of(context).textTheme.bodySmall,
                                      textAlign: TextAlign.center,
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
