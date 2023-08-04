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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CircularProgressIndicator(),
                  Text(AppLocalizations.of(context)!.rollingOut),
                ],
              ),
            ),
          ),
        if (token.pushRequests.peek() != null)
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(token.pushRequests.peek()?.question ?? 'No request'),
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
