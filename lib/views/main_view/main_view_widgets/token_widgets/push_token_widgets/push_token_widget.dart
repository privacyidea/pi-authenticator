import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../model/mixins/sortable_mixin.dart';
import '../../../../../model/tokens/push_token.dart';
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
    super.key,
    this.previousSortable,
  });

  @override
  TokenWidgetBase build(BuildContext context) {
    return TokenWidgetBase(
      token: token,
      tile: PushTokenWidgetTile(token),
      dragIcon: Icons.notifications,
      editAction: EditPushTokenAction(token: token),
      stack: [
        Visibility(
          visible: !token.isRolledOut,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: ListTile(
                title: Column(
                  children: <Widget>[
                    const CircularProgressIndicator(),
                    Text(AppLocalizations.of(context)!.rollingOut),
                  ],
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: token.pushRequests.peek() != null,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: ListTile(
                title: Column(
                  children: <Widget>[
                    Text(
                      token.pushRequests.peek()?.question ?? 'No request',
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Flexible(
                          child: SizedBox(),
                        ),
                        Flexible(
                          flex: 4,
                          child: PressButton(
                            onPressed: () {
                              globalRef?.read(pushRequestProvider.notifier).accept(token.pushRequests.pop());
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.accept,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const Icon(Icons.check, size: 15),
                              ],
                            ),
                          ),
                        ),
                        const Flexible(
                          child: SizedBox(),
                        ),
                        Flexible(
                          flex: 4,
                          child: PressButton(
                              onPressed: () {
                                globalRef?.read(pushRequestProvider.notifier).decline(
                                      token.pushRequests.pop(),
                                    );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.decline,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const Icon(Icons.close, size: 15),
                                ],
                              )),
                        ),
                        const Flexible(
                          child: SizedBox(),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}