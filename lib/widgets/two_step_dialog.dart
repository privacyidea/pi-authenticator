/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2023 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';
import 'package:privacyidea_authenticator/widgets/default_dialog.dart';

import 'widget_keys.dart';

class GenerateTwoStepDialog extends StatelessWidget {
  final int _saltLength;
  final int _iterations;
  final int _keyLength;
  final Uint8List _password;

  const GenerateTwoStepDialog({super.key, required int saltLength, required int iterations, required int keyLength, required Uint8List password})
      : _saltLength = saltLength,
        _iterations = iterations,
        _keyLength = keyLength,
        _password = password;

  void _do2Step(BuildContext context) async {
    // 1. Generate salt.
    final Uint8List salt = secureRandom().nextBytes(_saltLength);

    // 2. Generate secret.
    final Uint8List generatedSecret = await pbkdf2(
      salt: salt,
      iterations: _iterations,
      keyLength: _keyLength,
      password: _password,
    );

    String phoneChecksum = await generatePhoneChecksum(phonePart: salt);
    if (!context.mounted) {
      log('GenerateTwoStepDialog: context is not mounted anymore. Aborting.');
      return;
    }

    // 3. Show phone part if this widget is still mounted.
    Navigator.of(context).pop(generatedSecret);
    showAsyncDialog(
        barrierDismissible: false,
        builder: (context) => TwoStepDialog(
              phoneChecksum: phoneChecksum,
            ));
  }

  @override
  Widget build(BuildContext context) {
    _do2Step(context);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: DefaultDialog(
        scrollable: true,
        title: Text(
          AppLocalizations.of(context)!.generatingPhonePart,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        content: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[CircularProgressIndicator()],
        ),
      ),
    );
  }
}

class TwoStepDialog extends StatefulWidget {
  final String phoneChecksum;
  const TwoStepDialog({Key? key, required this.phoneChecksum}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _TwoStepDialogState();
}

class _TwoStepDialogState extends State<TwoStepDialog> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: WillPopScope(
        onWillPop: () async => false,
        // Prevents closing the dialog without returning a secret.
        child: DefaultDialog(
          scrollable: true,
          title: Text(
            AppLocalizations.of(context)!.phonePart,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          content: Text(
            splitPeriodically(widget.phoneChecksum, 4),
            key: twoStepDialogContent,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.dismiss,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            )
          ],
        ),
      ),
    );
  }
}
