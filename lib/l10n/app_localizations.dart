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
import 'app_localizations_id.dart';
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
    Locale('id'),
    Locale('nl'),
    Locale('pl')
  ];

  /// Buttontext to add a new folder.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get a11yAddFolderButton;

  /// Title of the screen where tokens are created manually.
  ///
  /// In en, this message translates to:
  /// **'Add token manually'**
  String get a11yAddTokenManuallyButton;

  /// A11y label for the button to close the search tokens field.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get a11yCloseSearchTokensButton;

  /// Title of the licenses screen.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get a11yLicensesButton;

  /// A11y label for the push tokens button.
  ///
  /// In en, this message translates to:
  /// **'Push Tokens'**
  String get a11yPushTokensButton;

  /// Accessibility label for the button to scan qr-codes.
  ///
  /// In en, this message translates to:
  /// **'Scan QR-Code'**
  String get a11yScanQrCodeButton;

  /// A11y label for the scan qr code view when the camera is active.
  ///
  /// In en, this message translates to:
  /// **' Scan-QR-code view. Cammera is active'**
  String get a11yScanQrCodeViewActive;

  /// A11y label for the flash light button of the scan qr code view when the flashlight is off.
  ///
  /// In en, this message translates to:
  /// **'Tap to turn on flashlight.'**
  String get a11yScanQrCodeViewFlashlightOff;

  /// A11y label for the flash light button of the scan qr code view when the flashlight is on.
  ///
  /// In en, this message translates to:
  /// **'Tap to turn off flashlight.'**
  String get a11yScanQrCodeViewFlashlightOn;

  /// A11y label for the gallery button of the scan qr code view.
  ///
  /// In en, this message translates to:
  /// **'Open gallery'**
  String get a11yScanQrCodeViewGallery;

  /// A11y label for the scan qr code view when the camera is not active.
  ///
  /// In en, this message translates to:
  /// **'Scan-QR-code view. Cammera is not active'**
  String get a11yScanQrCodeViewInactive;

  /// A11y label for the search tokens input field.
  ///
  /// In en, this message translates to:
  /// **'Search tokens'**
  String get a11ySearchTokensButton;

  /// Accessibility label for the button to open the settings page.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get a11ySettingsButton;

  /// Label for e.g. a button. Something gets accepted by the user.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Title of the dialog where a new folder can be added.
  ///
  /// In en, this message translates to:
  /// **'Create new folder'**
  String get addANewFolder;

  /// Description of the checkbox to add system information to the error report.
  ///
  /// In en, this message translates to:
  /// **'Add system information'**
  String get addSystemInfo;

  /// The button to open the screen to add tokens by hand.
  ///
  /// In en, this message translates to:
  /// **'Add token'**
  String get addToken;

  /// Label for the box where the user can write somthing about the error.
  ///
  /// In en, this message translates to:
  /// **'Optional message'**
  String get additionalErrorMessage;

  /// Title of the dropdown button where the encoding is selected.
  ///
  /// In en, this message translates to:
  /// **'Algorithm'**
  String get algorithm;

  /// Error message when the algorithm is not supported.
  ///
  /// In en, this message translates to:
  /// **'The algorithm {algorithm} is not supported'**
  String algorithmUnsupported(String algorithm);

  /// Content of the push synchronization dialog. Signaling the user that everything worked.
  ///
  /// In en, this message translates to:
  /// **'All tokens are synchronized.'**
  String get allTokensSynchronized;

  /// Buttontext to save the backup as a file.
  ///
  /// In en, this message translates to:
  /// **'As file'**
  String get asFile;

  /// Buttontext to export the token as a qr code.
  ///
  /// In en, this message translates to:
  /// **'As QR code'**
  String get asQrCode;

  /// The content of the dialog that asks the user if he sent the error log.
  ///
  /// In en, this message translates to:
  /// **'Did you send the log, and do you want to clear it now?'**
  String get askLogSendedDescription;

  /// Message shown as a dialog body that tells the user that device credentials or biometrics must be setup for this action.
  ///
  /// In en, this message translates to:
  /// **'This action requires the device to be secured by credentials or biometrics.'**
  String get authNotSupportedBody;

  /// Message shown as a dialog title that tells the user that device credentials or biometrics must be setup for this action.
  ///
  /// In en, this message translates to:
  /// **'Device credentials or biometrics required'**
  String get authNotSupportedTitle;

  /// Message to accepting a push request for authentication.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to accept the push request.'**
  String get authToAcceptPushRequest;

  /// Message for declining a push request for authentication.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to decline the push request.'**
  String get authToDeclinePushRequest;

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

  /// No description provided for @authenticationRequest.
  ///
  /// In en, this message translates to:
  /// **'Authentication request'**
  String get authenticationRequest;

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

  /// Message showed as a title in a dialog which indicates the user has not set up biometric authentication on their device. It is used on Android side. Maximum 60 characters.
  ///
  /// In en, this message translates to:
  /// **'Biometrics not setup'**
  String get biometricRequiredTitle;

  /// Message to let the user know that authentication was successful. It is used on Android side. Maximum 60 characters.
  ///
  /// In en, this message translates to:
  /// **'Authentication successful'**
  String get biometricSuccess;

  /// Smaller text for the button to discard the push request.
  ///
  /// In en, this message translates to:
  /// **'but discard it'**
  String get butDiscardIt;

  /// Button to cancel an action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Error message when the server certificate should be checked.
  ///
  /// In en, this message translates to:
  /// **'Please check the server certificate'**
  String get checkServerCertificate;

  /// Tells the user to check the network connection.
  ///
  /// In en, this message translates to:
  /// **'Please check your network connection and try again.'**
  String get checkYourNetwork;

  /// Button to clear the error log.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearErrorLog;

  /// No description provided for @clipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Clipboard is empty'**
  String get clipboardEmpty;

  /// Title of the dialog where a token can be deleted.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDeletion;

  /// Asks for confirmation on deleting a token.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String confirmDeletionOf(String name);

  /// Gives the user a hint about the consequences of deleting a folder.
  ///
  /// In en, this message translates to:
  /// **'Deleting a folder has no effect on the tokens in it.\nThe tokens are moved to the main list.'**
  String get confirmFolderDeletionHint;

  /// Title of the input field where the user has to confirm the password.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// Gives the user a hint about the consequences of deleting a token.
  ///
  /// In en, this message translates to:
  /// **'You may no longer be able to log in if you delete this token.\nPlease make sure that you can log in to the associated account without this token.'**
  String get confirmTokenDeletionHint;

  /// Title of the confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// Tells the user that the connection failed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed.'**
  String get connectionFailed;

  /// Title for the container view.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get container;

  /// Title of the dialog that tells the user that the container already exists.
  ///
  /// In en, this message translates to:
  /// **'Container already exists'**
  String get containerAlreadyExists;

  /// Title of the container details dialog.
  ///
  /// In en, this message translates to:
  /// **'Container details'**
  String get containerDetails;

  /// Title of the container serial field.
  ///
  /// In en, this message translates to:
  /// **'Container Serial'**
  String get containerSerial;

  /// Title of the container sync url field.
  ///
  /// In en, this message translates to:
  /// **'Container Sync Url'**
  String get containerSyncUrl;

  /// Button to continue an action.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// A11y label for the button to copy the otp value to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy OTP to clipboard'**
  String get copyOTPToClipboard;

  /// Error message when the connection to the server could not be established.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to server'**
  String get couldNotConnectToServer;

  /// Tells the user that the message could not be signed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign message.'**
  String get couldNotSignMessage;

  /// Describes the field where the tokens counter should be entered.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counter;

  /// Buttontext to create something e.g. a Folder.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Label for the creation date of the token.
  ///
  /// In en, this message translates to:
  /// **'Created on'**
  String get createdAt;

  /// Label for the creator of the token.
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get creator;

  /// Text for the trailing part of the day password token.
  ///
  /// In en, this message translates to:
  /// **'Valid for'**
  String get dayPasswordValidFor;

  /// Text for the trailing part of the day password token.
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get dayPasswordValidUntil;

  /// Label for e.g. a button. Something gets declined by the user.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// Smaller text for the button to decline the push request.
  ///
  /// In en, this message translates to:
  /// **'decline it'**
  String get declineIt;

  /// Buttontext to decrypt the tokens.
  ///
  /// In en, this message translates to:
  /// **'Decrypt'**
  String get decrypt;

  /// Buttontext to delete all tokens when they could not be decrypted.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get decryptErrorButtonDelete;

  /// Buttontext to retry decrypting the tokens when a decryption error occurred.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get decryptErrorButtonRetry;

  /// Buttontext to send an error report when a decryption error occurred.
  ///
  /// In en, this message translates to:
  /// **'Send error'**
  String get decryptErrorButtonSendError;

  /// Dialog content when the tokens could not be decrypted.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, the app was unable to decrypt your tokens. This indicates that the encryption key is broken. You can try again or delete the app data, which would delete the tokens in the app.'**
  String get decryptErrorContent;

  /// Content of the dialog that ensures the user wants to delete all tokens.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the app data?'**
  String get decryptErrorDeleteConfirmationContent;

  /// Title of the dialog when the tokens could not be decrypted.
  ///
  /// In en, this message translates to:
  /// **'Decryption error'**
  String get decryptErrorTitle;

  /// Label that describes deleting the token.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Content of the dialog that ensures the user wants to delete a container.
  ///
  /// In en, this message translates to:
  /// **'If you delete this container, the smartphone is disconnected from the privacyIDEA server and the tokens of this container become unusable. Before deleting, make sure that the corresponding tokens are no longer required!'**
  String get deleteContainerDialogContent;

  /// Title of the dialog where a container can be deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleting Container {serial}'**
  String deleteContainerDialogTitle(String serial);

  /// Text for the authentication dialog when the user wants to delete a locked token.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to delete the locked token.'**
  String get deleteLockedToken;

  /// Title of the details action Button.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// Message showed as a title in a dialog which indicates the user has not set up credentials authentication on their device. It is used on Android side. Maximum 60 characters.
  ///
  /// In en, this message translates to:
  /// **'Device credentials not set up'**
  String get deviceCredentialsRequiredTitle;

  /// Used for 'deviceCredentialsSetupDescription' of 'AndroidAuthMessages'
  ///
  /// In en, this message translates to:
  /// **'Setup device credentials in the device\'s settings'**
  String get deviceCredentialsSetupDescription;

  /// Title of the dropdown button where the number of digits for the opt value is selected.
  ///
  /// In en, this message translates to:
  /// **'Digits'**
  String get digits;

  /// Text of a button that closes a dialog.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// Buttontext for finishing an action.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Label for the edit action.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Text for the authentication dialog when the user wants to edit a locked token.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to edit the locked token.'**
  String get editLockedToken;

  /// Title for the edit token dialog.
  ///
  /// In en, this message translates to:
  /// **'Edit Token'**
  String get editToken;

  /// Name of the setting switch that enables polling.
  ///
  /// In en, this message translates to:
  /// **'Enable polling'**
  String get enablePolling;

  /// Title of the dropdown button where the encoding is selected.
  ///
  /// In en, this message translates to:
  /// **'Encoding'**
  String get encoding;

  /// Title of the screen where tokens are created manually, tells the user to enter all required values.
  ///
  /// In en, this message translates to:
  /// **'Enter token details'**
  String get enterDetailsForToken;

  /// Buttontext for the import type link.
  ///
  /// In en, this message translates to:
  /// **'Enter link'**
  String get enterLink;

  /// Content of the dialog where the user has to enter a password to encrypt the tokens.
  ///
  /// In en, this message translates to:
  /// **'Enter a password to encrypt the tokens. This password will be required to import the tokens.'**
  String get enterPasswordToEncrypt;

  /// Message that tells the user that the error log was cleared.
  ///
  /// In en, this message translates to:
  /// **'Error log cleared.'**
  String get errorLogCleared;

  /// Message that tells the user that the error log is empty.
  ///
  /// In en, this message translates to:
  /// **'The error log is empty.'**
  String get errorLogEmpty;

  /// Title of the error log screen.
  ///
  /// In en, this message translates to:
  /// **'Error log'**
  String get errorLogTitle;

  /// Message for email body
  ///
  /// In en, this message translates to:
  /// **'The error log file is attached.\nYou can replace this text with additional information about the error.'**
  String get errorMailBody;

  /// Error message when the private key is missing.
  ///
  /// In en, this message translates to:
  /// **'Private key missing'**
  String get errorMissingPrivateKey;

  /// Tells the user that the token could not be rolled out, because a network error occurred.
  ///
  /// In en, this message translates to:
  /// **'Rolling out token {name} failed.'**
  String errorRollOutFailed(String name);

  /// Tells the user that the roll-out failed because the server could not be reached.
  ///
  /// In en, this message translates to:
  /// **'Rolling out token {name} failed, the server could not be reached.'**
  String errorRollOutNoConnectionToServer(String name);

  /// Tells the user that the roll-out and not possible anymore for some reason.
  ///
  /// In en, this message translates to:
  /// **'Rolling out this Token is not possible anymore.'**
  String get errorRollOutNotPossibleAnymore;

  /// Tells the user that the roll-out failed because the SSL handshake failed.
  ///
  /// In en, this message translates to:
  /// **'SSL handshake failed. Roll-out not possible.'**
  String get errorRollOutSSLHandshakeFailed;

  /// Tells the user that the roll-out failed because of an unknown error.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred. Roll-out not possible: {e}'**
  String errorRollOutUnknownError(String e);

  /// Tells the user that the file could not be saved.
  ///
  /// In en, this message translates to:
  /// **'Saving to file failed'**
  String get errorSavingFile;

  /// Tells the user that synchronizing the push tokens failed because the server could not be reached.
  ///
  /// In en, this message translates to:
  /// **'Synchronizing tokens failed, privacyIDEA server could not be reached.'**
  String get errorSynchronizationNoNetworkConnection;

  /// The submessage (reason) of "errorRollOutNotPossibleAnymore" that tells the user that the token is expired.
  ///
  /// In en, this message translates to:
  /// **'The token {name} has expired.'**
  String errorTokenExpired(String name);

  /// Error message when unlinking a push token failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to unlink the push token {label}.'**
  String errorUnlinkingPushToken(String label);

  /// errorWhenPullingChallenges
  ///
  /// In en, this message translates to:
  /// **'An error occured when polling for challenges of {name}'**
  String errorWhenPullingChallenges(String name);

  /// Shows the user an example of a valid URL.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL like: \"https://example.com/\"'**
  String get exampleUrl;

  /// Text for the authentication dialog when the user wants to expand a locked folder.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to uncollapse the locked folder.'**
  String get expandLockedFolder;

  /// Buttontext to export tokens.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// Description of the checkbox to export all tokens.
  ///
  /// In en, this message translates to:
  /// **'Export all tokens'**
  String get exportAllTokens;

  /// Text for the authentication dialog when the user wants to export a locked token.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to export locked tokens.'**
  String get exportLockedTokenReason;

  /// Buttontext to export non privacyIDEA tokens.
  ///
  /// In en, this message translates to:
  /// **'Export non-privacyIDEA tokens'**
  String get exportNonPrivacyIDEATokens;

  /// Button to export one more token.
  ///
  /// In en, this message translates to:
  /// **'One more'**
  String get exportOneMore;

  /// Title of the export Tokens dialog.
  ///
  /// In en, this message translates to:
  /// **'Export tokens'**
  String get exportTokens;

  /// Text for the loading indicator when exporting tokens.
  ///
  /// In en, this message translates to:
  /// **'Exporting tokens...'**
  String get exportingTokens;

  /// Error message when finalizing a container failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to finalize the container {serial}'**
  String failedToFinalizeContainer(String serial);

  /// Error message when something could not be loaded.
  ///
  /// In en, this message translates to:
  /// **'Failed to load: \"{name}\"'**
  String failedToLoad(String name);

  /// No description provided for @failedToSyncContainer.
  ///
  /// In en, this message translates to:
  /// **'Failed to sync container {serial}'**
  String failedToSyncContainer(String serial);

  /// Text for the feedback button and view title of the feedback screen.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// Description for the feedback screen.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions, suggestions or problems, please let us know.'**
  String get feedbackDescription;

  /// Descripes waht happens when the user clicks on the send button.
  ///
  /// In en, this message translates to:
  /// **'A ready-made e-mail will open, which you can send to us. If desired, information about your device and the version of the application will be added. You can check and edit the email before sending it.'**
  String get feedbackHint;

  /// First part of the text that tells the user that he agrees to the privacy policy by sending feedback.
  ///
  /// In en, this message translates to:
  /// **'By sending the feedback you agree to our '**
  String get feedbackPrivacyPolicy1;

  /// Taping on this should open the privacy policy.
  ///
  /// In en, this message translates to:
  /// **'privacy policy'**
  String get feedbackPrivacyPolicy2;

  /// Last part of the text that tells the user that he agrees to the privacy policy by sending feedback.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get feedbackPrivacyPolicy3;

  /// The content of the dialog that appears after the feedback was sent.
  ///
  /// In en, this message translates to:
  /// **'Thank you very much for your help in making this application better!'**
  String get feedbackSentDescription;

  /// The Title of the dialog that appears after the feedback was sent.
  ///
  /// In en, this message translates to:
  /// **'Feedback sent'**
  String get feedbackSentTitle;

  /// First big line of the feedback screen.
  ///
  /// In en, this message translates to:
  /// **'Your feedback is always welcome!'**
  String get feedbackTitle;

  /// Tells the user that the file was saved to the downloads folder.
  ///
  /// In en, this message translates to:
  /// **'File saved to Downloads folder'**
  String get fileSavedToDownloadsFolder;

  /// Title of the finalization state field.
  ///
  /// In en, this message translates to:
  /// **'Finalization State'**
  String get finalizationState;

  /// Text for the error message when finalizing a container failed for some reason.
  ///
  /// In en, this message translates to:
  /// **'Finalize Container Failed'**
  String get finalizeContainerFailed;

  /// Label for the field where the firebase token is shown.
  ///
  /// In en, this message translates to:
  /// **'Firebase Token'**
  String get firebaseToken;

  /// Label for the input field where the folder name should be entered.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get folderName;

  /// Title of a dialog telling the user that the phone part gets generated right now.
  ///
  /// In en, this message translates to:
  /// **'Generating phone part'**
  String get generatingPhonePart;

  /// Buttontext to open the GitHub page.
  ///
  /// In en, this message translates to:
  /// **'This Application is Open Source\nVisit us on GitHub'**
  String get gitHubButton;

  /// Message showed on a button that the user can click to go to settings pages from the current dialog. It is used on both Android and iOS side. Maximum 30 characters.
  ///
  /// In en, this message translates to:
  /// **'Go to settings'**
  String get goToSettingsButton;

  /// Tells the user that they need to set up device credentials in the device's settings.
  ///
  /// In en, this message translates to:
  /// **'Authentication by credentials or biometrics is not set up on your device. Please set it up in the device\'s settings.'**
  String get goToSettingsDescription;

  /// Buttontext to grant the camera permission.
  ///
  /// In en, this message translates to:
  /// **'Grant permission'**
  String get grantCameraPermissionDialogButton;

  /// Content of the dialog that asks the user to grant the camera permission.
  ///
  /// In en, this message translates to:
  /// **'Please grant camera permission to scan QR codes.'**
  String get grantCameraPermissionDialogContent;

  /// Description for the permanently denied camera permission.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is permanently denied. Please grant camera permission in your Phone\'s settings.'**
  String get grantCameraPermissionDialogPermanentlyDenied;

  /// Title of the dialog that asks the user to grant the camera permission.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is not granted'**
  String get grantCameraPermissionDialogTitle;

  /// Error message when the handshake failed.
  ///
  /// In en, this message translates to:
  /// **'Handshake failed'**
  String get handshakeFailed;

  /// Label for the switch to hide push tokens.
  ///
  /// In en, this message translates to:
  /// **'Hide push tokens'**
  String get hidePushTokens;

  /// Descripes what happens when the user hides the push tokens.
  ///
  /// In en, this message translates to:
  /// **'Hide push tokens from the token list. This will not delete the tokens and they will still be visible on a separate screen.'**
  String get hidePushTokensDescription;

  /// Title of the image url field.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrl;

  /// Title for the section where the user can see the conflicting tokens.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{There is no conflict with existing tokens.} one{There is a conflict with existing tokens.\nPlease select which one you would like to keep.} other{There are {count} conflicts with existing tokens.\nPlease select the tokens you wish to keep.}}'**
  String importConflictToken(int count);

  /// Title for the section where the user can see the tokens that already exist.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{No token was found that is already in the application.} one{A token was found that already exists in the application.} other{{count} tokens was found that are already in the application.}}'**
  String importExistingToken(int count);

  /// Title of the import/export settings group.
  ///
  /// In en, this message translates to:
  /// **'Import/Export tokens'**
  String get importExportTokens;

  /// Title for the section where the user can see the tokens that could not be imported.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{No token Failed to import.} one{Failed to import a token.} other{Failed to import {count} tokens.}}'**
  String importFailedToken(int count);

  /// Tells the user importent information about the import of 2FAS tokens.
  ///
  /// In en, this message translates to:
  /// **'Select your 2FAS backup.\nIf you do not have a backup, create one in the 2FAS app. We recommend using a password.'**
  String get importHint2FAS;

  /// Tells the user importent information about the import of Aegis backup files.
  ///
  /// In en, this message translates to:
  /// **'Select your Aegis export (.JSON).\nIf you do not have an export, please create one via the settings menu in the Aegis app. The use of a password is recommended.'**
  String get importHintAegisBackupFile;

  /// Tells the user importent information about the import of Aegis links.
  ///
  /// In en, this message translates to:
  /// **'Enter the link you receive when you transfer entries from Aegis.'**
  String get importHintAegisLink;

  /// Tells the user importent information about the import of Aegis qr codes.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code you receive when you transfer entries from Aegis.'**
  String get importHintAegisQrScan;

  /// Tells the user importent information about the import of Authenticator Pro files.
  ///
  /// In en, this message translates to:
  /// **'To create a backup of the Authenticator Pro app, navigate to the settings and tap on \"Auto backup\". Select a storage location and set a password. Then press \"Back up now\" to export the tokens.'**
  String get importHintAuthenticatorProFile;

  /// Tells the user importent information about the import of FreeOTP+ files.
  ///
  /// In en, this message translates to:
  /// **'To create a backup of the FreeOTP+ app, tap on the three dots in the upper right corner and select \"Export\". You can choose between JSON and URI format. We recommend to delete the backup after importing it, because it is not encrypted.'**
  String get importHintFreeOtpPlusFile;

  /// Tells the user importent information about the import of FreeOTP+ qr codes.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code you receive when you press the three dots in the tile of the token and select \"Share QR code\".'**
  String get importHintFreeOtpPlusQrScan;

  /// Tells the user importent information about the import of Google qr codes.
  ///
  /// In en, this message translates to:
  /// **'Select an image file with the QR code you receive when you export your accounts from Google Authenticator.\n!! Note that it is not safe to save the QR code on your device as the tokens are not encrypted !!'**
  String get importHintGoogleQrFile;

  /// Tells the user importent information about the import of Google qr codes.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code you receive when you export your accounts from Google Authenticator.'**
  String get importHintGoogleQrScan;

  /// Tells the user importent information about the import of privacyIDEA files.
  ///
  /// In en, this message translates to:
  /// **'To create a backup, go to the settings and tap on \"Export\". Select \"As file\", select the tokens you want to export. Then tap on \"Export\" and set a password. The storage location is the download folder on your device.'**
  String get importHintPrivacyIdeaFile;

  /// Tells the user importent information about the import of privacyIDEA qr codes.
  ///
  /// In en, this message translates to:
  /// **'Um QR-Codes der Token zu erstellen, navigieren Sie zu den Einstellungen und tippen auf \"Exportieren\". Wählen Sie dann \"Als QR-Code\" und tippen Sie auf den zu exportierenden Token. Diese Variante ist nur für die direkte Übertragung auf ein anderes Gerät geeignet, da der QR-Code nicht verschlüsselt ist.'**
  String get importHintPrivacyIdeaQrScan;

  /// Buttontext to import n tokens.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{Import no token} one{Import one token} other{Import {count} tokens}}'**
  String importNTokens(int count);

  /// Title for the section where the user can see the new tokens.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero{No new token was found.} one{A new token was found that can be imported.} other{{count} new tokens were found that can be imported.}}'**
  String importNewToken(int count);

  /// Title of the import Tokens screen when it is not clear where the tokens come from.
  ///
  /// In en, this message translates to:
  /// **'Import token'**
  String get importTokens;

  /// No description provided for @importantInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Important information'**
  String get importantInformationTitle;

  /// Label for the import method of the token.
  ///
  /// In en, this message translates to:
  /// **'Imported via'**
  String get importedVia;

  /// A11y label for the button that increases the counter.
  ///
  /// In en, this message translates to:
  /// **'Increase counter'**
  String get increaseCounter;

  /// Error message when an internal server error occurred.
  ///
  /// In en, this message translates to:
  /// **'Internal server error ({code})'**
  String internalServerError(String code);

  /// Text for the introduction that explains how to add a folder.
  ///
  /// In en, this message translates to:
  /// **'You can create folders to organize your tokens.'**
  String get introAddFolder;

  /// Introduction text for the manual token enrollment.
  ///
  /// In en, this message translates to:
  /// **'If you don\'t want to scan a QR code, you can also add tokens manually.'**
  String get introAddTokenManually;

  /// Text for the introduction that explains how to drag a token.
  ///
  /// In en, this message translates to:
  /// **'Reorganize your tokens by pressing it for a few seconds and then dragging it to the desired position.'**
  String get introDragToken;

  /// Text for the introduction that explains how to edit a token.
  ///
  /// In en, this message translates to:
  /// **'Here you can edit the token name and see some details.'**
  String get introEditToken;

  /// Text for the introduction that explains where the user can find the hidden push tokens.
  ///
  /// In en, this message translates to:
  /// **'Your push tokens are hidden now.\nBut you can still see them on the push token screen.'**
  String get introHidePushTokens;

  /// Text for the introduction that explains how to lock a token.
  ///
  /// In en, this message translates to:
  /// **'To improve security even more, you can lock tokens.\nThen the token can only be used after authentication.'**
  String get introLockToken;

  /// Text for the introduction that explains how to poll for challenges.
  ///
  /// In en, this message translates to:
  /// **'You can check for new challenges by dragging down the token list.'**
  String get introPollForChallenges;

  /// Text for the introduction that explains how to scan a qr code.
  ///
  /// In en, this message translates to:
  /// **'You can scan QR codes to add tokens.\nWe support every common Two-Factor-Authentication token and also the privacyIDEA tokens.'**
  String get introScanQrCode;

  /// Text for the introduction that explains how to see the available actions for a token.
  ///
  /// In en, this message translates to:
  /// **'Swipe tokens to the left to see available actions.'**
  String get introTokenSwipe;

  /// Error message when the backup file is invalid.
  ///
  /// In en, this message translates to:
  /// **'The selected file is not a valid backup of {appName}.'**
  String invalidBackupFile(String appName);

  /// Error message when the link is invalid.
  ///
  /// In en, this message translates to:
  /// **'The link entered is not a valid token of {appName}, or it is not supported.'**
  String invalidLink(String appName);

  /// Error message when the qr file is invalid.
  ///
  /// In en, this message translates to:
  /// **'The selected file does not contain a valid QR code from {appName}.'**
  String invalidQrFile(String appName);

  /// Error message when the qr scan is invalid.
  ///
  /// In en, this message translates to:
  /// **'The scanned QR code is not a valid backup of {appName}.'**
  String invalidQrScan(String appName);

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get invalidUrl;

  /// Error message when the value is not valid for the parameter.
  ///
  /// In en, this message translates to:
  /// **'The {type} ‘{value}’ is not valid for ‘{parameter}’'**
  String invalidValue(String parameter, String type, String value);

  /// Text for the error message when a value is not valid for a parameter in a specific map.
  ///
  /// In en, this message translates to:
  /// **'The {type} ‘{value}’ is not valid for ‘{parameter}’ in ‘{map}’'**
  String invalidValueIn(String map, String parameter, String type, String value);

  /// Label for the question if the token is exportable.
  ///
  /// In en, this message translates to:
  /// **'Is exportable?'**
  String get isExpotableQuestion;

  /// Title of the field where the user can see if the token is a privacyIDEA token.
  ///
  /// In en, this message translates to:
  /// **'It\'s a privacyIDEA token?'**
  String get isPiTokenQuestion;

  /// Title of the issuer field.
  ///
  /// In en, this message translates to:
  /// **'Issuer'**
  String get issuer;

  /// Label for the issuer of the token, container... etc.
  ///
  /// In en, this message translates to:
  /// **'Issuer: {name}'**
  String issuerLabel(String name);

  /// Title of language setting group.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Message of the error dialog that is shown when an error occurs while using a legacy token.
  ///
  /// In en, this message translates to:
  /// **'The token was enrolled in a old version of this app, which may cause trouble using it.\nIt is suggested to enroll a new push token if the problem persist!'**
  String get legacySigningErrorMessage;

  /// Title of the error dialog that is shown when an error occurs while using a legacy token.
  ///
  /// In en, this message translates to:
  /// **'An error occured while using the legacy token: {tokenLabel}'**
  String legacySigningErrorTitle(String tokenLabel);

  /// Buttontext to open the licenses and version screen.
  ///
  /// In en, this message translates to:
  /// **'Licenses and version'**
  String get licensesAndVersion;

  /// No description provided for @linkMustOtpAuth.
  ///
  /// In en, this message translates to:
  /// **'The link must start with otpauth://'**
  String get linkMustOtpAuth;

  /// Label for the linked container serial number.
  ///
  /// In en, this message translates to:
  /// **'Linked container'**
  String get linkedContainer;

  /// Description of button that locks a token.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get lock;

  /// Message advising the user to re-enable biometrics on their device. It shows in a dialog on iOS side.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is disabled. Please lock and unlock your screen to enable it.'**
  String get lockOut;

  /// Button to open the log menu.
  ///
  /// In en, this message translates to:
  /// **'Log menu'**
  String get logMenu;

  /// Error message when the data is malformed.
  ///
  /// In en, this message translates to:
  /// **'Malformed data'**
  String get malformedData;

  /// Buttontext to mark the qr code.
  ///
  /// In en, this message translates to:
  /// **'Mark QR Code'**
  String get markQrCode;

  /// Error message when a required parameter is missing.
  ///
  /// In en, this message translates to:
  /// **'The value for the [{parameter}] parameter is required, but is missing.'**
  String missingRequiredParameter(String parameter);

  /// Error message when a required parameter is missing in a specific map.Error message when a required parameter is missing in a specific map.Error message when a required parameter is missing in a specific map.Error message when a required parameter is missing in a specific map.
  ///
  /// In en, this message translates to:
  /// **'The value for the parameter [{parameter}] is required, but is missing in \"{map}\".'**
  String missingRequiredParameterIn(String map, String parameter);

  /// Error message when a field must not be empty.
  ///
  /// In en, this message translates to:
  /// **'{field} must not be empty'**
  String mustNotBeEmpty(String field);

  /// Describes the field where the tokens name should be entered.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Content of the field when the answer is no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Tells the user that there is no Firebase token available.
  ///
  /// In en, this message translates to:
  /// **'No Firebase token available'**
  String get noFbToken;

  /// Description of the dialog that tells the user that there is no mail app available.
  ///
  /// In en, this message translates to:
  /// **'There is no e-mail app installed or initialised on this device, please try again when you are able to send an email message.'**
  String get noMailAppDescription;

  /// Title of the dialog that tells the user that there is no mail app available.
  ///
  /// In en, this message translates to:
  /// **'No mail app found'**
  String get noMailAppTitle;

  /// Tells the user that there is no network connection.
  ///
  /// In en, this message translates to:
  /// **'No network connection.'**
  String get noNetworkConnection;

  /// Error message when the public key is missing.
  ///
  /// In en, this message translates to:
  /// **'No public key available'**
  String get noPublicKey;

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

  /// No tokens stored yet.
  ///
  /// In en, this message translates to:
  /// **'No tokens stored yet.'**
  String get noResultTitle;

  /// Tells the user that there are no tokens to export.
  ///
  /// In en, this message translates to:
  /// **'No token available for export'**
  String get noTokenToExport;

  /// Tells the user that there are no tokens to import.
  ///
  /// In en, this message translates to:
  /// **'No token found to import'**
  String get noTokenToImport;

  /// Error message when the user entered a value that is not an integer.
  ///
  /// In en, this message translates to:
  /// **'The value is not an integer.'**
  String get notAnInteger;

  /// Error message when the user entered a value that is not a number.
  ///
  /// In en, this message translates to:
  /// **'The value is not a number.'**
  String get notAnNumber;

  /// Button to confirm an action.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// Button to open something.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// Label for the origin app.
  ///
  /// In en, this message translates to:
  /// **'Origin app'**
  String get originApp;

  /// Title of the origin details menu.
  ///
  /// In en, this message translates to:
  /// **'Origin details'**
  String get originDetails;

  /// Tells the user that the otp value was copied to the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Password \"{otpValue}\" copied to clipboard.'**
  String otpValueCopiedMessage(String otpValue);

  /// Labeltext for the password input field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Hint telling the user that the password cannot be empty.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get passwordCannotBeEmpty;

  /// Hint telling the user that the password cannot contain whitespace.
  ///
  /// In en, this message translates to:
  /// **'Password cannot contain whitespace'**
  String get passwordCannotContainWhitespace;

  /// Hint telling the user that the password must be at least 8 characters long.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMustBeAtLeast8Characters;

  /// Hint telling the user that the password must contain a lowercase letter.
  ///
  /// In en, this message translates to:
  /// **'Password must contain lowercase letter'**
  String get passwordMustContainLowercaseLetter;

  /// Hint telling the user that the password must contain a number.
  ///
  /// In en, this message translates to:
  /// **'Password must contain number'**
  String get passwordMustContainNumber;

  /// Hint telling the user that the password must contain a special character.
  ///
  /// In en, this message translates to:
  /// **'Password must contain special character'**
  String get passwordMustContainSpecialCharacter;

  /// Hint telling the user that the password must contain an uppercase letter.
  ///
  /// In en, this message translates to:
  /// **'Password must contain uppercase letter'**
  String get passwordMustContainUppercaseLetter;

  /// Hint telling the user that the confirm password does not match the password.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Title of the section in the patch notes that lists the bug fixes.
  ///
  /// In en, this message translates to:
  /// **'Bug fixes'**
  String get patchNotesBugFixes;

  /// Title of the dialog that shows the patch notes.
  ///
  /// In en, this message translates to:
  /// **'What\'s new?'**
  String get patchNotesDialogTitle;

  /// Title of the section in the patch notes that lists the improvements.
  ///
  /// In en, this message translates to:
  /// **'Improvements'**
  String get patchNotesImprovements;

  /// Title of the section in the patch notes that lists the new features.
  ///
  /// In en, this message translates to:
  /// **'New features'**
  String get patchNotesNewFeatures;

  /// Patch notes for a new feature in version 4.3.0.
  ///
  /// In en, this message translates to:
  /// **'Support for importing tokens from Google, Aegis and 2FAS Authenticator has been added. More import sources will be added in the future.'**
  String get patchNotesV4_3_0NewFeatures1;

  /// Patch notes for a new feature in version 4.3.0.
  ///
  /// In en, this message translates to:
  /// **'Added feedback option to the settings.'**
  String get patchNotesV4_3_0NewFeatures2;

  /// Patch notes for a new feature in version 4.3.0.
  ///
  /// In en, this message translates to:
  /// **'Push tokens can now be hidden from the token list.'**
  String get patchNotesV4_3_0NewFeatures3;

  /// Patch notes for a new feature in version 4.3.0.
  ///
  /// In en, this message translates to:
  /// **'Introductions have been added to help new users get started.'**
  String get patchNotesV4_3_0NewFeatures4;

  /// Patch notes for a new feature in version 4.3.0.
  ///
  /// In en, this message translates to:
  /// **'You can now search for tokens by tapping the magnifying glass in the upper right corner.'**
  String get patchNotesV4_3_0NewFeatures5;

  /// Patch notes for a new feature in version 4.3.0.
  ///
  /// In en, this message translates to:
  /// **'Added HomeWidget token for Android 12 and later.'**
  String get patchNotesV4_3_0NewFeatures6;

  /// Patch notes for a bug fix in version 4.3.1.
  ///
  /// In en, this message translates to:
  /// **'Fixed an issue where the otp value was not displayed after authentication on some devices.'**
  String get patchNotesV4_3_1BugFix1;

  /// Patch notes for an improvement in version 4.3.1.
  ///
  /// In en, this message translates to:
  /// **'Improved the qr code scanner.'**
  String get patchNotesV4_3_1Improvement1;

  /// Patch notes for an improvement in version 4.4.0.
  ///
  /// In en, this message translates to:
  /// **'Further import sources have been added.'**
  String get patchNotesV4_4_0Improvement1;

  /// Patch notes for an improvement in version 4.4.0.
  ///
  /// In en, this message translates to:
  /// **'Improved recognition of QR codes from image files.'**
  String get patchNotesV4_4_0Improvement2;

  /// Patch notes for a new feature in version 4.4.0.
  ///
  /// In en, this message translates to:
  /// **'It is now possible to export tokens where it can be ensured that they are not privacyIDEA tokens. Currently, it cannot be ruled out that tokens added via the QR code scanner originate from privacyIDEA. The differentiation will be improved in future versions.'**
  String get patchNotesV4_4_0NewFeatures1;

  /// Patch notes for a new feature in version 4.4.0.
  ///
  /// In en, this message translates to:
  /// **'Added support for privacyIDEA\'s \"require presence\"'**
  String get patchNotesV4_4_0NewFeatures2;

  /// Patch notes for an improvement in version 4.4.2
  ///
  /// In en, this message translates to:
  /// **'Added flashlight support for QR code scanning.'**
  String get patchNotesV4_4_2Improvement1;

  /// Patch notes for a new feature in version 4.4.2
  ///
  /// In en, this message translates to:
  /// **'Tokens can now be inserted using copy & paste.'**
  String get patchNotesV4_4_2NewFeatures1;

  /// Patch notes for a new feature in version 4.4.2
  ///
  /// In en, this message translates to:
  /// **'Added gallery support for QR code scanning.'**
  String get patchNotesV4_4_2NewFeatures2;

  /// Title of the dropdown button where the period of the totp token is selected.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// Title of a dialog telling the user that the phone was generated, and it is shown to the user.
  ///
  /// In en, this message translates to:
  /// **'Phone part:'**
  String get phonePart;

  /// Message when privacyIDEA sends a server code.
  ///
  /// In en, this message translates to:
  /// **'PI Server Code: {code}'**
  String piServerCode(String code);

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

  /// Tells the user that the polling failed.
  ///
  /// In en, this message translates to:
  /// **'Polling failed.'**
  String get pollingFailed;

  /// Tells the user that the polling failed.
  ///
  /// In en, this message translates to:
  /// **'Polling failed for {serial}'**
  String pollingFailedFor(String serial);

  /// Button to open the privacy policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// Label for the text field where the public key is shown.
  ///
  /// In en, this message translates to:
  /// **'Public Key'**
  String get publicKey;

  /// Title of the push endpoint url field.
  ///
  /// In en, this message translates to:
  /// **'Push endpoint URL'**
  String get pushEndpointUrl;

  /// Error message when the push request could not be parsed.
  ///
  /// In en, this message translates to:
  /// **'Push request could not be parsed.'**
  String get pushRequestParseError;

  /// Title for the settings block concerning the push tokens.
  ///
  /// In en, this message translates to:
  /// **'Push Token'**
  String get pushToken;

  /// Error message when the qr file could not be decoded.
  ///
  /// In en, this message translates to:
  /// **'It was not possible to decode the QR code from the selected image, please use the QR code scanner instead.'**
  String get qrFileDecodeError;

  /// Error message when the qr code in the file could not be found.
  ///
  /// In en, this message translates to:
  /// **'No QR code was found in the selected image.'**
  String get qrInFileNotFound;

  /// Error message when the qr code in the file could not be found.
  ///
  /// In en, this message translates to:
  /// **'You can show me where the QR code is located.'**
  String get qrInFileNotFound2;

  /// Error message when the qr code in the file could not be found.
  ///
  /// In en, this message translates to:
  /// **'I expect i will find the code if it is in the middle of the marked area.'**
  String get qrInFileNotFound3;

  /// Error message when the qr code could not be found.
  ///
  /// In en, this message translates to:
  /// **'No QR code found!'**
  String get qrNotFound;

  /// Label that describes renaming the token.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// Title of the dialog where a new name for a token can be entered.
  ///
  /// In en, this message translates to:
  /// **'Rename token'**
  String get renameToken;

  /// Title of the dialog where a new name for a token folder can be entered.
  ///
  /// In en, this message translates to:
  /// **'Rename folder'**
  String get renameTokenFolder;

  /// Button to replace something, depending on the context.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replaceButton;

  /// Description of the authentication request.
  ///
  /// In en, this message translates to:
  /// **'Sent by {issuer} for your account: \"{account}\"'**
  String requestInfo(String account, String issuer);

  /// The description of the polling feature.
  ///
  /// In en, this message translates to:
  /// **'Request push challenges from the server periodically. Enable this if push challenges are not received normally.'**
  String get requestPushChallengesPeriodically;

  /// Content of the dialog that asks the user if the request was triggered by the user.
  ///
  /// In en, this message translates to:
  /// **'Was this request triggered by you?'**
  String get requestTriggerdByUserQuestion;

  /// Buttontext to retry the rollout.
  ///
  /// In en, this message translates to:
  /// **'Retry rollout'**
  String get retryRolloutButton;

  /// Message for the rollout process
  ///
  /// In en, this message translates to:
  /// **'Rollout completed'**
  String get rolloutStateCompleted;

  /// Message for the rollout process
  ///
  /// In en, this message translates to:
  /// **'Generating key pair'**
  String get rolloutStateGeneratingKeyPair;

  /// Message for the rollout process
  ///
  /// In en, this message translates to:
  /// **'Generating key pair completed'**
  String get rolloutStateGeneratingKeyPairCompleted;

  /// Message for the rollout process
  ///
  /// In en, this message translates to:
  /// **'Generating key pair failed'**
  String get rolloutStateGeneratingKeyPairFailed;

  /// Label that tells the user that the token is being rolled out.
  ///
  /// In en, this message translates to:
  /// **'Start rollout'**
  String get rolloutStateNotStarted;

  /// Message for the rollout process
  ///
  /// In en, this message translates to:
  /// **'Parsing response'**
  String get rolloutStateParsingResponse;

  /// Message for the rollout process
  ///
  /// In en, this message translates to:
  /// **'Parsing response completed'**
  String get rolloutStateParsingResponseCompleted;

  /// Message for the rollout process
  ///
  /// In en, this message translates to:
  /// **'Parsing response failed'**
  String get rolloutStateParsingResponseFailed;

  /// Message for the rollout process
  ///
  /// In en, this message translates to:
  /// **'Sending public key'**
  String get rolloutStateSendingPublicKey;

  /// Message for the rollout process
  ///
  /// In en, this message translates to:
  /// **'Senden des öffentlichen Schlüssels abgeschlossen'**
  String get rolloutStateSendingPublicKeyCompleted;

  /// Message for the rollout process
  ///
  /// In en, this message translates to:
  /// **'Sending public key failed'**
  String get rolloutStateSendingPublicKeyFailed;

  /// Buttontext to save something, depending on the context.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// The button to scan otpauth qr-codes.
  ///
  /// In en, this message translates to:
  /// **'Scan QR-Code'**
  String get scanQrCode;

  /// Content of the token export dialog that shows the user the qr code.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code with your new device to import the token.'**
  String get scanThisQrWithNewDevice;

  /// Semantics label for the animated countdown until the next OTP is generated.
  ///
  /// In en, this message translates to:
  /// **'Seconds until next OTP'**
  String get secondsUntilNextOTP;

  /// Error message when the secret is missing.
  ///
  /// In en, this message translates to:
  /// **'Secret is required'**
  String get secretIsRequired;

  /// Describes the field where the tokens secret should be entered.
  ///
  /// In en, this message translates to:
  /// **'Secret key'**
  String get secretKey;

  /// Buttontext and Title for the import type file.
  ///
  /// In en, this message translates to:
  /// **'Select file'**
  String get selectFile;

  /// Title of the screen where the user can select the token import source.
  ///
  /// In en, this message translates to:
  /// **'Select import source'**
  String get selectImportSource;

  /// Title of the screen where the user can select the token import type.
  ///
  /// In en, this message translates to:
  /// **'How do you want to import the tokens?'**
  String get selectImportType;

  /// Title of the screen where the user can select the tokens to export.
  ///
  /// In en, this message translates to:
  /// **'Please select the tokens you want to export.'**
  String selectTokensToExport(num count);

  /// Tells the user why some tokens are not exportable.
  ///
  /// In en, this message translates to:
  /// **'If a token is not listed, it is not guaranteed that it is not a privacyIDEA token.'**
  String get selectTokensToExportHelpContent1;

  /// Tells the user why some tokens are not exportable.
  ///
  /// In en, this message translates to:
  /// **'Currently only manually added and imported tokens are exportable.'**
  String get selectTokensToExportHelpContent2;

  /// Tells the user why some tokens are not exportable.
  ///
  /// In en, this message translates to:
  /// **'We are working on a solution to differentiate between privacyIDEA tokens and private tokens.'**
  String get selectTokensToExportHelpContent3;

  /// Tells the user why some tokens are not exportable.
  ///
  /// In en, this message translates to:
  /// **'You can obtain a new QR code from the service from which you received the token.'**
  String get selectTokensToExportHelpContent4;

  /// Title of the help dialog that explains why some tokens are not exportable.
  ///
  /// In en, this message translates to:
  /// **'Is your token not listed?'**
  String get selectTokensToExportHelpTitle;

  /// Button to send the error log.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Description shown to the user about what info the error report contains.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred in the application. The information below can be send to the developers by email to help prevent this error in the future.'**
  String get sendErrorDialogBody;

  /// Explanation for the user what he will send.
  ///
  /// In en, this message translates to:
  /// **'A predefined email is created.\nIt contains information about the app, the error and the device.\nYou can edit the email before sending it.\nYou can see here how we use the information:'**
  String get sendErrorLogDescription;

  /// Error message when the response to a push request could not be sent.
  ///
  /// In en, this message translates to:
  /// **'Failed to send the response.'**
  String get sendPushRequestResponseFailed;

  /// Tells the user that the server could not be reached.
  ///
  /// In en, this message translates to:
  /// **'The server could not be reached.'**
  String get serverNotReachable;

  /// Button to open the settings page.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Title for the general settings group.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGroupGeneral;

  /// Button to show details.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get showDetails;

  /// Button to show the error log.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get showErrorLog;

  /// Button to show the privacy policy.
  ///
  /// In en, this message translates to:
  /// **'Show privacy policy'**
  String get showPrivacyPolicy;

  /// Message showed as a title in a dialog which indicates the user that they need to scan biometric to continue. It is used on Android side. Maximum 60 characters.
  ///
  /// In en, this message translates to:
  /// **'Authentication required'**
  String get signInTitle;

  /// Tells the user, that the following tokens do not support polling.
  ///
  /// In en, this message translates to:
  /// **'Some of the tokens are outdated and do not support polling'**
  String get someTokensDoNotSupportPolling;

  /// Tells the user the status code of the error.
  ///
  /// In en, this message translates to:
  /// **'Status code: {statusCode}'**
  String statusCode(int statusCode);

  /// Text of button that is used to synchronize push tokens.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// Error message when synchronizing a container failed.
  ///
  /// In en, this message translates to:
  /// **'Container synchronization failed'**
  String get syncContainerFailed;

  /// Headline for the list of tokens where the synchronization failed.
  ///
  /// In en, this message translates to:
  /// **'Synchronization failed for the following tokens, please try again:'**
  String get syncFbTokenFailed;

  /// Status message that tells the user to sync the Firebase token manually when the network is available.
  ///
  /// In en, this message translates to:
  /// **'Please synchronize the push tokens manually via the settings when a network connection is available.'**
  String get syncFbTokenManuallyWhenNetworkIsAvailable;

  /// The state of the synchronization of the token
  ///
  /// In en, this message translates to:
  /// **'Sync State'**
  String get syncState;

  /// The description of the state when the synchronization is completed
  ///
  /// In en, this message translates to:
  /// **'Sync completed'**
  String get syncStateCompletedDescription;

  /// The description of the state when the synchronization failed
  ///
  /// In en, this message translates to:
  /// **'Sync Failed'**
  String get syncStateFailedDescription;

  /// The description of the state when the synchronization is not started
  ///
  /// In en, this message translates to:
  /// **'Sync not started'**
  String get syncStateNotStartedDescription;

  /// The description of the state when the synchronization is currently syncing
  ///
  /// In en, this message translates to:
  /// **'Currently Syncing'**
  String get syncStateSyncingDescription;

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

  /// Title of the push synchronization dialog.
  ///
  /// In en, this message translates to:
  /// **'Synchronizing tokens.'**
  String get synchronizingTokens;

  /// Hint telling the user that the secret does not fit the selected encoding.
  ///
  /// In en, this message translates to:
  /// **'The secret does not fit the current encoding'**
  String get theSecretDoesNotFitTheCurrentEncoding;

  /// Title of the setting group where the theme can be selected.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Error message when a request times out.
  ///
  /// In en, this message translates to:
  /// **'Time out'**
  String get timeOut;

  /// Error message when the token data could not be parsed.
  ///
  /// In en, this message translates to:
  /// **'Token data could not be parsed'**
  String get tokenDataParseError;

  /// Title of the token details menu.
  ///
  /// In en, this message translates to:
  /// **'Token details'**
  String get tokenDetails;

  /// Label for the input field where the token link should be entered.
  ///
  /// In en, this message translates to:
  /// **'Token link'**
  String get tokenLinkImport;

  /// Label for the token serial number.
  ///
  /// In en, this message translates to:
  /// **'Token serial'**
  String get tokenSerial;

  /// Content of the import view that tells the user that the tokens are encrypted.
  ///
  /// In en, this message translates to:
  /// **'The tokens are encrypted. Please enter the password to decrypt them.'**
  String get tokensAreEncrypted;

  /// Informs the user that the following tokens cannot be synchronized as they do not support that.
  ///
  /// In en, this message translates to:
  /// **'The following tokens do not support synchronization and must be rolled out again:'**
  String get tokensDoNotSupportSynchronization;

  /// Content of the import view that tells the user that the tokens were successfully decrypted.
  ///
  /// In en, this message translates to:
  /// **'The tokens have been successfully decrypted and can now be imported.'**
  String get tokensSuccessfullyDecrypted;

  /// Title of the dropdown button where the type of the token is selected.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Title of page report mode.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred.'**
  String get unexpectedError;

  /// Tells that something is unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Description of button that unlocks a token.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// Error message when something is not supported, depending on the context.
  ///
  /// In en, this message translates to:
  /// **'The {name} [{value}] is not supported by this version of the app.'**
  String unsupported(String name, String value);

  /// Description of the switch tile where using the devices language can be enabled.
  ///
  /// In en, this message translates to:
  /// **'Use device language if it is supported, otherwise default to english.'**
  String get useDeviceLocaleDescription;

  /// Title of the switch tile where using the devices language can be enabled.
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get useDeviceLocaleTitle;

  /// Error message when a value is not allowed for a specific parameter.
  ///
  /// In en, this message translates to:
  /// **'Type {type} “{value}” is not a permitted value for “{parameter}”'**
  String valueNotAllowed(String parameter, String type, String value);

  /// Error message when a value is not allowed for a specific parameter in a specific map.
  ///
  /// In en, this message translates to:
  /// **' Type {type} “{value}” is not a valid value for “{parameter}” in “{map}”'**
  String valueNotAllowedIn(String map, String parameter, String type, String value);

  /// Title of the switch tile where verbose logging can be enabled.
  ///
  /// In en, this message translates to:
  /// **'Verbose logging'**
  String get verboseLogging;

  /// Title of a section of the patch notes.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionTitle;

  /// Tells the user that the entered password is wrong.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get wrongPassword;

  /// Positive answer text to a binary question. Used for buttons and text fields.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['cs', 'de', 'en', 'es', 'fr', 'id', 'nl', 'pl'].contains(locale.languageCode);

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
    case 'id': return AppLocalizationsId();
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
