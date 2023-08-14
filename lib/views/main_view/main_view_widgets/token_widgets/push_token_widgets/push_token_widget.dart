import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../model/mixins/sortable_mixin.dart';
import '../../../../../model/tokens/push_token.dart';
import '../../../../../utils/customizations.dart';
import '../../../../../utils/identifiers.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../widgets/press_button.dart';
import '../token_widget.dart';
import '../token_widget_actions/edit_push_token_action.dart';
import '../token_widget_base.dart';
import 'push_token_widget_tile.dart';

class PushTokenWidget extends TokenWidget {
  final PushToken token;
  final SortableMixin? previousSortable;
  final bool withDivider;

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
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: _rolloutFailed(token) ? RolloutFailedWidget(token: token) : RolloutPushTokenWidget(token: token),
            ),
          ),
        if (token.pushRequests.peek() != null)
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    token.pushRequests.peek()?.question ?? 'No request',
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Flexible(child: SizedBox()),
                      Flexible(
                        flex: 4,
                        child: PressButton(
                          onPressed: () => globalRef?.read(pushRequestProvider.notifier).accept(token.pushRequests.pop()),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.accept,
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                              ),
                              const Icon(Icons.check, size: 15),
                            ],
                          ),
                        ),
                      ),
                      const Flexible(child: SizedBox()),
                      Flexible(
                        flex: 4,
                        child: PressButton(
                            onPressed: () => globalRef?.read(pushRequestProvider.notifier).decline(token.pushRequests.pop()),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.decline,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                ),
                                const Icon(Icons.close, size: 15),
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
      ],
    );
  }
}

class RolloutPushTokenWidget extends StatelessWidget {
  final PushToken token;
  const RolloutPushTokenWidget({required this.token, super.key});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          Text(
            _rolloutMsg(token, context),
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ],
      );
}

class RolloutFailedWidget extends StatelessWidget {
  final PushToken token;

  const RolloutFailedWidget({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _rolloutMsg(token, context),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width * 0.35,
                child: PressButton(
                  onPressed: () => globalRef?.read(tokenProvider.notifier).rolloutPushToken(token),
                  child: Text(
                    AppLocalizations.of(context)!.retryRollout,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: width * 0.35,
                child: PressButton(
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.errorContainer)),
                  onPressed: () => _showDialog(),
                  child: Text(
                    AppLocalizations.of(context)!.delete,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDialog() => showDialog(
      context: globalNavigatorKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.confirmDeletion,
          ),
          content: Text(AppLocalizations.of(context)!.confirmDeletionOf(token.label)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
            TextButton(
              onPressed: () {
                globalRef?.read(tokenProvider.notifier).removeToken(token);
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context)!.delete,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
          ],
        );
      });
}

bool _rolloutFailed(PushToken token) => switch (token.rolloutState) {
      PushRollOutState.generateingRSAKeyPairFailed => true,
      PushRollOutState.sendRSAPublicKeyFailed => true,
      PushRollOutState.parsingResponseFailed => true,
      _ => false,
    };

String _rolloutMsg(PushToken token, BuildContext context) => switch (token.rolloutState) {
      PushRollOutState.rolloutNotStarted => AppLocalizations.of(context)!.rollingOut,
      PushRollOutState.generateingRSAKeyPair => AppLocalizations.of(context)!.generatingRSAKeyPair,
      PushRollOutState.generateingRSAKeyPairFailed => AppLocalizations.of(context)!.generatingRSAKeyPairFailed,
      PushRollOutState.sendRSAPublicKey => AppLocalizations.of(context)!.sendingRSAPublicKey,
      PushRollOutState.sendRSAPublicKeyFailed => AppLocalizations.of(context)!.sendingRSAPublicKeyFailed,
      PushRollOutState.parsingResponse => AppLocalizations.of(context)!.parsingResponse,
      PushRollOutState.parsingResponseFailed => AppLocalizations.of(context)!.parsingResponseFailed,
      PushRollOutState.rolloutComplete => AppLocalizations.of(context)!.rolloutCompleted,
    };
