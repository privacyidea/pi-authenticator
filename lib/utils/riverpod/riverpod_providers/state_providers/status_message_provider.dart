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
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations_en.dart';

import '../../../logger.dart';

final statusMessageProvider = StateProvider<StatusMessage?>(
  (ref) {
    Logger.info("New statusMessageProvider created");
    return null;
  },
);

class StatusMessage {
  String Function(AppLocalizations localization) message;
  String Function(AppLocalizations localization)? details;
  bool isError;

  StatusMessage({
    required this.message,
    this.details,
    this.isError = true,
  });

  @override
  String toString() {
    return 'StatusMessage{message: ${message(AppLocalizationsEn())}, details: ${details?.call(AppLocalizationsEn())}}';
  }
}
