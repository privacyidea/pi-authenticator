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

  /// No description provided for @sendErrorLog.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendErrorLog;

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

  /// No description provided for @uncollapseLockedFolder.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to uncollapse the locked folder.'**
  String get uncollapseLockedFolder;

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
  /// **'Foldername'**
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

  /// Tells the user that the roll-out failed because the token has expired.
  ///
  /// In en, this message translates to:
  /// **'Rolling out this Token is not possible anymore.\nThe token {name} has expired.'**
  String errorRollOutTokenExpired(Object name);

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
