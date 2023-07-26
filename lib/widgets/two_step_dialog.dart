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

import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

class TwoStepDialog extends StatefulWidget {
  final int _saltLength;
  final int _iterations;
  final int _keyLength;
  final Uint8List _password;

  const TwoStepDialog({super.key, required int saltLength, required int iterations, required int keyLength, required Uint8List password})
      : _saltLength = saltLength,
        _iterations = iterations,
        _keyLength = keyLength,
        _password = password;

  @override
  State<StatefulWidget> createState() => _TwoStepDialogState();
}

class _TwoStepDialogState extends State<TwoStepDialog> {
  late String _title;
  Widget _content = const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[CircularProgressIndicator()],
  );
  VoidCallback? _onPressed;
  late Uint8List _generatedSecret;

  @override
  void initState() {
    super.initState();

    _do2Step();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _title = AppLocalizations.of(context)!.generatingPhonePart;
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: WillPopScope(
        onWillPop: () async => false,
        // Prevents closing the dialog without returning a secret.
        child: AlertDialog(
          title: Text(_title),
          content: _content,
          actions: [
            TextButton(
              onPressed: _onPressed,
              child: Text(
                AppLocalizations.of(context)!.dismiss,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _do2Step() async {
    // 1. Generate salt.
    Uint8List salt = secureRandom().nextBytes(widget._saltLength);

    // 2. Generate secret.
    _generatedSecret = await pbkdf2(
      salt: salt,
      iterations: widget._iterations,
      keyLength: widget._keyLength,
      password: widget._password,
    );

    // 3. Show phone part.
    String phoneChecksum = await generatePhoneChecksum(phonePart: salt);
    String show = splitPeriodically(phoneChecksum, 4);

    // Update UI.
    setState(() {
      _title = AppLocalizations.of(context)!.phonePart;
      _content = Text(show);
      _onPressed = () => Navigator.of(context).pop(_generatedSecret);
    });
  }
}
