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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:privacyidea_authenticator/model/tokens.dart';
import 'package:privacyidea_authenticator/utils/localization_utils.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class MigrateLegacyTokensDialog extends StatefulWidget {
  final Uri _githubLink =
      Uri.parse('https://github.com/privacyidea/pi-authenticator/issues');

  @override
  State<StatefulWidget> createState() => _MigrateLegacyTokensDialogState();
}

class _MigrateLegacyTokensDialogState extends State<MigrateLegacyTokensDialog> {
  Widget _content = Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[CircularProgressIndicator()],
  );

  TapGestureRecognizer _tabRecognizer;
  var problem; // I.e. Error or Exception

  @override
  void initState() {
    super.initState();
    _tabRecognizer = TapGestureRecognizer()
      ..onTap = () => _launchUri(widget._githubLink);
    _migrateTokens();
  }

  @override
  void dispose() {
    _tabRecognizer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        title: Text('Migrating tokens from previous version'),
        content: _content,
        actions: <Widget>[
//          Visibility(
//            visible: problem != null,
//            child: RaisedButton(
//              onPressed: () =>
//                  Clipboard.setData(new ClipboardData(text: '$problem')),
//              child: Text('Copy'),
//            ),
//          ),
          RaisedButton(
            child: Text(Localization.of(context).dismiss),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _launchUri(Uri link) async {
    String uri = link.toString();
    if (await canLaunch(uri)) launch(uri);
  }

  void _migrateTokens() async {
    List<Widget> children = [];

    // Load legacy tokens and add them to the storage.
    log('Attempt to load legacy tokens.',
        name: 'migrate_legacy_tokens_dialog.dart');
    try {
      List<Token> existingTokens = await StorageUtil.loadAllTokens();
      List<Token> legacyTokens = await StorageUtil.loadAllTokensLegacy();

      for (Token t in legacyTokens) {
        // TODO? Prevent migrating token if it already was migrated!
        // This would likely overwrite the existing token.
//        if ((t is OTPToken &&
//                existingTokens
//                    .whereType<OTPToken>()
//                    .any((e) => e.secret == t.secret && e.type == t.type)) ||
//            (t is PushToken &&
//                existingTokens
//                    .whereType<PushToken>()
//                    .any((e) => e.serial == t.serial))) {
//          continue;
//        }
        await StorageUtil.saveOrReplaceToken(t);
      }

      if (legacyTokens.isEmpty) {
        children.add(Text('No tokens exist that could be migrated.'));
      }
    } catch (e) {
      // Catch Exceptions and Errors together with stacktrace:
      String version = (await PackageInfo.fromPlatform()).version;
      problem = 'Version: $version\n$e';

//      children.add(
//        RichText(
//          text: TextSpan(
//              children: [
//                TextSpan(
//                  text: '${widget._githubLink}',
//                  recognizer: _tabRecognizer,
//                  style: Theme.of(context)
//                      .textTheme
//                      .subtitle1
//                      .copyWith(color: Colors.blue),
//                ),
//                TextSpan(
//                  text: ' with the error information below:',
//                  style: Theme.of(context).textTheme.subtitle1,
//                ),
//              ],
//              text: 'Something went wrong, please submit an issue under ',
//              style: Theme.of(context).textTheme.subtitle1),
//        ),
//      );
      children.add(Text('Something went wrong:'));
      children.add(Padding(
        padding: EdgeInsets.only(top: 10),
        child: Container(
          child: Text('$problem'),
          color: Colors.black26,
        ),
      ));
    }

    if (children.isEmpty) {
      children.add(Text('All tokens migrated successfully'));
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
            children: children,
          ),
        ),
      );
    });
  }
}
