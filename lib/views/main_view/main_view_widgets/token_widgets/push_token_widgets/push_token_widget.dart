import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens/push_token/push_token.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/push_token_widgets/push_token_widget_tile.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/token_widgets/token_widget_base.dart';
import 'dart:ui';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      ],
    );
  }
}
