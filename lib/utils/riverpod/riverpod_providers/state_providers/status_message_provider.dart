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
import 'dart:collection';

import 'package:flutter_riverpod/legacy.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';

final statusProvider = StateNotifierProvider<StatusNotifier, StatusState>(
  (ref) => StatusNotifier(),
);

class StatusMessage {
  final String Function(AppLocalizations localization) message;
  final String Function(AppLocalizations localization)? details;
  final bool isError;

  StatusMessage({required this.message, this.details, this.isError = true});
}

class StatusState {
  final StatusMessage? current;
  final Queue<StatusMessage> queue;
  StatusState({this.current, required this.queue});
}

class StatusNotifier extends StateNotifier<StatusState> {
  StatusNotifier() : super(StatusState(queue: Queue()));

  void show(
    String Function(AppLocalizations l) message, {
    String Function(AppLocalizations l)? details,
    bool isError = true,
  }) {
    final statusMessage = StatusMessage(
      message: message,
      details: details,
      isError: isError,
    );

    if (state.current == statusMessage || state.queue.contains(statusMessage)) {
      return;
    }

    state.queue.add(statusMessage);
    _tryNext();
  }

  void dismiss() {
    state = StatusState(queue: state.queue);
    _tryNext();
  }

  void _tryNext() {
    if (state.current == null && state.queue.isNotEmpty) {
      state = StatusState(
        current: state.queue.removeFirst(),
        queue: state.queue,
      );
    }
  }
}
