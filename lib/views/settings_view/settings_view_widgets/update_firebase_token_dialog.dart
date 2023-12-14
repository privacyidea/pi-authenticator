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
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';

import '../../../model/tokens/push_token.dart';
import '../../../utils/globals.dart';
import '../../../utils/push_provider.dart';
import '../../../widgets/default_dialog.dart';

class UpdateFirebaseTokenDialog extends StatefulWidget {
  const UpdateFirebaseTokenDialog({super.key});

  @override
  State<StatefulWidget> createState() => _UpdateFirebaseTokenDialogState();
}

class _UpdateFirebaseTokenDialogState extends State<UpdateFirebaseTokenDialog> {
  Widget _content = const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [CircularProgressIndicator()],
  );

  @override
  void initState() {
    super.initState();
    _updateFbTokens();
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

  void _updateFbTokens() async {
    Logger.info('Starting update of firebase token.', name: 'update_firebase_token_dialog.dart#_updateFbTokens');

    // TODO What to do with poll only tokens if google-services is used?

    final tuple = await PushProvider.updateFirebaseToken();
    if (tuple == null) {
      showMessage(message: AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorSynchronizationNoNetworkConnection);
      return;
    }
    late List<PushToken> tokenWithFailedUpdate;
    late List<PushToken> tokenWithOutUrl;
    (tokenWithFailedUpdate, tokenWithOutUrl) = tuple;

    if (tokenWithFailedUpdate.isEmpty && tokenWithOutUrl.isEmpty) {
      if (!mounted) return;
      setState(() {
        _content = Text(AppLocalizations.of(context)!.allTokensSynchronized);
      });
    } else {
      List<Widget> children = [];

      if (tokenWithFailedUpdate.isNotEmpty) {
        children.add(
          Text('${AppLocalizations.of(globalNavigatorKey.currentContext!)!.synchronizationFailed}\n'),
        );
        for (PushToken p in tokenWithFailedUpdate) {
          children.add(Text('• ${p.label}'));
        }
      }

      if (tokenWithOutUrl.isNotEmpty) {
        if (children.isNotEmpty) {
          children.add(const Divider());
        }

        children.add(Text(AppLocalizations.of(globalNavigatorKey.currentContext!)!.tokensDoNotSupportSynchronization));
        for (PushToken p in tokenWithOutUrl) {
          children.add(Text('• ${p.label}'));
        }
      }

      final ScrollController controller = ScrollController();
      if (!mounted) return;
      setState(() {
        _content = Scrollbar(
          thumbVisibility: true,
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
}
