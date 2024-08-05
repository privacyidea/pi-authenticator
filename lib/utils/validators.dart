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
import '../l10n/app_localizations.dart';

class Validators {
  final AppLocalizations appLocalizations;
  const Validators(this.appLocalizations);

  String? password(String? value) {
    if (value == null || value.isEmpty) return appLocalizations.passwordCannotBeEmpty;
    if (value.length < 8) return appLocalizations.passwordMustBeAtLeast8Characters;
    if (value.contains(RegExp(r'\s'))) return appLocalizations.passwordCannotContainWhitespace;
    if (!value.contains(RegExp(r'[a-z]'))) return appLocalizations.passwordMustContainLowercaseLetter;
    if (!value.contains(RegExp(r'[A-Z]'))) return appLocalizations.passwordMustContainUppercaseLetter;
    if (!value.contains(RegExp(r'[0-9]'))) return appLocalizations.passwordMustContainNumber;
    if (!value.contains(RegExp(r"[!@#$%^&*()_+{}|:<>?`~\-=[\]\\;\',./]"))) return appLocalizations.passwordMustContainSpecialCharacter;
    return null;
  }

  String? confirmPassword(String? password, String? confirmPassword) {
    if (password != confirmPassword) return appLocalizations.passwordsDoNotMatch;
    return null;
  }
}
