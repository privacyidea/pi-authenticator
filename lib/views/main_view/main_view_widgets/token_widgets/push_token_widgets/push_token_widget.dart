import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../model/tokens/push_token.dart';
import '../../../../../utils/riverpod_providers.dart';
import '../../../../../widgets/press_button.dart';
import '../token_widget.dart';
import '../token_widget_base.dart';
import 'push_token_widget_tile.dart';

class PushTokenWidget extends TokenWidget {
  final PushToken token;
  const PushTokenWidget(this.token, {super.key});
  @override
  TokenWidgetBase build(BuildContext context) => TokenWidgetBase(
        token: token,
        tile: PushTokenWidgetTile(token),
        dragIcon: Icons.notifications,
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
                          PressButton(
                              onPressed: () {
                                globalRef?.read(pushRequestProvider.notifier).decline(token.pushRequests.pop());
                              },
                              child: const SizedBox(
                                width: 75,
                                child: Center(child: Text('Deny')),
                              )),
                          PressButton(
                            onPressed: () {
                              globalRef?.read(pushRequestProvider.notifier).accept(token.pushRequests.pop());
                            },
                            child: const SizedBox(
                              width: 75,
                              child: Center(child: Text('Approve')),
                            ),
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
