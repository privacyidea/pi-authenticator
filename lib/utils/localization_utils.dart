import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/messages_all.dart';

class L10n {
  String localeName;

  L10n(this.localeName);

  static Future<L10n> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      return L10n(localeName);
    });
  }

  static L10n of(BuildContext context) {
    // Widget tests will fail with called getter [getter] on null otherwise.
    //  This will use the default localization in that case.
    return Localizations.of<L10n>(context, L10n) ?? L10n('');
  }

  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: 'The text of the button to calculate the next otp value.',
      locale: localeName,
    );
  }

  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: 'Button to open the about page.',
      locale: localeName,
    );
  }

  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: 'Button to open the settings page.',
      locale: localeName,
    );
  }

  String get addManually {
    return Intl.message(
      'Add token manually',
      name: 'addManually',
      desc: 'The button to open the screen to add tokens by hand.',
      locale: localeName,
    );
  }

  String get scanQr {
    return Intl.message(
      'Scan QR-Code',
      name: 'scanQr',
      desc: 'The button to scan otpauto qr-codes.',
      locale: localeName,
    );
  }

  String get addManuallyTitle {
    return Intl.message(
      'Enter details for token',
      name: 'addManuallyTitle',
      desc: 'Title of the screen where tokens are created manually,'
          ' tells the user to enter all required values.',
      locale: localeName,
    );
  }

  String get nameHint {
    return Intl.message(
      'Name',
      name: 'nameHint',
      desc: 'Describes the field where the tokens name should be entered.',
      locale: localeName,
    );
  }

  String get secretHint {
    return Intl.message(
      'Secret',
      name: 'secretHint',
      desc: 'Describes the field where the tokens secret should be entered.',
      locale: localeName,
    );
  }

  String get encoding {
    return Intl.message(
      'Encoding',
      name: 'encoding',
      desc: 'Title of the dropdown button where the encoding is selected.',
      locale: localeName,
    );
  }

  String get algorithm {
    return Intl.message(
      'Algorithm',
      name: 'algorithm',
      desc: 'Title of the dropdown button where the encoding is selected.',
      locale: localeName,
    );
  }

  String get digits {
    return Intl.message(
      'Digits',
      name: 'digits',
      desc:
          'Title of the dropdown button where the number of digits for the opt value is selecte.',
      locale: localeName,
    );
  }

  String get type {
    return Intl.message(
      'Type',
      name: 'type',
      desc:
          'Title of the dropdown button where the type of the token is selected.',
      locale: localeName,
    );
  }

  String get period {
    return Intl.message(
      'Period',
      name: 'period',
      desc:
          'Title of the dropdown button where the period of the totp token is selected.',
      locale: localeName,
    );
  }

  String get addToken {
    return Intl.message(
      'Add token',
      name: 'addToken',
      desc:
          'Button to add the token for which the values where added in this screen.',
      locale: localeName,
    );
  }

  String get toolTipAddToken {
    return Intl.message(
      'Add tokens',
      name: 'toolTipAddToken',
      desc:
          'Tooltip for the button that opens the selection for adding tokens.',
      locale: localeName,
    );
  }

  String get hintEmptyName {
    return Intl.message(
      'Please enter a name for this token.',
      name: 'hintEmptyName',
      desc: 'Hint telling the user to enter a name for a token.',
      locale: localeName,
    );
  }

  String get hintEmptySecret {
    return Intl.message(
      'Please enter a secret for this token.',
      name: 'hintEmptySecret',
      desc: 'Hint telling the user to enter a secret for a token.',
      locale: localeName,
    );
  }

  String get hintInvalidSecret {
    return Intl.message(
      'The secret does not the fit current encoding',
      name: 'hintInvalidSecret',
      desc:
          'Hint telling the user that the secret deos not fit the selected encoding.',
      locale: localeName,
    );
  }
}

class MyLocalizationsDelegate extends LocalizationsDelegate<L10n> {
  const MyLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'de'].contains(locale.languageCode);
  }

  @override
  Future<L10n> load(Locale locale) {
    return L10n.load(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<L10n> old) {
    return false;
  }
}
