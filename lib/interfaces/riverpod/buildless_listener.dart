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

// ignore: invalid_use_of_internal_member
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../utils/logger.dart';

// ignore: invalid_use_of_internal_member
abstract class BuildlessListener<T extends BuildlessNotifier<S>, S> {
  final String listenerName;
  // ignore: invalid_use_of_internal_member
  final NotifierProviderImpl<T, S> provider;
  final void Function(S? previous, S next) onNewState;
  const BuildlessListener({required this.provider, required this.onNewState, required this.listenerName});
  void buildListen(WidgetRef ref) {
    Logger.debug('("$listenerName") listening to provider ("$provider")', name: 'StateNotifierProviderListener#buildListen');
    ref.listen(provider, (previous, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onNewState(previous, next));
    });
  }
}
