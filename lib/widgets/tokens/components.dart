/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';

class TokenTile extends StatelessWidget {
  final Widget _avatar;
  final Widget _title;
  final Widget _subtitle;

  TokenTile({avatar, title, subtitle})
      : _avatar = avatar,
        _title = title,
        _subtitle = subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.all(5),
          child: _avatar,
        ),
        Expanded(
          child: ListTile(
            title: _title,
            subtitle: _subtitle,
          ),
        ),
      ],
    );
  }
}

class TokenAvatar extends StatelessWidget {
  final int? _avatarColor;
  final String? _avatarImagePath;
  final double _radius;

  const TokenAvatar(this._avatarColor, this._avatarImagePath, this._radius);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: _avatarColor == null ? null : Color(_avatarColor!),
      backgroundImage:
          _avatarImagePath == null ? null : FileImage(File(_avatarImagePath!)),
      radius: _radius,
    );
  }
}

class TokenSubtitle extends StatelessWidget {
  final Token _token;

  const TokenSubtitle(this._token);

  @override
  Widget build(BuildContext context) {
    TextStyle style = Theme.of(context)
        .textTheme
        .headline6!
        .copyWith(fontWeight: FontWeight.normal);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _token is PushToken
            ? Text((_token as PushToken).serial, style: style)
            : Text(_token.label, style: style),
        Text(_token.issuer, style: style)
      ],
    );
  }
}
