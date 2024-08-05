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
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../globals.dart';
import '../../../logger.dart';
import '../state_notifier_providers/token_provider.dart';
import '../state_providers/status_message_provider.dart';

final connectivityProvider = StreamProvider<List<ConnectivityResult>>(
  (ref) {
    Logger.info("New connectivityProvider created", name: 'connectivityProvider');
    ref.read(tokenProvider.notifier).initState.then(
      (newState) {
        Connectivity().checkConnectivity().then((connectivity) {
          Logger.info("First connectivity check: $connectivity", name: 'connectivityProvider#initialCheck');
          final hasNoConnection = connectivity.contains(ConnectivityResult.none);
          if (hasNoConnection && newState.hasPushTokens && globalNavigatorKey.currentContext != null) {
            ref.read(statusMessageProvider.notifier).state = (AppLocalizations.of(globalNavigatorKey.currentContext!)!.noNetworkConnection, null);
          }
        });
      },
    );
    return Connectivity().onConnectivityChanged;
  },
);
