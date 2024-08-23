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
import 'dart:ui';

import 'package:flutter/material.dart';

class EnterPassphraseDialog extends StatefulWidget {
  static Future<String?> show(BuildContext context) => showDialog(
        context: context,
        builder: (context) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: const EnterPassphraseDialog(),
        ),
      );

  const EnterPassphraseDialog({super.key});

  @override
  State<EnterPassphraseDialog> createState() => _EnterPassphraseDialogState();
}

class _EnterPassphraseDialogState extends State<EnterPassphraseDialog> {
  String text = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter your passphrase'),
      content: TextField(
        decoration: const InputDecoration(hintText: 'Passphrase'),
        onChanged: (value) => setState(() {
          text = value;
        }),
      ),
      actions: [
        TextButton(
          onPressed: text.isNotEmpty ? () => Navigator.of(context).pop(text) : null,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
