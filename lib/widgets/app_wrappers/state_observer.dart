/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../interfaces/riverpod/buildless_listener.dart';
import '../../interfaces/riverpod/state_listeners/base_listeners/buildless_async_notifier_listener.dart';
import '../../interfaces/riverpod/state_listeners/base_listeners/stream_notifier_listener.dart';
import '../../interfaces/riverpod/state_listeners/state_notifier_provider_listener.dart';

class StateObserver extends ConsumerWidget {
  final List<StateNotifierProviderListener> stateNotifierProviderListeners;
  final List<BuildlessListener> buildlessProviderListener;
  final List<BuildlessAsyncNotifierListener> asyncNotifierProviderListeners;
  final List<StreamNotifierListener> streamNotifierProviderListeners;
  final Widget child;

  const StateObserver({
    super.key,
    this.asyncNotifierProviderListeners = const [],
    this.buildlessProviderListener = const [],
    this.stateNotifierProviderListeners = const [],
    this.streamNotifierProviderListeners = const [],
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    for (final listener in stateNotifierProviderListeners) {
      listener.buildListen(ref);
    }
    for (final listener in buildlessProviderListener) {
      listener.buildListen(ref);
    }
    for (final listener in asyncNotifierProviderListeners) {
      listener.buildListen(ref);
    }
    for (final listener in streamNotifierProviderListeners) {
      listener.buildListen(ref);
    }
    return child;
  }
}
