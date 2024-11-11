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
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../interfaces/riverpod/state_listeners/state_notifier_provider_listeners/deep_link_listener.dart';
import '../../../model/deeplink.dart';
import '../riverpod_providers/generated_providers/token_notifier.dart';

class TokenImportDeepLinkListener extends DeepLinkListener {
  const TokenImportDeepLinkListener({
    required super.deeplinkProvider,
  }) : super(
          onNewState: _onNewState,
          listenerName: 'TokenImportDeepLinkListener().processUri',
        );

  static void _onNewState(WidgetRef ref, AsyncValue<DeepLink>? previous, AsyncValue<DeepLink> next) {
    next.whenData((next) {
      ref.read(tokenProvider.notifier).handleLink(next.uri);
    });
  }
}
