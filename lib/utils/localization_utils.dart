import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/messages_all.dart';

class Localization {
  String localeName;

  Localization(this.localeName);

  static Future<Localization> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    return initializeMessages(localeName).then((_) {
      return Localization(localeName);
    });
  }

  static Localization of(BuildContext context) {
    // Widget tests will fail with called getter [getter] on null otherwise.
    //  This will use the default localization in that case.
    return Localizations.of<Localization>(context, Localization) ??
        Localization('');
  }

  // ###########################################################################
  // WORDS (E.G. FOR BUTTONS)
  // ###########################################################################

  String get guide {
    return Intl.message(
      'Guide',
      desc: 'Button to open the guide screen.',
      locale: localeName,
    );
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

  String get retry {
    return Intl.message(
      "Retry",
      name: 'retry',
      desc: 'Label for e.g. a button. Something is tried to be done again.',
      locale: localeName,
    );
  }

  String get accept {
    return Intl.message(
      "Accept",
      name: 'accept',
      desc: 'Label for e.g. a button. Something gets accepted by the user.',
      locale: localeName,
    );
  }

  String get decline {
    return Intl.message(
      "Decline",
      name: 'decline',
      desc: 'Label for e.g. a button. Something gets declined by the user.',
      locale: localeName,
    );
  }

  String get name {
    return Intl.message(
      'Name',
      desc: 'Describes the field where the tokens name should be entered.',
      locale: localeName,
    );
  }

  String get secret {
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

  String get rename {
    return Intl.message(
      'Rename',
      desc: 'Label that describes renaming the token.',
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

  String get dismiss {
    return Intl.message(
      'Dismiss',
      desc: 'Text of a button that closes a dialog.',
      locale: localeName,
    );
  }

  // ###########################################################################
  // OTHERS
  // ###########################################################################

  String get showThisOnStart {
    return Intl.message(
      'Show this screen on start:',
      desc: 'Description for checkbox, if the checkbox is ticked, the guide '
          'screen is shown on every app start.',
      locale: localeName,
    );
  }

  String get somethingWentWrong {
    return Intl.message(
      'Something went wrong.',
      desc: 'Tells the user that something went wrong.',
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
      desc: 'The button to scan otpauth qr-codes.',
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

  String get addToken {
    return Intl.message(
      'Add token',
      desc:
          'Button to add the token for which the values where added in this screen.',
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
      'The secret does not fit the current encoding',
      desc:
          'Hint telling the user that the secret does not fit the selected encoding.',
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

  String get deleteDialogTitle {
    return Intl.message(
      'Confirm deletion',
      desc: 'Title of the dialog where a token can be deleted.',
      locale: localeName,
    );
  }

  String confirmDeletionOf(String name) {
    return Intl.message(
      'Are you sure you want to delete $name?',
      desc: 'Asks for confirmation on deleting a token.',
      args: [name],
      examples: const {'name': 'PUSH1234'},
      name: 'confirmDeletionOf',
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

  // ###########################################################################
  // SETTINGS
  // ###########################################################################

  String get settings {
    return Intl.message(
      'Settings',
      desc: 'Button to open the settings page.',
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

  String get pollingInfoTitle {
    return Intl.message(
      'Some of the tokens are outdated and do not support polling',
      desc: 'Tells the user, that the following tokens do not support polling.',
      locale: localeName,
    );
  }

  String get enablePolling {
    return Intl.message(
      'Enable polling',
      desc: 'Name of the setting switch that enables polling.',
      locale: localeName,
    );
  }

  String get misc {
    return Intl.message(
      'Miscellaneous',
      desc: 'Title for misc settings.',
      locale: localeName,
    );
  }

  String get pollingDescription {
    return Intl.message(
      'Request push challenges from the server'
      ' periodically. Enable this if push challenges are'
      ' not received normally.',
      desc: 'The description of the polling feature.',
      locale: localeName,
    );
  }

  // ###########################################################################
  //                                PUSH TOKENS:
  // ###########################################################################

  String errorOnlyOneFirebaseProjectIsSupported(var name) {
    return Intl.message(
      "The firebase configuration of $name differs from the one currently "
      "used by the app. Currently only one is supported.",
      name: 'errorOnlyOneFirebaseProjectIsSupported',
      args: [name],
      examples: const {'name': 'PUSH1234A'},
      desc: 'Tells the user that the token can not be used because'
          ' it has a different firebase configuration than the current'
          ' used configuration of the application.',
      locale: localeName,
    );
  }

  String errorTokenExpired(var name) {
    return Intl.message(
      "Token $name is expired, roll-out not possible.",
      name: 'errorTokenExpired',
      args: [name],
      examples: const {'name': 'PUSH1234A'},
      desc:
          'Tells the user that the token can not be rolled out, because it expired.',
      locale: localeName,
    );
  }

  String errorRollOutFailed(String name, var errorCode) {
    return Intl.message(
      "Rolling out token $name failed. Error code: $errorCode",
      name: "errorRollOutFailed",
      args: [name, errorCode],
      examples: const {'name': 'PUSH1234A', 'errorCode': "500"},
      desc:
          'Tells the user that the token could not be rolled out, because a network error occured.',
      locale: localeName,
    );
  }

  String get errorRollOutNoNetworkConnection {
    return Intl.message(
      "No network connection. Roll-out not possible.",
      name: 'errorRollOutNoNetworkConnection',
      desc: 'Tells the user that the roll-out failed because '
          'no network connection is available.',
      locale: localeName,
    );
  }

  String errorRollOutUnknownError(var e) {
    return Intl.message(
      "An unknown error occurred. Roll-out not possible: $e",
      name: 'errorRollOutUnknownError',
      args: [e],
      examples: const {'e': 'IllegalArgumentException on Line 5 ...'},
      desc:
          'Tells the user that the roll-out failed because of an unknown error.',
      locale: localeName,
    );
  }

  String acceptPushAuthRequestFor(String name) {
    return Intl.message(
      "Accepted authentication request for $name.",
      name: "acceptPushAuthRequestFor",
      args: [name],
      examples: const {'name': 'PUSH1234A'},
      desc:
          'Tells the user that a push request for a specific token was accepted.',
      locale: localeName,
    );
  }

  String decliningPushAuthRequestFor(String name) {
    return Intl.message(
      "Declined authentication request for $name.",
      name: "decliningPushAuthRequestFor",
      args: [name],
      examples: const {'name': 'PUSH1234A'},
      desc:
          'Tells the user that a push request for a specific token was declined.',
      locale: localeName,
    );
  }

  String errorPushAuthRequestFailedFor(String name, var errorCode) {
    return Intl.message(
      "Accepting authentication request for $name failed. "
      "Error code: $errorCode",
      name: "errorPushAuthRequestFailedFor",
      args: [name, errorCode],
      examples: const {'name': 'PUSH1234A', 'errorCode': "500"},
      desc:
          'Tells the user that a push auth request could not be accepted for a token.',
      locale: localeName,
    );
  }

  String get rollingOut {
    return Intl.message(
      "Rolling out",
      name: 'rollingOut',
      desc: 'Label that tells the user that the token is being rolled out.',
      locale: localeName,
    );
  }

  String get retryRollOut {
    return Intl.message(
      "Roll-out failed, please try again.",
      name: 'retryRollOut',
      desc:
          'Label for e.g. a button. Tells the user that rolling out the token '
          'failed. Roll out can be retried by clicking this button.',
      locale: localeName,
    );
  }

  String get errorAuthenticationNotPossibleWithoutNetworkAccess {
    return Intl.message(
      "No network connection. Authentication not possible.",
      name: 'errorAuthenticationNotPossibleWithoutNetworkAccess',
      desc: 'Error message tell the user that accepting a push request failed.',
      locale: localeName,
    );
  }

  String errorAuthenticationFailedUnknownError(var e) {
    return Intl.message(
      "An unknown error occurred. Authentication failed: $e",
      name: 'errorAuthenticationFailedUnknownError',
      args: [e],
      examples: const {'e': 'IllegalArgumentException on line 5, ...'},
      desc: "Tells the user that the authentication could not be accepted "
          "because of an unknown error.",
      locale: localeName,
    );
  }

  String get errorFirebaseConfigCorrupted {
    return Intl.message(
      "The firebase configuration is corrupted and cannot be used.",
      locale: localeName,
    );
  }

  String get pollNow {
    return Intl.message('Polling for new challenges', locale: localeName);
  }
}

class MyLocalizationsDelegate extends LocalizationsDelegate<Localization> {
  const MyLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'de'].contains(locale.languageCode);

  @override
  Future<Localization> load(Locale locale) => Localization.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => false;
}
