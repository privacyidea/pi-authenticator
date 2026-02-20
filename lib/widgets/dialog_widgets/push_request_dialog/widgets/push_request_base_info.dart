/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../model/push_request/push_request.dart';
import '../../../../model/tokens/push_token.dart';

class PushRequestBaseInfo extends StatelessWidget {
  final PushToken token;
  final PushRequest pushRequest;

  const PushRequestBaseInfo({
    required this.token,
    required this.pushRequest,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.requestInfo(token.label, token.issuer),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(pushRequest.question, textAlign: TextAlign.center),
      ],
    );
  }
}
