/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'package:flutter/material.dart';

import '../../../../model/tokens/day_password_token.dart';
import '../../../../model/tokens/hotp_token.dart';
import '../../../../model/tokens/push_token.dart';
import '../../../../model/tokens/steam_token.dart';
import '../../../../model/tokens/token.dart';
import '../../../../model/tokens/totp_token.dart';
import 'day_password_token_widgets/day_password_token_widget.dart';
import 'day_password_token_widgets/day_password_token_widget_tile.dart';
import 'hotp_token_widgets/hotp_token_widget.dart';
import 'hotp_token_widgets/hotp_token_widget_tile.dart';
import 'push_token_widgets/push_token_widget.dart';
import 'push_token_widgets/push_token_widget_tile.dart';
import 'token_widget.dart';
import 'totp_token_widgets/totp_token_widget.dart';
import 'totp_token_widgets/totp_token_widget_tile.dart';

abstract class TokenWidgetBuilder {
  static TokenWidget fromToken(Token token, {Key? key}) {
    return switch (token.runtimeType) {
      const (TOTPToken) => TOTPTokenWidget(token as TOTPToken, key: key),
      const (HOTPToken) => HOTPTokenWidget(token as HOTPToken, key: key),
      const (PushToken) => PushTokenWidget(token as PushToken, key: key),
      const (DayPasswordToken) => DayPasswordTokenWidget(token as DayPasswordToken, key: key),
      const (SteamToken) => TOTPTokenWidget(token as SteamToken, key: key),
      _ => throw UnimplementedError('Token type (${token.runtimeType}) not supported in this Version of the App')
    };
  }

  static Widget previewFromToken(Token token, {Key? key}) => switch (token.runtimeType) {
        const (TOTPToken) => TOTPTokenWidgetTile(token as TOTPToken, key: key, isPreview: true),
        const (HOTPToken) => HOTPTokenWidgetTile(token as HOTPToken, key: key, isPreview: true),
        const (PushToken) => PushTokenWidgetTile(token as PushToken, key: key, isPreview: true),
        const (DayPasswordToken) => DayPasswordTokenWidgetTile(token as DayPasswordToken, key: key, isPreview: true),
        const (SteamToken) => TOTPTokenWidgetTile(token as SteamToken, key: key, isPreview: true),
        _ => throw UnimplementedError('Preview for token type (${token.runtimeType}) not supported in this Version of the App')
      };
}
