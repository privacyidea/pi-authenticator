import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('nl'),
    Locale('pl')
  ];

  /// No description provided for @patchNotesNewFeatures.
  ///
  /// In en, this message translates to:
  /// **'New features'**
  String get patchNotesNewFeatures;

  /// No description provided for @patchNotesImprovements.
  ///
  /// In en, this message translates to:
  /// **'Improvements'**
  String get patchNotesImprovements;

  /// No description provided for @patchNotesBugFixes.
  ///
  /// In en, this message translates to:
  /// **'Bug fixes'**
  String get patchNotesBugFixes;

  /// No description provided for @patchNotesV4_4_0NewFeatures1.
  ///
  /// In en, this message translates to:
  /// **'It is now possible to export tokens where it can be ensured that they are not privacyIDEA tokens. Currently, it cannot be ruled out that tokens added via the QR code scanner originate from privacyIDEA. The differentiation will be improved in future versions.'**
  String get patchNotesV4_4_0NewFeatures1;

  /// No description provided for @patchNotesV4_4_0NewFeatures2.
  ///
  /// In en, this message translates to:
  /// **'Added support for privacyIDEA\'s \"require presence\"'**
  String get patchNotesV4_4_0NewFeatures2;

  /// No description provided for @patchNotesV4_4_0Improvement1.
  ///
  /// In en, this message translates to:
  /// **'Further import sources have been added.'**
  String get patchNotesV4_4_0Improvement1;

  /// No description provided for @patchNotesV4_4_0Improvement2.
  ///
  /// In en, this message translates to:
  /// **'Improved recognition of QR codes from image files.'**
  String get patchNotesV4_4_0Improvement2;

  /// No description provided for @patchNotesV4_3_1BugFix1.
  ///
  /// In en, this message translates to:
  /// **'Fixed an issue where the otp value was not displayed after authentication on some devices.'**
  String get patchNotesV4_3_1BugFix1;

  /// No description provided for @patchNotesV4_3_1Improvement1.
  ///
  /// In en, this message translates to:
  /// **'Improved the qr code scanner.'**
  String get patchNotesV4_3_1Improvement1;

  /// No description provided for @patchNotesV4_3_0NewFeatures1.
  ///
  /// In en, this message translates to:
  /// **'Support for importing tokens from Google, Aegis and 2FAS Authenticator has been added. More import sources will be added in the future.'**
  String get patchNotesV4_3_0NewFeatures1;

  /// No description provided for @patchNotesV4_3_0NewFeatures2.
  ///
  /// In en, this message translates to:
  /// **'Added feedback option to the settings.'**
  String get patchNotesV4_3_0NewFeatures2;

  /// No description provided for @patchNotesV4_3_0NewFeatures3.
  ///
  /// In en, this message translates to:
  /// **'Push tokens can now be hidden from the token list.'**
  String get patchNotesV4_3_0NewFeatures3;

  /// No description provided for @patchNotesV4_3_0NewFeatures4.
  ///
  /// In en, this message translates to:
  /// **'Introductions have been added to help new users get started.'**
  String get patchNotesV4_3_0NewFeatures4;

  /// No description provided for @patchNotesV4_3_0NewFeatures5.
  ///
  /// In en, this message translates to:
  /// **'You can now search for tokens by tapping the magnifying glass in the upper right corner.'**
  String get patchNotesV4_3_0NewFeatures5;

  /// No description provided for @patchNotesV4_3_0NewFeatures6.
  ///
  /// In en, this message translates to:
  /// **'Added HomeWidget token for Android 12 and later.'**
  String get patchNotesV4_3_0NewFeatures6;

  /// Label for e.g. a button. Something gets accepted by the user.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Label for e.g. a button. Something gets declined by the user.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// Describes the field where the tokens name should be entered.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Describes the field where the tokens secret should be entered.
  ///
  /// In en, this message translates to:
  /// **'Secret key'**
  String get secretKey;

  /// Title of the dropdown button where the encoding is selected.
  ///
  /// In en, this message translates to:
  /// **'Encoding'**
  String get encoding;

  /// Title of the dropdown button where the encoding is selected.
  ///
  /// In en, this message translates to:
  /// **'Algorithm'**
  String get algorithm;

  /// Title of the dropdown button where the number of digits for the opt value is selected.
  ///
  /// In en, this message translates to:
  /// **'Digits'**
  String get digits;

  /// Title of the dropdown button where the type of the token is selected.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Title of the dropdown button where the period of the totp token is selected.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// Label that describes renaming the token.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// Button to cancel an action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label that describes deleting the token.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Text of a button that closes a dialog.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// The button to open the screen to add tokens by hand.
  ///
  /// In en, this message translates to:
  /// **'Add token'**
  String get addToken;

  /// The button to scan otpauth qr-codes.
  ///
  /// In en, this message translates to:
  /// **'Scan QR-Code'**
  String get scanQrCode;

  /// Title of the screen where tokens are created manually, tells the user to enter all required values.
  ///
  /// In en, this message translates to:
  /// **'Enter details for token'**
  String get enterDetailsForToken;

  /// Hint telling the user to enter a name for a token.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name for this token.'**
  String get pleaseEnterANameForThisToken;

  /// Hint telling the user to enter a secret for a token.
  ///
  /// In en, this message translates to:
  /// **'Please enter a secret for this token.'**
  String get pleaseEnterASecretForThisToken;

  /// Hint telling the user that the secret does not fit the selected encoding.
  ///
  /// In en, this message translates to:
  /// **'The secret does not fit the current encoding'**
  String get theSecretDoesNotFitTheCurrentEncoding;

  /// Title of the dialog where a new name for a token can be entered.
  ///
  /// In en, this message translates to:
  /// **'Rename token'**
  String get renameToken;

  /// Title of the dialog where a token can be deleted.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDeletion;

  /// Asks for confirmation on deleting a token.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String confirmDeletionOf(Object name);

  /// Gives the user a hint about the consequences of deleting a token.
  ///
  /// In en, this message translates to:
  /// **'You may no longer be able to log in if you delete this token.\nPlease make sure that you can log in to the associated account without this token.'**
  String get confirmTokenDeletionHint;

  /// Gives the user a hint about the consequences of deleting a folder.
  ///
  /// In en, this message translates to:
  /// **'Deleting a folder has no effect on the tokens in it.\nThe tokens are moved to the main list.'**
  String get confirmFolderDeletionHint;

  /// Title of a dialog telling the user that the phone part gets generated right now.
  ///
  /// In en, this message translates to:
  /// **'Generating phone part'**
  String get generatingPhonePart;

  /// Title of a dialog telling the user that the phone was generated, and it is shown to the user.
  ///
  /// In en, this message translates to:
  /// **'Phone part:'**
  String get phonePart;

  /// Tells the user that the otp value was copied to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Password \"{otpValue}\" copied to clipboard.'**
  String otpValueCopiedMessage(Object otpValue);

  /// Button to open the settings page.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Title for the settings block concerning the push tokens.
  ///
  /// In en, this message translates to:
  /// **'Push Token'**
  String get pushToken;

  /// Title of the setting group where the theme can be selected.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// The light theme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// The dark theme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// The systems theme.
  ///
  /// In en, this message translates to:
  /// **'Use device\'s theme'**
  String get systemTheme;

  /// Tells the user, that the following tokens do not support polling.
  ///
  /// In en, this message translates to:
  /// **'Some of the tokens are outdated and do not support polling'**
  String get someTokensDoNotSupportPolling;

  /// Name of the setting switch that enables polling.
  ///
  /// In en, this message translates to:
  /// **'Enable polling'**
  String get enablePolling;

  /// The description of the polling feature.
  ///
  /// In en, this message translates to:
  /// **'Request push challenges from the server periodically. Enable this if push challenges are not received normally.'**
  String get requestPushChallengesPeriodically;

  /// Title of synchronizing push tokens in settings.
  ///
  /// In en, this message translates to:
  /// **'Synchronize push tokens'**
  String get synchronizePushTokens;

  /// Description of synchronizing push tokens in settings.
  ///
  /// In en, this message translates to:
  /// **'Synchronizes tokens with the privacyIDEA server.'**
  String get synchronizesTokensWithServer;

  /// Text of button that is used to synchronize push tokens.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// Title of the push synchronization dialog.
  ///
  /// In en, this message translates to:
  /// **'Synchronizing tokens.'**
  String get synchronizingTokens;

  /// Content of the push synchronization dialog. Signaling the user that everything worked.
  ///
  /// In en, this message translates to:
  /// **'All tokens are synchronized.'**
  String get allTokensSynchronized;

  /// Headline for the list of tokens where the synchronization failed.
  ///
  /// In en, this message translates to:
  /// **'Synchronization failed for the following tokens, please try again:'**
  String get synchronizationFailed;

  /// Informs the user that the following tokens cannot be synchronized as they do not support that.
  ///
  /// In en, this message translates to:
  /// **'The following tokens do not support synchronization and must be rolled out again:'**
  String get tokensDoNotSupportSynchronization;

  /// Tells the user that the token could not be rolled out, because a network error occurred.
  ///
  /// In en, this message translates to:
  /// **'Rolling out token {name} failed.'**
  String errorRollOutFailed(Object name);

  /// Tells the user the status code of the error.
  ///
  /// In en, this message translates to:
  /// **'Status code: {statusCode}'**
  String statusCode(Object statusCode);

  /// Tells the user that synchronizing the push tokens failed because the server could not be reached.
  ///
  /// In en, this message translates to:
  /// **'Synchronizing tokens failed, privacyIDEA server could not be reached.'**
  String get errorSynchronizationNoNetworkConnection;

  /// Tells the user that the roll-out failed because the server could not be reached.
  ///
  /// In en, this message translates to:
  /// **'Rolling out token {name} failed, the server could not be reached.'**
  String errorRollOutNoConnectionToServer(Object name);

  /// Tells the user that the roll-out failed because of an unknown error.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred. Roll-out not possible: {e}'**
  String errorRollOutUnknownError(Object e);

  /// Label that tells the user that the token is being rolled out.
  ///
  /// In en, this message translates to:
  /// **'Rolling out'**
  String get rollingOut;

  /// No description provided for @pollingChallenges.
  ///
  /// In en, this message translates to:
  /// **'Polling for new challenges'**
  String get pollingChallenges;

  /// Title of page report mode.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedError;

  /// Tells the user that the polling failed.
  ///
  /// In en, this message translates to:
  /// **'Polling failed.'**
  String get pollingFailed;

  /// Tells the user that the polling failed.
  ///
  /// In en, this message translates to:
  /// **'Polling failed for {serial}'**
  String pollingFailedFor(Object serial);

  /// Tells the user that there is no network connection.
  ///
  /// In en, this message translates to:
  /// **'No network connection.'**
  String get noNetworkConnection;

  /// Tells the user that the connection failed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed.'**
  String get connectionFailed;

  /// Tells the user to check the network connection.
  ///
  /// In en, this message translates to:
  /// **'Please check your network connection and try again.'**
  String get checkYourNetwork;

  /// Tells the user that the server could not be reached.
  ///
  /// In en, this message translates to:
  /// **'The server could not be reached.'**
  String get serverNotReachable;

  /// Tells the user that the message could not be signed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign message.'**
  String get couldNotSignMessage;

  /// Title of the switch tile where using the devices language can be enabled.
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get useDeviceLocaleTitle;

  /// Description of the switch tile where using the devices language can be enabled.
  ///
  /// In en, this message translates to:
  /// **'Use device language if it is supported, otherwise default to english.'**
  String get useDeviceLocaleDescription;

  /// Title of language setting group.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Reason to authenticate when trying to view a one time password.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to show one time password.'**
  String get authenticateToShowOtp;

  /// Reason to authenticate when trying to lock or unlock a token.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to change the lock status of the token.'**
  String get authenticateToUnLockToken;

  /// Message showed as a title in a dialog which indicates the user has not set up biometric authentication on their device. It is used on Android side. Maximum 60 characters.
  ///
  /// In en, this message translates to:
  /// **'Biometrics not setup'**
  String get biometricRequiredTitle;

  /// Hint message advising the user how to authenticate with biometrics. It is used on Android side. Maximum 60 characters.
  ///
  /// In en, this message translates to:
  /// **'Authentication required'**
  String get biometricHint;

  /// Message to let the user know that authentication was failed. It is used on Android side. Maximum 60 characters.
  ///
  /// In en, this message translates to:
  /// **'Not recognized. Try again.'**
  String get biometricNotRecognized;

  /// Message to let the user know that authentication was successful. It is used on Android side. Maximum 60 characters.
  ///
  /// In en, this message translates to:
  /// **'Authentication successful'**
  String get biometricSuccess;

  /// Message showed as a title in a dialog which indicates the user has not set up credentials authentication on their device. It is used on Android side. Maximum 60 characters.
  ///
  /// In en, this message translates to:
  /// **'Device credentials not set up'**
  String get deviceCredentialsRequiredTitle;

  /// Message advising the user to go to the settings and configure device credentials on their device. It shows in a dialog on Android side.
  ///
  /// In en, this message translates to:
  /// **'Setup device credentials in the device\'s settings'**
  String get deviceCredentialsSetupDescription;

  /// Message showed as a title in a dialog which indicates the user that they need to scan biometric to continue. It is used on Android side. Maximum 60 characters.
  ///
  /// In en, this message translates to:
  /// **'Authentication required'**
  String get signInTitle;

  /// Message showed on a button that the user can click to go to settings pages from the current dialog. It is used on both Android and iOS side. Maximum 30 characters.
  ///
  /// In en, this message translates to:
  /// **'Go to settings'**
  String get goToSettingsButton;

  /// Message advising the user to go to the settings and configure device credentials or biometrics on their device.
  ///
  /// In en, this message translates to:
  /// **'Authentication by credentials or biometrics is not set up on your device. Please set it up in the device\'s settings.'**
  String get goToSettingsDescription;

  /// Message advising the user to re-enable biometrics on their device. It shows in a dialog on iOS side.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is disabled. Please lock and unlock your screen to enable it.'**
  String get lockOut;

  /// Message shown as a dialog title that tells the user that device credentials or biometrics must be setup for this action.
  ///
  /// In en, this message translates to:
  /// **'Device credentials or biometrics required'**
  String get authNotSupportedTitle;

  /// Message shown as a dialog body that tells the user that device credentials or biometrics must be setup for this action.
  ///
  /// In en, this message translates to:
  /// **'This action requires the device to be secured by credentials or biometrics.'**
  String get authNotSupportedBody;

  /// Description of button that locks a token.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get lock;

  /// Description of button that unlocks a token.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No tokens stored yet.
  ///
  /// In en, this message translates to:
  /// **'No tokens stored yet.'**
  String get noResultTitle;

  /// first no result text
  ///
  /// In en, this message translates to:
  /// **'Tap the '**
  String get noResultText1;

  /// second no result text
  ///
  /// In en, this message translates to:
  /// **' button to get started!'**
  String get noResultText2;

  /// No description provided for @onBoardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'{appName}'**
  String onBoardingTitle1(Object appName);

  /// No description provided for @onBoardingText1.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication\nmade easy'**
  String get onBoardingText1;

  /// No description provided for @onBoardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Maximum Security'**
  String get onBoardingTitle2;

  /// No description provided for @onBoardingText2.
  ///
  /// In en, this message translates to:
  /// **'Store tokens on your device securely\nProtected by your biometrics'**
  String get onBoardingText2;

  /// No description provided for @onBoardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Visit us at Github'**
  String get onBoardingTitle3;

  /// No description provided for @onBoardingText3.
  ///
  /// In en, this message translates to:
  /// **'This app is open source'**
  String get onBoardingText3;

  /// No description provided for @errorLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Error log'**
  String get errorLogTitle;

  /// No description provided for @logMenu.
  ///
  /// In en, this message translates to:
  /// **'Log menu'**
  String get logMenu;

  /// No description provided for @showErrorLog.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get showErrorLog;

  /// No description provided for @clearErrorLog.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearErrorLog;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Explanation for the user what he will send.
  ///
  /// In en, this message translates to:
  /// **'A predefined email is created.\nIt contains information about the app, the error and the device.\nYou can edit the email before sending it.\nYou can see here how we use the information:'**
  String get sendErrorLogDescription;

  /// No description provided for @showPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Show privacy policy'**
  String get showPrivacyPolicy;

  /// No description provided for @errorLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'The error log is empty.'**
  String get errorLogEmpty;

  /// No description provided for @verboseLogging.
  ///
  /// In en, this message translates to:
  /// **'Verbose logging'**
  String get verboseLogging;

  /// No description provided for @errorLogCleared.
  ///
  /// In en, this message translates to:
  /// **'Error log cleared.'**
  String get errorLogCleared;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// Message for email body
  ///
  /// In en, this message translates to:
  /// **'The error log file is attached.\nYou can replace this text with additional information about the error.'**
  String get errorMailBody;

  /// No description provided for @showDetails.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get showDetails;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// Description shown to the user about what info the error report contains.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred in the application. The information below can be send to the developers by email to help prevent this error in the future.'**
  String get sendErrorDialogBody;

  /// No description provided for @noFbToken.
  ///
  /// In en, this message translates to:
  /// **'No Firebase token available'**
  String get noFbToken;

  /// No description provided for @firebaseToken.
  ///
  /// In en, this message translates to:
  /// **'Firebase Token'**
  String get firebaseToken;

  /// No description provided for @noPublicKey.
  ///
  /// In en, this message translates to:
  /// **'No public key available'**
  String get noPublicKey;

  /// No description provided for @publicKey.
  ///
  /// In en, this message translates to:
  /// **'Public Key'**
  String get publicKey;

  /// No description provided for @editToken.
  ///
  /// In en, this message translates to:
  /// **'Edit Token'**
  String get editToken;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @validFor.
  ///
  /// In en, this message translates to:
  /// **'Valid for'**
  String get validFor;

  /// No description provided for @validUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get validUntil;

  /// No description provided for @deleteLockedToken.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to delete the locked token.'**
  String get deleteLockedToken;

  /// No description provided for @editLockedToken.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to edit the locked token.'**
  String get editLockedToken;

  /// No description provided for @expandLockedFolder.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to uncollapse the locked folder.'**
  String get expandLockedFolder;

  /// Title of the dialog where a new name for a token folder can be entered.
  ///
  /// In en, this message translates to:
  /// **'Rename folder'**
  String get renameTokenFolder;

  /// No description provided for @addANewFolder.
  ///
  /// In en, this message translates to:
  /// **'Create new folder'**
  String get addANewFolder;

  /// No description provided for @folderName.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderName;

  /// No description provided for @retryRollout.
  ///
  /// In en, this message translates to:
  /// **'Retry rollout'**
  String get retryRollout;

  /// Message for the rollout process
  ///
  /// In en, this message translates to:
  /// **'Generating RSA key pair'**
  String get generatingRSAKeyPair;

  /// Message for the rollout process
  ///
  /// In en, this message translates to:
  /// **'Generating RSA key pair failed'**
  String get generatingRSAKeyPairFailed;

  /// Message for the rollout process
  ///
  /// In en, this message translates to:
  /// **'Sending public RSA key'**
  String get sendingRSAPublicKey;

  /// Message for the rollout process
  ///
  /// In en, this message translates to:
  /// **'Sending public RSA key failed'**
  String get sendingRSAPublicKeyFailed;

  /// Message for the rollout process
  ///
  /// In en, this message translates to:
  /// **'Parsing response'**
  String get parsingResponse;

  /// Message for the rollout process
  ///
  /// In en, this message translates to:
  /// **'Parsing response failed'**
  String get parsingResponseFailed;

  /// Message for the rollout process
  ///
  /// In en, this message translates to:
  /// **'Rollout completed'**
  String get rolloutCompleted;

  /// No description provided for @authToAcceptPushRequest.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to accept the push request.'**
  String get authToAcceptPushRequest;

  /// No description provided for @authToDeclinePushRequest.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to decline the push request.'**
  String get authToDeclinePushRequest;

  /// No description provided for @pushRequestParseError.
  ///
  /// In en, this message translates to:
  /// **'Push request could not be parsed.'**
  String get pushRequestParseError;

  /// No description provided for @imageUrl.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrl;

  /// Tells the user that the roll-out failed because the SSL handshake failed.
  ///
  /// In en, this message translates to:
  /// **'SSL handshake failed. Roll-out not possible.'**
  String get errorRollOutSSLHandshakeFailed;

  /// errorWhenPullingChallenges
  ///
  /// In en, this message translates to:
  /// **'An error occured when polling for challenges of {name}'**
  String errorWhenPullingChallenges(Object name);

  /// No description provided for @couldNotConnectToServer.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to server'**
  String get couldNotConnectToServer;

  /// No description provided for @errorRollOutNotPossibleAnymore.
  ///
  /// In en, this message translates to:
  /// **'Rolling out this Token is not possible anymore.'**
  String get errorRollOutNotPossibleAnymore;

  /// No description provided for @errorTokenExpired.
  ///
  /// In en, this message translates to:
  /// **'The token {name} has expired.'**
  String errorTokenExpired(Object name);

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @butDiscardIt.
  ///
  /// In en, this message translates to:
  /// **'but discard it'**
  String get butDiscardIt;

  /// No description provided for @declineIt.
  ///
  /// In en, this message translates to:
  /// **'decline it'**
  String get declineIt;

  /// No description provided for @requestTriggerdByUserQuestion.
  ///
  /// In en, this message translates to:
  /// **'Was this request triggered by you?'**
  String get requestTriggerdByUserQuestion;

  /// No description provided for @grantCameraPermissionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is not granted'**
  String get grantCameraPermissionDialogTitle;

  /// No description provided for @grantCameraPermissionDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Please grant camera permission to scan QR codes.'**
  String get grantCameraPermissionDialogContent;

  /// No description provided for @grantCameraPermissionDialogPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is permanently denied. Please grant camera permission in your Phone\'s settings.'**
  String get grantCameraPermissionDialogPermanentlyDenied;

  /// No description provided for @grantCameraPermissionDialogButton.
  ///
  /// In en, this message translates to:
  /// **'Grant permission'**
  String get grantCameraPermissionDialogButton;

  /// No description provided for @decryptErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Decryption error'**
  String get decryptErrorTitle;

  /// No description provided for @decryptErrorContent.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, the app was unable to decrypt your tokens. This indicates that the encryption key is broken. You can try again or delete the app data, which would delete the tokens in the app.'**
  String get decryptErrorContent;

  /// No description provided for @decryptErrorButtonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get decryptErrorButtonDelete;

  /// No description provided for @decryptErrorButtonSendError.
  ///
  /// In en, this message translates to:
  /// **'Send error'**
  String get decryptErrorButtonSendError;

  /// No description provided for @decryptErrorButtonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get decryptErrorButtonRetry;

  /// No description provided for @decryptErrorDeleteConfirmationContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the app data?'**
  String get decryptErrorDeleteConfirmationContent;

  /// No description provided for @hidePushTokens.
  ///
  /// In en, this message translates to:
  /// **'Hide push tokens'**
  String get hidePushTokens;

  /// No description provided for @hidePushTokensDescription.
  ///
  /// In en, this message translates to:
  /// **'Hide push tokens from the token list. This will not delete the tokens and they will still be visible on a separate screen.'**
  String get hidePushTokensDescription;

  /// No description provided for @settingsGroupGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGroupGeneral;

  /// No description provided for @licensesAndVersion.
  ///
  /// In en, this message translates to:
  /// **'Licenses and version'**
  String get licensesAndVersion;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @introScanQrCode.
  ///
  /// In en, this message translates to:
  /// **'You can scan QR codes to add tokens.\nWe support every common Two-Factor-Authentication token and also the privacyIDEA tokens.'**
  String get introScanQrCode;

  /// No description provided for @introAddTokenManually.
  ///
  /// In en, this message translates to:
  /// **'If you don\'t want to scan a QR code, you can also add tokens manually.'**
  String get introAddTokenManually;

  /// No description provided for @introTokenSwipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe tokens to the left to see available actions.'**
  String get introTokenSwipe;

  /// No description provided for @introEditToken.
  ///
  /// In en, this message translates to:
  /// **'Here you can edit the token name and see some details.'**
  String get introEditToken;

  /// No description provided for @introLockToken.
  ///
  /// In en, this message translates to:
  /// **'To improve security even more, you can lock tokens.\nThen the token can only be used after authentication.'**
  String get introLockToken;

  /// No description provided for @introDragToken.
  ///
  /// In en, this message translates to:
  /// **'Reorganize your tokens by pressing it for a few seconds and then dragging it to the desired position.'**
  String get introDragToken;

  /// No description provided for @introAddFolder.
  ///
  /// In en, this message translates to:
  /// **'You can create folders\nto organize your tokens.'**
  String get introAddFolder;

  /// No description provided for @introPollForChallenges.
  ///
  /// In en, this message translates to:
  /// **'You can check for new challenges by dragging down the token list.'**
  String get introPollForChallenges;

  /// No description provided for @introHidePushTokens.
  ///
  /// In en, this message translates to:
  /// **'Your push tokens are hidden now.\nBut you can still see them on the push token screen.'**
  String get introHidePushTokens;

  /// Title of the error dialog that is shown when an error occurs while using a legacy token.
  ///
  /// In en, this message translates to:
  /// **'An error occured while using the legacy token: {tokenLabel}'**
  String legacySigningErrorTitle(Object tokenLabel);

  /// Message of the error dialog that is shown when an error occurs while using a legacy token.
  ///
  /// In en, this message translates to:
  /// **'The token was enrolled in a old version of this app, which may cause trouble using it.\nIt is suggested to enroll a new push token if the problem persist!'**
  String get legacySigningErrorMessage;

  /// No description provided for @selectImportSource.
  ///
  /// In en, this message translates to:
  /// **'Select import source'**
  String get selectImportSource;

  /// No description provided for @selectImportType.
  ///
  /// In en, this message translates to:
  /// **'How do you want to import the tokens?'**
  String get selectImportType;

  /// No description provided for @importTokens.
  ///
  /// In en, this message translates to:
  /// **'Import token'**
  String get importTokens;

  /// No description provided for @importNTokens.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{Import no tokens} one{Import one token} other{Import {count} tokens}}'**
  String importNTokens(num count);

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select file'**
  String get selectFile;

  /// No description provided for @decrypt.
  ///
  /// In en, this message translates to:
  /// **'Decrypt'**
  String get decrypt;

  /// No description provided for @tokensAreEncrypted.
  ///
  /// In en, this message translates to:
  /// **'The tokens are encrypted. Please enter the password to decrypt them.'**
  String get tokensAreEncrypted;

  /// No description provided for @tokensNotEncrypted.
  ///
  /// In en, this message translates to:
  /// **'The tokens are not encrypted and can be imported directly.'**
  String get tokensNotEncrypted;

  /// No description provided for @tokensSuccessfullyDecrypted.
  ///
  /// In en, this message translates to:
  /// **'The tokens have been successfully decrypted and can now be imported.'**
  String get tokensSuccessfullyDecrypted;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get wrongPassword;

  /// No description provided for @qrScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get qrScan;

  /// No description provided for @enterLink.
  ///
  /// In en, this message translates to:
  /// **'Enter link'**
  String get enterLink;

  /// No description provided for @invalidBackupFile.
  ///
  /// In en, this message translates to:
  /// **'The selected file is not a valid backup of {appName}.'**
  String invalidBackupFile(Object appName);

  /// No description provided for @invalidQrScan.
  ///
  /// In en, this message translates to:
  /// **'The scanned QR code is not a valid backup of {appName}.'**
  String invalidQrScan(Object appName);

  /// No description provided for @invalidQrFile.
  ///
  /// In en, this message translates to:
  /// **'The selected file does not contain a valid QR code from {appName}.'**
  String invalidQrFile(Object appName);

  /// No description provided for @invalidLink.
  ///
  /// In en, this message translates to:
  /// **'The link entered is not a valid token of {appName}, or it is not supported.'**
  String invalidLink(Object appName);

  /// No description provided for @importFailedToken.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{No token Failed to import.} one{Failed to import a token.} other{Failed to import {count} tokens.}}'**
  String importFailedToken(num count);

  /// No description provided for @importExistingToken.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{No token was found that is already in the application.} one{A token was found that already exists in the application.} other{{count} tokens was found that are already in the application.}}'**
  String importExistingToken(num count);

  /// No description provided for @importConflictToken.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{There is no conflict with existing tokens.} one{There is a conflict with existing tokens.\nPlease select which one you would like to keep.} other{There are conflicts with existing tokens.\nPlease select the tokens you wish to keep.}}'**
  String importConflictToken(num count);

  /// No description provided for @importNewToken.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{No new token was found.} one{A new token was found that can be imported.} other{{count} new tokens were found that can be imported.}}'**
  String importNewToken(num count);

  /// No description provided for @importHintPrivacyIdeaQrScan.
  ///
  /// In en, this message translates to:
  /// **'Um QR-Codes der Token zu erstellen, navigieren Sie zu den Einstellungen und tippen auf \"Exportieren\". Wählen Sie dann \"Als QR-Code\" und tippen Sie auf den zu exportierenden Token. Diese Variante ist nur für die direkte Übertragung auf ein anderes Gerät geeignet, da der QR-Code nicht verschlüsselt ist.'**
  String get importHintPrivacyIdeaQrScan;

  /// No description provided for @importHintPrivacyIdeaFile.
  ///
  /// In en, this message translates to:
  /// **'To create a backup, go to the settings and tap on \"Export\". Select \"As file\", select the tokens you want to export. Then tap on \"Export\" and set a password. The storage location is the download folder on your device.'**
  String get importHintPrivacyIdeaFile;

  /// No description provided for @importHint2FAS.
  ///
  /// In en, this message translates to:
  /// **'Select your 2FAS backup.\nIf you do not have a backup, create one in the 2FAS app. We recommend using a password.'**
  String get importHint2FAS;

  /// No description provided for @importHintAegisBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Select your Aegis export (.JSON).\nIf you do not have an export, please create one via the settings menu in the Aegis app. The use of a password is recommended.'**
  String get importHintAegisBackupFile;

  /// No description provided for @importHintAegisQrScan.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code you receive when you transfer entries from Aegis.'**
  String get importHintAegisQrScan;

  /// No description provided for @importHintAegisLink.
  ///
  /// In en, this message translates to:
  /// **'Enter the link you receive when you transfer entries from Aegis.'**
  String get importHintAegisLink;

  /// No description provided for @importHintGoogleQrScan.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code you receive when you export your accounts from Google Authenticator.'**
  String get importHintGoogleQrScan;

  /// No description provided for @importHintGoogleQrFile.
  ///
  /// In en, this message translates to:
  /// **'Select an image file with the QR code you receive when you export your accounts from Google Authenticator.\n!! Note that it is not safe to save the QR code on your device as the tokens are not encrypted !!'**
  String get importHintGoogleQrFile;

  /// No description provided for @importHintAuthenticatorProFile.
  ///
  /// In en, this message translates to:
  /// **'To create a backup of the Authenticator Pro app, navigate to the settings and tap on \"Auto backup\". Select a storage location and set a password. Then press \"Back up now\" to export the tokens.'**
  String get importHintAuthenticatorProFile;

  /// No description provided for @importHintFreeOtpPlusQrScan.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code you receive when you press the three dots in the tile of the token and select \"Share QR code\".'**
  String get importHintFreeOtpPlusQrScan;

  /// No description provided for @importHintFreeOtpPlusFile.
  ///
  /// In en, this message translates to:
  /// **'To create a backup of the FreeOTP+ app, tap on the three dots in the upper right corner and select \"Export\". You can choose between JSON and URI format. We recommend to delete the backup after importing it, because it is not encrypted.'**
  String get importHintFreeOtpPlusFile;

  /// No description provided for @qrFileDecodeError.
  ///
  /// In en, this message translates to:
  /// **'It was not possible to decode the QR code from the selected image, please use the QR code scanner instead.'**
  String get qrFileDecodeError;

  /// No description provided for @tokenLink.
  ///
  /// In en, this message translates to:
  /// **'Token link'**
  String get tokenLink;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @feedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Your feedback is always welcome!'**
  String get feedbackTitle;

  /// No description provided for @feedbackDescription.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions, suggestions or problems, please let us know.'**
  String get feedbackDescription;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'A ready-made e-mail will open, which you can send to us. If desired, information about your device and the version of the application will be added. You can check and edit the email before sending it.'**
  String get feedbackHint;

  /// No description provided for @feedbackPrivacyPolicy1.
  ///
  /// In en, this message translates to:
  /// **'By sending the feedback you agree to our '**
  String get feedbackPrivacyPolicy1;

  /// Taping on this should open the privacy policy.
  ///
  /// In en, this message translates to:
  /// **'privacy policy'**
  String get feedbackPrivacyPolicy2;

  /// No description provided for @feedbackPrivacyPolicy3.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get feedbackPrivacyPolicy3;

  /// No description provided for @addSystemInfo.
  ///
  /// In en, this message translates to:
  /// **'Add system information'**
  String get addSystemInfo;

  /// No description provided for @feedbackSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback sent'**
  String get feedbackSentTitle;

  /// No description provided for @feedbackSentDescription.
  ///
  /// In en, this message translates to:
  /// **'Thank you very much for your help in making this application better!'**
  String get feedbackSentDescription;

  /// No description provided for @patchNotesDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s new?'**
  String get patchNotesDialogTitle;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @noMailAppTitle.
  ///
  /// In en, this message translates to:
  /// **'No mail app found'**
  String get noMailAppTitle;

  /// No description provided for @noMailAppDescription.
  ///
  /// In en, this message translates to:
  /// **'There is no e-mail app installed or initialised on this device, please try again when you are able to send an email message.'**
  String get noMailAppDescription;

  /// No description provided for @authentication.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get authentication;

  /// Description of the authentication request.
  ///
  /// In en, this message translates to:
  /// **'Sent by {issuer} for your account: \"{account}\"'**
  String requestInfo(Object issuer, Object account);

  /// Error message when unlinking a push token failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to unlink the push token {label}.'**
  String errorUnlinkingPushToken(Object label);

  /// No description provided for @pleaseSyncManuallyWhenNetworkIsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Please synchronize the push tokens manually via the settings when a network connection is available.'**
  String get pleaseSyncManuallyWhenNetworkIsAvailable;

  /// No description provided for @pushTokens.
  ///
  /// In en, this message translates to:
  /// **'Push Tokens'**
  String get pushTokens;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @addTokenManually.
  ///
  /// In en, this message translates to:
  /// **'Add token manually'**
  String get addTokenManually;

  /// No description provided for @addFolder.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get addFolder;

  /// No description provided for @searchTokens.
  ///
  /// In en, this message translates to:
  /// **'Search tokens'**
  String get searchTokens;

  /// No description provided for @closeSearchTokens.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get closeSearchTokens;

  /// No description provided for @increaseCounter.
  ///
  /// In en, this message translates to:
  /// **'Increase counter'**
  String get increaseCounter;

  /// No description provided for @copyOTPToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy OTP to clipboard'**
  String get copyOTPToClipboard;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @optionalMessage.
  ///
  /// In en, this message translates to:
  /// **'Optional message'**
  String get optionalMessage;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @askLogSendedDescription.
  ///
  /// In en, this message translates to:
  /// **'Did you send the log, and do you want to clear it now?'**
  String get askLogSendedDescription;

  /// No description provided for @algorithmUnsupported.
  ///
  /// In en, this message translates to:
  /// **'The algorithm {algorithm} is not supported'**
  String algorithmUnsupported(Object algorithm);

  /// No description provided for @thisAppIsOpenSource.
  ///
  /// In en, this message translates to:
  /// **'This Application is Open Source\nVisit us on GitHub'**
  String get thisAppIsOpenSource;

  /// No description provided for @importExportTokens.
  ///
  /// In en, this message translates to:
  /// **'Import/Export tokens'**
  String get importExportTokens;

  /// No description provided for @exportNonPrivacyIDEATokens.
  ///
  /// In en, this message translates to:
  /// **'Export non-privacyIDEA tokens'**
  String get exportNonPrivacyIDEATokens;

  /// No description provided for @selectTokensToExport.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{} one{Select token to export} other{Select tokens to export}}'**
  String selectTokensToExport(num count);

  /// No description provided for @noTokenToExport.
  ///
  /// In en, this message translates to:
  /// **'No token available for export'**
  String get noTokenToExport;

  /// No description provided for @exportAllTokens.
  ///
  /// In en, this message translates to:
  /// **'Export all tokens'**
  String get exportAllTokens;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @exportingTokens.
  ///
  /// In en, this message translates to:
  /// **'Exporting tokens...'**
  String get exportingTokens;

  /// No description provided for @exportTokens.
  ///
  /// In en, this message translates to:
  /// **'Export tokens'**
  String get exportTokens;

  /// No description provided for @enterPasswordToEncrypt.
  ///
  /// In en, this message translates to:
  /// **'Enter a password to encrypt the tokens. This password will be required to import the tokens.'**
  String get enterPasswordToEncrypt;

  /// No description provided for @exportLockedTokenReason.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to export locked tokens.'**
  String get exportLockedTokenReason;

  /// No description provided for @fileSavedToDownloadsFolder.
  ///
  /// In en, this message translates to:
  /// **'File saved to Downloads folder'**
  String get fileSavedToDownloadsFolder;

  /// No description provided for @errorSavingFile.
  ///
  /// In en, this message translates to:
  /// **'Saving to file failed'**
  String get errorSavingFile;

  /// No description provided for @asQrCode.
  ///
  /// In en, this message translates to:
  /// **'As QR code'**
  String get asQrCode;

  /// No description provided for @asFile.
  ///
  /// In en, this message translates to:
  /// **'As file'**
  String get asFile;

  /// No description provided for @scanThisQrWithNewDevice.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code with your new device to import the token.'**
  String get scanThisQrWithNewDevice;

  /// No description provided for @oneMore.
  ///
  /// In en, this message translates to:
  /// **'One more'**
  String get oneMore;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @secretIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Secret is required'**
  String get secretIsRequired;

  /// No description provided for @tokenDataParseError.
  ///
  /// In en, this message translates to:
  /// **'Token data could not be parsed'**
  String get tokenDataParseError;

  /// No description provided for @missingRequiredParameter.
  ///
  /// In en, this message translates to:
  /// **'Value for parameter [{counter}] is required and is missing'**
  String missingRequiredParameter(Object counter);

  /// No description provided for @invalidValueForParameter.
  ///
  /// In en, this message translates to:
  /// **'\"{value}\" is not a valid value for the parameter \"{parameter}\".'**
  String invalidValueForParameter(Object value, Object parameter);

  /// No description provided for @unsupported.
  ///
  /// In en, this message translates to:
  /// **'The {name} [{value}] is not supported by this version of the app.'**
  String unsupported(Object name, Object value);

  /// No description provided for @pushEndpointUrl.
  ///
  /// In en, this message translates to:
  /// **'Push endpoint URL'**
  String get pushEndpointUrl;

  /// No description provided for @exampleUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL like: \"https://example.com/\"'**
  String get exampleUrl;

  /// No description provided for @mustNotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'{field} must not be empty'**
  String mustNotBeEmpty(Object field);

  /// Error message when the response to a push request could not be sent.
  ///
  /// In en, this message translates to:
  /// **'Failed to send the response.'**
  String get sendPushRequestResponseFailed;

  /// No description provided for @passwordCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get passwordCannotBeEmpty;

  /// No description provided for @passwordMustBeAtLeast8Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMustBeAtLeast8Characters;

  /// No description provided for @passwordCannotContainWhitespace.
  ///
  /// In en, this message translates to:
  /// **'Password cannot contain whitespace'**
  String get passwordCannotContainWhitespace;

  /// No description provided for @passwordMustContainLowercaseLetter.
  ///
  /// In en, this message translates to:
  /// **'Password must contain lowercase letter'**
  String get passwordMustContainLowercaseLetter;

  /// No description provided for @passwordMustContainUppercaseLetter.
  ///
  /// In en, this message translates to:
  /// **'Password must contain uppercase letter'**
  String get passwordMustContainUppercaseLetter;

  /// No description provided for @passwordMustContainNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must contain number'**
  String get passwordMustContainNumber;

  /// No description provided for @passwordMustContainSpecialCharacter.
  ///
  /// In en, this message translates to:
  /// **'Password must contain special character'**
  String get passwordMustContainSpecialCharacter;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @selectTokensToExportHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Is your token not listed?'**
  String get selectTokensToExportHelpTitle;

  /// No description provided for @selectTokensToExportHelpContent.
  ///
  /// In en, this message translates to:
  /// **'If a token is not listed, it is not guaranteed that it is not a privacyIDEA token.\nCurrently only manually added and imported tokens are exportable.'**
  String get selectTokensToExportHelpContent;

  /// No description provided for @findingQrCodeInImage.
  ///
  /// In en, this message translates to:
  /// **'Looking for QR code in image...'**
  String get findingQrCodeInImage;

  /// No description provided for @qrNotFound.
  ///
  /// In en, this message translates to:
  /// **'No QR code found!'**
  String get qrNotFound;

  /// No description provided for @qrInFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'No QR code was found in the selected image.'**
  String get qrInFileNotFound;

  /// No description provided for @qrInFileNotFound2.
  ///
  /// In en, this message translates to:
  /// **'You can show me where the QR code is located.'**
  String get qrInFileNotFound2;

  /// No description provided for @qrInFileNotFound3.
  ///
  /// In en, this message translates to:
  /// **'I expect i will find the code if it is in the middle of the marked area.'**
  String get qrInFileNotFound3;

  /// No description provided for @markQrCode.
  ///
  /// In en, this message translates to:
  /// **'Mark QR Code'**
  String get markQrCode;

  /// No description provided for @malformedData.
  ///
  /// In en, this message translates to:
  /// **'Malformed data'**
  String get malformedData;

  /// No description provided for @linkMustOtpAuth.
  ///
  /// In en, this message translates to:
  /// **'The link must start with otpauth://'**
  String get linkMustOtpAuth;

  /// No description provided for @clipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Clipboard is empty'**
  String get clipboardEmpty;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get invalidUrl;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['cs', 'de', 'en', 'es', 'fr', 'nl', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs': return AppLocalizationsCs();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'nl': return AppLocalizationsNl();
    case 'pl': return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
