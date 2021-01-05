/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2019 NetKnights GmbH

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

import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pi_authenticator_legacy/pi_authenticator_legacy.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

class UpdateFirebaseTokenDialog extends StatefulWidget {
  UpdateFirebaseTokenDialog();

  @override
  State<StatefulWidget> createState() => _UpdateFirebaseTokenDialogState();
}

class _UpdateFirebaseTokenDialogState extends State<UpdateFirebaseTokenDialog> {
  String _title;
  Widget _content = Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[CircularProgressIndicator()],
  );
  MaterialButton _button;

  @override
  void initState() {
    super.initState();

    _updateFbTokens();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _title = "Updating Firebase Tokens";
  }

  @override
  Widget build(BuildContext context) {
    print('Starting update!');

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        title: Text(_title),
        content: _content,
        actions: <Widget>[_button],
      ),
    );
  }

  void _updateFbTokens() async {
    String token = await FirebaseMessaging().getToken();

    List<PushToken> tokenList =
        (await StorageUtil.loadAllTokens()).whereType<PushToken>().toList();

    // TODO Is there a good way to handle these tokens?
    List<PushToken> tokenWithOutUrl =
        tokenList.where((e) => e.url == null).toList();
    List<PushToken> tokenWithUrl =
        tokenList.where((e) => e.url != null).toList();
    List<PushToken> tokenWithFailedUpdate = [];

    for (PushToken p in tokenWithUrl) {
      // POST /ttype/push HTTP/1.1
      //Host: example.com
      //
      //new_fb_token=<new firebase token>
      //serial=<tokenserial>element
      //timestamp=<timestamp>
      //signature=SIGNATURE(<new firebase token>|<tokenserial>|<timestamp>)

      String timestamp = DateTime.now().toUtc().toIso8601String();

      String message = '$token|${p.serial}|$timestamp';

      String signature = p.privateTokenKey == null
          ? await Legacy.sign(p.serial, message)
          : createBase32Signature(p.getPrivateTokenKey(), utf8.encode(message));

      Response response =
          await doPost(sslVerify: p.sslVerify, url: p.url, body: {
        'new_fb_token': token,
        'serial': p.serial,
        'timestamp': timestamp,
        'signature': signature
      });

      if (response.statusCode == 200) {
        log('Updating firebase token for push token: ${p.serial} succeeded!');
      } else {
        log('Updating firebase token for push token: ${p.serial} failed!',
            name: 'main_screen.dart');
        tokenWithFailedUpdate.add(p);
      }
    }

    if (tokenWithFailedUpdate.isEmpty && tokenWithOutUrl.isEmpty) {
      setState(() {
        _content = Text('Update was successful.');
        _button = FlatButton(
          child: Text(Localization.of(context).dismiss),
          onPressed: () => Navigator.pop(context),
        );
      });
    } else {
      List<Widget> children = [];

      // TODO Remove this:
//      tokenWithFailedUpdate.addAll(List<PushToken>.generate(
//          5, (index) => PushToken(label: 'Token $index')));
//      tokenWithOutUrl.addAll(List<PushToken>.generate(
//          5, (index) => PushToken(label: 'Token $index')));

      if (tokenWithFailedUpdate.isNotEmpty) {
        List<Widget> failedToken = [];

        failedToken.add(Text(
          'Update failed for the following token, please try again:',
        )); // TODO Add translation
        for (PushToken p in tokenWithFailedUpdate) {
          failedToken.add(Text('• ${p.label}'));
        }

        children.add(Padding(
          padding: EdgeInsets.only(bottom: 15),
          child: Column(
            children: failedToken,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ));
      }

      if (tokenWithOutUrl.isNotEmpty) {
        children.add(Text(
            'Updating the following token is not supported, these must be rolled out again:')); // TODO Add translation
        for (PushToken p in tokenWithOutUrl) {
          children.add(Text('• ${p.label}'));
        }
      }

      setState(() {
        _content = SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        );
        _button = RaisedButton(
          child: Text(Localization.of(context).dismiss),
          onPressed: () => Navigator.pop(context),
        );
      });
    }
  }
}
