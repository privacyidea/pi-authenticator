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

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/network_utils.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';

import '../../../model/tokens/push_token.dart';
import '../../../utils/customizations.dart';

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
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        title: Text(AppLocalizations.of(context)!.synchronizingTokens),
        content: _content,
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.dismiss),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _updateFbTokens() async {
    Logger.info('Starting update of firebase token.', name: 'update_firebase_token_dialog.dart#_updateFbTokens');

    List<PushToken> tokenList = (await StorageUtil.loadAllTokens()).whereType<PushToken>().toList();

    // TODO What to do with poll only tokens if google-services is used?

    String? token = await PushProvider.getFBToken();

    // TODO Is there a good way to handle these tokens?
    List<PushToken> tokenWithOutUrl = tokenList.where((e) => e.url == null).toList();
    List<PushToken> tokenWithUrl = tokenList.where((e) => e.url != null).toList();
    List<PushToken> tokenWithFailedUpdate = [];

    for (PushToken pushToken in tokenWithUrl) {
      // POST /ttype/push HTTP/1.1
      // Host: example.com
      //
      // new_fb_token=<new firebase token>
      // serial=<tokenserial>element
      // timestamp=<timestamp>
      // signature=SIGNATURE(<new firebase token>|<tokenserial>|<timestamp>)

      String timestamp = DateTime.now().toUtc().toIso8601String();

      String message = '$token|${pushToken.serial}|$timestamp';
      String? signature = await trySignWithToken(pushToken, message);
      if (signature == null) {
        return;
      }

      Response response;
      try {
        response = await postRequest(
            sslVerify: pushToken.sslVerify!,
            url: pushToken.url!,
            body: {'new_fb_token': token, 'serial': pushToken.serial, 'timestamp': timestamp, 'signature': signature});

        if (response.statusCode == 200) {
          Logger.info('Updating firebase token for push token: ${pushToken.serial} succeeded!', name: 'update_firebase_token_dialog.dart#_updateFbTokens');
        } else {
          Logger.warning('Updating firebase token for push token: ${pushToken.serial} failed!', name: 'update_firebase_token_dialog.dart#_updateFbTokens');
          tokenWithFailedUpdate.add(pushToken);
        }
      } on SocketException catch (e, s) {
        Logger.warning(
          'Socket exception occurred: $e',
          name: 'update_firebase_token_dialog.dart#_updateFbTokens',
          stackTrace: s,
        );
        ScaffoldMessenger.of(globalNavigatorKey.currentContext!).showSnackBar(SnackBar(
          content: Text(
            AppLocalizations.of(globalNavigatorKey.currentContext!)!.errorSynchronizationNoNetworkConnection,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
          duration: const Duration(seconds: 3),
        ));
        Navigator.pop(globalNavigatorKey.currentContext!);
        return;
      }
    }

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
