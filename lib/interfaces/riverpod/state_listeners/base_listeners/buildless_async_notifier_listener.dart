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
// ignore_for_file: invalid_use_of_internal_member

import 'package:privacyidea_authenticator/views/view_interface.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../utils/logger.dart';

abstract class BuildlessAsyncNotifierListener<T extends BuildlessAsyncNotifier<S>, S> {
  final String listenerName;
  // ignore: invalid_use_of_visible_for_testing_member
  final AsyncNotifierProviderImpl<T, S>? provider;
  final void Function(AsyncValue<S>? previous, AsyncValue<S> next, WidgetRef ref)? onNewState;
  const BuildlessAsyncNotifierListener({this.provider, this.onNewState, required this.listenerName});
  void buildListen(WidgetRef ref) {
    Logger.debug('("$listenerName") listening to provider ("$provider")');
    if (provider == null || onNewState == null) return;
    ref.listen(provider!, (AsyncValue<S>? previous, AsyncValue<S> next) => onNewState!(previous, next, ref));
  }
}
