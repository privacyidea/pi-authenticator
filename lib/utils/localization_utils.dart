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
    return Localizations.of<L10n>(context, L10n);
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
