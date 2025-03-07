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

import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../l10n/app_localizations_en.dart';
import '../../../logger.dart';

part 'localization_notifier.g.dart';

@Riverpod(keepAlive: true)
class LocalizationNotifier extends _$LocalizationNotifier {
  @override
  AppLocalizations build() {
    Logger.info("New AppConstraints created");
    return AppLocalizationsEn();
  }

  void update(AppLocalizations localizations) {
    if (state == localizations) return;
    Logger.debug("AppLocalizations updated");
    state = localizations;
  }
}
