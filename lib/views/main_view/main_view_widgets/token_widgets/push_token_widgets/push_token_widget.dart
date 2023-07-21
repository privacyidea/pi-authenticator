import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token/push_token.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/push_token_widgets/push_token_widget_tile.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_base.dart';
import 'dart:ui';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/widgets/press_button.dart';

class PushTokenWidget extends TokenWidget {
  final PushToken token;

  PushTokenWidget(this.token, {super.key});

  @override
  TokenWidgetBase build(BuildContext context) {
    return TokenWidgetBase(
      token: token,
      tile: PushTokenWidgetTile(token),
      stack: [
        Visibility(
          visible: !token.isRolledOut,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: ListTile(
                title: Column(
                  children: <Widget>[
                    CircularProgressIndicator(),
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
                            child: SizedBox(
                              width: 75,
                              child: Center(child: Text('Deny')),
                            )),
                        PressButton(
                          onPressed: () {
                            globalRef?.read(pushRequestProvider.notifier).accept(token.pushRequests.pop());
                          },
                          child: SizedBox(
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
}
