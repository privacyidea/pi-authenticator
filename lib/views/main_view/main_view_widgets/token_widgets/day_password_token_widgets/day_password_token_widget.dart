import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens/day_password_token.dart';

import '../token_widget.dart';
import '../token_widget_base.dart';
import 'day_password_token_widget_tile.dart';

class DayPasswordTokenWidget extends TokenWidget {
  final DayPasswordToken token;

  const DayPasswordTokenWidget(this.token, {super.key});

  @override
  TokenWidgetBase build(BuildContext context) {
    return TokenWidgetBase(
      token: token,
      tile: DayPasswordTokenWidgetTile(token),
      dragIcon: Icons.calendar_month,
    );
  }
}
