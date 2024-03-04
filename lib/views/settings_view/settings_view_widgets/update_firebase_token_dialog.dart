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

import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';

import '../../../widgets/dialog_widgets/default_dialog.dart';

class UpdateFirebaseTokenDialog extends StatefulWidget {
  const UpdateFirebaseTokenDialog({super.key});

  @override
  State<StatefulWidget> createState() => _UpdateFirebaseTokenDialogState();
}

class _UpdateFirebaseTokenDialogState extends State<UpdateFirebaseTokenDialog> {
  final Widget _content = const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [CircularProgressIndicator()],
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultDialog(
      scrollable: true,
      title: Text(AppLocalizations.of(context)!.synchronizingTokens),
      content: _content,
      actions: [
        TextButton(
          child: Text(AppLocalizations.of(context)!.dismiss),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
