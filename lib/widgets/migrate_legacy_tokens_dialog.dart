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

import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';

class MigrateLegacyTokensDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MigrateLegacyTokensDialogState();
}

class _MigrateLegacyTokensDialogState extends State<MigrateLegacyTokensDialog> {
  Widget _content = Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[CircularProgressIndicator()],
  );

  @override
  void initState() {
    super.initState();
    _migrateTokens();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        title: Text(Localization.of(context).migrationDialogTitle),
        content: _content,
        actions: <Widget>[
          RaisedButton(
            child: Text(Localization.of(context).dismiss),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _migrateTokens() async {
    // Load legacy tokens and add them to the storage.
    log('Attempt to load legacy tokens.',
        name: 'migrate_legacy_tokens_dialog.dart');

    List<Token> legacyTokens = await StorageUtil.loadAllTokensLegacy();
    List<PushToken> currentPushToken =
        (await StorageUtil.loadAllTokens()).whereType<PushToken>().toList();

    for (Token old in legacyTokens) {
      // Skip push token which already exist (by serial)
      if (old is PushToken) {
        if (currentPushToken.any((e) => old.serial == e.serial)) {
          continue;
        }
      }
      await StorageUtil.saveOrReplaceToken(old);
    }

    String text;

    if (legacyTokens.isEmpty) {
      text = Localization.of(context).migrationNoTokens;
    } else {
      text = Localization.of(context).migrationSuccess;
    }

    final ScrollController controller = ScrollController();

    setState(() {
      _content = Scrollbar(
        isAlwaysShown: true,
        controller: controller,
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(text)],
          ),
        ),
      );
    });
  }
}
