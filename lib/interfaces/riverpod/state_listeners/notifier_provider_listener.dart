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
// ignore_for_file: invalid_use_of_internal_member

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../utils/logger.dart';

abstract class AsyncNotifierProviderListener<T extends BuildlessAutoDisposeAsyncNotifier<S>, S> {
  final AutoDisposeAsyncNotifierProviderImpl<T, S>? provider;
  final void Function(AsyncValue<S>? previous, AsyncValue<S> next)? onNewState;
  const AsyncNotifierProviderListener({this.provider, this.onNewState});
  void buildListen(WidgetRef ref) {
    Logger.debug('Listening to $provider', name: 'AsyncNotifierProviderListener#buildListen');
    if (provider == null || onNewState == null) return;
    ref.listen(provider!, onNewState!);
  }
}
