/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2025 NetKnights GmbH
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
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';

import '../../widgets/push_request_listener.dart';
import '../view_interface.dart';
import 'widgets/push_tokens_view_list.dart';

class PushTokensView extends StatelessView {
  @override
  RouteSettings get routeSettings => const RouteSettings(name: routeName);
  static const routeName = '/push_tokens';
  const PushTokensView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.pushTokensViewTitle,
            overflow: TextOverflow.ellipsis, // maxLines: 2 only works like this.
            maxLines: 2, // Title can be shown on small screens too.
          ),
        ),
        body: PushRequestListener(
          child: Stack(
            children: [
              Center(
                child: Icon(Icons.notifications_none, size: 300, color: Colors.grey.withValues(alpha: 0.2)),
              ),
              const PushTokensViwList(),
            ],
          ),
        ),
      ),
    );
  }
}
