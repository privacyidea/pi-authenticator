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
      desc: 'The text of the button to calculate the next otp value.',
      locale: localeName,
    );
  }

  String get about {
    return Intl.message(
      'About',
      desc: 'Button to open the about page.',
      locale: localeName,
    );
  }

  String get settings {
    return Intl.message(
      'Settings',
      desc: 'Button to open the settings page.',
      locale: localeName,
    );
  }

  String get addManually {
    return Intl.message(
      'Add token',
      desc: 'The button to open the screen to add tokens by hand.',
      locale: localeName,
    );
  }

  String get scanQr {
    return Intl.message(
      'Scan QR-Code',
      desc: 'The button to scan otpauto qr-codes.',
      locale: localeName,
    );
  }

  String get addManuallyTitle {
    return Intl.message(
      'Enter details for token',
      desc: 'Title of the screen where tokens are created manually,'
          ' tells the user to enter all required values.',
      locale: localeName,
    );
  }

  String get nameHint {
    return Intl.message(
      'Name',
      desc: 'Describes the field where the tokens name should be entered.',
      locale: localeName,
    );
  }

  String get secretHint {
    return Intl.message(
      'Secret',
      desc: 'Describes the field where the tokens secret should be entered.',
      locale: localeName,
    );
  }

  String get encoding {
    return Intl.message(
      'Encoding',
      desc: 'Title of the dropdown button where the encoding is selected.',
      locale: localeName,
    );
  }

  String get algorithm {
    return Intl.message(
      'Algorithm',
      desc: 'Title of the dropdown button where the encoding is selected.',
      locale: localeName,
    );
  }

  String get digits {
    return Intl.message(
      'Digits',
      desc:
          'Title of the dropdown button where the number of digits for the opt value is selecte.',
      locale: localeName,
    );
  }

  String get type {
    return Intl.message(
      'Type',
      desc:
          'Title of the dropdown button where the type of the token is selected.',
      locale: localeName,
    );
  }

  String get period {
    return Intl.message(
      'Period',
      desc:
          'Title of the dropdown button where the period of the totp token is selected.',
      locale: localeName,
    );
  }

  String get addToken {
    return Intl.message(
      'Add token',
      desc:
          'Button to add the token for which the values where added in this screen.',
      locale: localeName,
    );
  }

  String get toolTipAddToken {
    return Intl.message(
      'Add tokens',
      desc:
          'Tooltip for the button that opens the selection for adding tokens.',
      locale: localeName,
    );
  }

  String get hintEmptyName {
    return Intl.message(
      'Please enter a name for this token.',
      desc: 'Hint telling the user to enter a name for a token.',
      locale: localeName,
    );
  }

  String get hintEmptySecret {
    return Intl.message(
      'Please enter a secret for this token.',
      desc: 'Hint telling the user to enter a secret for a token.',
      locale: localeName,
    );
  }

  String get hintInvalidSecret {
    return Intl.message(
      'The secret does not the fit current encoding',
      desc:
          'Hint telling the user that the secret deos not fit the selected encoding.',
      locale: localeName,
    );
  }

  String get rename {
    return Intl.message(
      'Rename',
      desc: 'Label that describes renaming the token.',
      locale: localeName,
    );
  }

  String get renameDialogTitle {
    return Intl.message(
      'Rename token',
      desc: 'Title of the dialog where a new name for a token can be entered.',
      locale: localeName,
    );
  }

  String get cancel {
    return Intl.message(
      'Cancel',
      desc: 'Button to cancel an action.',
      locale: localeName,
    );
  }

  String get delete {
    return Intl.message(
      'Delete',
      desc: 'Label that describes deleting the token.',
      locale: localeName,
    );
  }

  String get deleteDialogTitle {
    return Intl.message(
      'Confirm deletion',
      desc: 'Title of the dialog where a token can be deleted.',
      locale: localeName,
    );
  }

  String get areYouSure {
    return Intl.message(
      'Are you sure you want to delete',
      desc: 'Part of a question: Do you want to delete {x}?',
      locale: localeName,
    );
  }

  String get scanQRTooltip {
    return Intl.message(
      'Scan QR code',
      desc: 'Tooltip for button that starts scanning for qr code.',
      locale: localeName,
    );
  }

  String get twoStepDialogTitleGenerate {
    return Intl.message(
      'Generating phone part',
      desc:
          'Title of a dialog telling the user that the phone part gets generated right now.',
      locale: localeName,
    );
  }

  String get twoStepDialogTitlePhonePart {
    return Intl.message(
      'Phone part:',
      desc:
          'Title of a dialog telling the user that the phone was generated, and it is shown to the user.',
      locale: localeName,
    );
  }

  String get dismiss {
    return Intl.message(
      'Dismiss',
      desc: 'Text of a button that closes a dialog.',
      locale: localeName,
    );
  }

  String otpValueCopiedMessage(var otpValue) {
    return Intl.message(
      'Password "$otpValue" copied to clipboard.',
      name: 'otpValueCopiedMessage',
      args: [otpValue],
      examples: const {'otpValue': '055374'},
      desc: 'Tells the user that the otp value was copied to the clipboard.',
      locale: localeName,
    );
  }

  String get theme {
    return Intl.message(
      'Theme',
      desc: 'Title of the setting group where the theme can be selected.',
      locale: localeName,
    );
  }

  String get lightTheme {
    return Intl.message(
      'Light theme',
      desc: 'The light theme.',
      locale: localeName,
    );
  }

  String get darkTheme {
    return Intl.message(
      'Dark theme',
      desc: 'The dark theme.',
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
