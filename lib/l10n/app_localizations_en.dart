import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get name => 'Name';

  @override
  String get secretKey => 'Secret key';

  @override
  String get encoding => 'Encoding';

  @override
  String get algorithm => 'Algorithm';

  @override
  String get digits => 'Digits';

  @override
  String get type => 'Type';

  @override
  String get period => 'Period';

  @override
  String get rename => 'Rename';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get addToken => 'Add token';

  @override
  String get scanQrCode => 'Scan QR-Code';

  @override
  String get enterDetailsForToken => 'Enter details for token';

  @override
  String get pleaseEnterANameForThisToken => 'Please enter a name for this token.';

  @override
  String get pleaseEnterASecretForThisToken => 'Please enter a secret for this token.';

  @override
  String get theSecretDoesNotFitTheCurrentEncoding => 'The secret does not fit the current encoding';

  @override
  String get renameToken => 'Rename token';

  @override
  String get confirmDeletion => 'Confirm deletion';

  @override
  String confirmDeletionOf(Object name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get generatingPhonePart => 'Generating phone part';

  @override
  String get phonePart => 'Phone part:';

  @override
  String otpValueCopiedMessage(Object otpValue) {
    return 'Password \"$otpValue\" copied to clipboard.';
  }

  @override
  String get settings => 'Settings';

  @override
  String get pushToken => 'Push Token';

  @override
  String get theme => 'Theme';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'Use device\'s theme';

  @override
  String get enablePolling => 'Enable polling';

  @override
  String get requestPushChallengesPeriodically => 'Request push challenges from the server periodically. Enable this if push challenges are not received normally.';

  @override
  String get synchronizePushTokens => 'Synchronize push tokens';

  @override
  String get synchronizesTokensWithServer => 'Synchronizes tokens with the privacyIDEA server.';

  @override
  String get sync => 'Sync';

  @override
  String get synchronizingTokens => 'Synchronizing tokens.';

  @override
  String get allTokensSynchronized => 'All tokens are synchronized.';

  @override
  String get synchronizationFailed => 'Synchronization failed for the following tokens, please try again:';

  @override
  String get tokensDoNotSupportSynchronization => 'The following tokens do not support synchronization and must be rolled out again:';

  @override
  String errorRollOutFailed(Object name) {
    return 'Rolling out token $name failed.';
  }

  @override
  String statusCode(Object statusCode) {
    return 'Status code: $statusCode';
  }

  @override
  String get errorSynchronizationNoNetworkConnection => 'Synchronizing tokens failed, privacyIDEA server could not be reached.';

  @override
  String errorRollOutNoConnectionToServer(Object name) {
    return 'Rolling out token $name failed, the server could not be reached.';
  }

  @override
  String errorRollOutUnknownError(Object e) {
    return 'An unknown error occurred. Roll-out not possible: $e';
  }

  @override
  String get rollingOut => 'Rolling out';

  @override
  String get pollingChallenges => 'Polling for new challenges';

  @override
  String get unexpectedError => 'An unexpected error occurred.';

  @override
  String get pollingFailed => 'Polling failed.';

  @override
  String pollingFailedFor(Object serial) {
    return 'Polling failed for $serial';
  }

  @override
  String get noNetworkConnection => 'No network connection.';

  @override
  String get connectionFailed => 'Connection failed.';

  @override
  String get checkYourNetwork => 'Please check your network connection and try again.';

  @override
  String get serverNotReachable => 'The server could not be reached.';

  @override
  String get couldNotSignMessage => 'Could not sign message.';

  @override
  String get useDeviceLocaleTitle => 'Use device language';

  @override
  String get useDeviceLocaleDescription => 'Use device language if it is supported, otherwise default to english.';

  @override
  String get language => 'Language';

  @override
  String get authenticateToShowOtp => 'Please authenticate to show one time password.';

  @override
  String get authenticateToUnLockToken => 'Please authenticate to change the lock status of the token.';

  @override
  String get biometricRequiredTitle => 'Biometrics not setup';

  @override
  String get biometricHint => 'Authentication required';

  @override
  String get biometricNotRecognized => 'Not recognized. Try again.';

  @override
  String get biometricSuccess => 'Authentication successful';

  @override
  String get deviceCredentialsRequiredTitle => 'Device credentials not set up';

  @override
  String get deviceCredentialsSetupDescription => 'Setup device credentials in the device\'s settings';

  @override
  String get signInTitle => 'Authentication required';

  @override
  String get goToSettingsButton => 'Go to settings';

  @override
  String get goToSettingsDescription => 'Authentication by credentials or biometrics is not set up on your device. Please set it up in the device\'s settings.';

  @override
  String get lockOut => 'Biometric authentication is disabled. Please lock and unlock your screen to enable it.';

  @override
  String get authNotSupportedTitle => 'Device credentials or biometrics required';

  @override
  String get authNotSupportedBody => 'This action requires the device to be secured by credentials or biometrics.';

  @override
  String get lock => 'Lock';

  @override
  String get unlock => 'Unlock';

  @override
  String get noResultTitle => 'No tokens stored yet.';

  @override
  String get noResultText1 => 'Tap the ';

  @override
  String get noResultText2 => ' button to get started!';

  @override
  String onBoardingTitle1(Object appName) {
    return '$appName';
  }

  @override
  String get onBoardingText1 => 'Two-factor authentication\nmade easy';

  @override
  String get onBoardingTitle2 => 'Maximum Security';

  @override
  String get onBoardingText2 => 'Store tokens on your device securely\nProtected by your biometrics';

  @override
  String get onBoardingTitle3 => 'Visit us at Github';

  @override
  String get onBoardingText3 => 'This app is open source';

  @override
  String get errorLogTitle => 'Error log';

  @override
  String get logMenu => 'Log menu';

  @override
  String get showErrorLog => 'Show';

  @override
  String get clearErrorLog => 'Clear';

  @override
  String get sendErrorLog => 'Send';

  @override
  String get sendErrorLogDescription => 'A predefined email is created.\nIt contains information about the app, the error and the device.\nYou can edit the email before sending it.\nYou can see here how we use the information:';

  @override
  String get showPrivacyPolicy => 'Show privacy policy';

  @override
  String get errorLogEmpty => 'The error log is empty.';

  @override
  String get verboseLogging => 'Verbose logging';

  @override
  String get errorLogCleared => 'Error log cleared.';

  @override
  String get ok => 'Ok';

  @override
  String get errorMailBody => 'The error log file is attached.\nYou can replace this text with additional information about the error.';

  @override
  String get showDetails => 'Show details';

  @override
  String get open => 'Open';

  @override
  String get sendErrorDialogBody => 'An unexpected error occurred in the application. The information below can be send to the developers by email to help prevent this error in the future.';

  @override
  String get noFbToken => 'No Firebase token available';

  @override
  String get firebaseToken => 'Firebase Token';

  @override
  String get noPublicKey => 'No public key available';

  @override
  String get publicKey => 'Public Key';

  @override
  String get editToken => 'Edit Token';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get validFor => 'Valid for';

  @override
  String get validUntil => 'Valid until';

  @override
  String get deleteLockedToken => 'Please authenticate to delete the locked token.';

  @override
  String get editLockedToken => 'Please authenticate to edit the locked token.';

  @override
  String get uncollapseLockedFolder => 'Please authenticate to uncollapse the locked folder.';

  @override
  String get renameTokenFolder => 'Rename folder';

  @override
  String get addANewFolder => 'Create new folder';

  @override
  String get folderName => 'Foldername';

  @override
  String get retryRollout => 'Retry rollout';

  @override
  String get generatingRSAKeyPair => 'Generating RSA key pair';

  @override
  String get generatingRSAKeyPairFailed => 'Generating RSA key pair failed';

  @override
  String get sendingRSAPublicKey => 'Sending public RSA key';

  @override
  String get sendingRSAPublicKeyFailed => 'Sending public RSA key failed';

  @override
  String get parsingResponse => 'Parsing response';

  @override
  String get parsingResponseFailed => 'Parsing response failed';

  @override
  String get rolloutCompleted => 'Rollout completed';

  @override
  String get authToAcceptPushRequest => 'Please authenticate to accept the push request.';

  @override
  String get authToDeclinePushRequest => 'Please authenticate to decline the push request.';

  @override
  String get pushRequestParseError => 'Push request could not be parsed.';

  @override
  String get imageUrl => 'Image URL';

  @override
  String get errorRollOutSSLHandshakeFailed => 'SSL handshake failed. Roll-out not possible.';

  @override
  String errorWhenPullingChallenges(Object name) {
    return 'An error occured when polling for challenges of $name';
  }

  @override
  String get errorRollOutNotPossibleAnymore => 'Rolling out this Token is not possible anymore.';

  @override
  String errorTokenExpired(Object name) {
    return 'The token $name has expired.';
  }

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get butDiscardIt => 'but discard it';

  @override
  String get declineIt => 'decline it';

  @override
  String get requestTriggerdByUserQuestion => 'Was this request triggered by you?';

  @override
  String get grantCameraPermissionDialogTitle => 'Camera permission is not granted';

  @override
  String get grantCameraPermissionDialogContent => 'Please grant camera permission to scan QR codes.';

  @override
  String get grantCameraPermissionDialogPermanentlyDenied => 'Camera permission is permanently denied. Please grant camera permission in your Phone\'s settings.';

  @override
  String get grantCameraPermissionDialogButton => 'Grant permission';

  @override
  String get decryptErrorTitle => 'Decryption error';

  @override
  String get decryptErrorContent => 'Unfortunately, the app was unable to decrypt your tokens. This indicates that the encryption key is broken. You can try again or delete the app data, which would delete the tokens in the app.';

  @override
  String get decryptErrorButtonDelete => 'Delete';

  @override
  String get decryptErrorButtonSendError => 'Send error';

  @override
  String get decryptErrorButtonRetry => 'Retry';

  @override
  String get decryptErrorDeleteConfirmationContent => 'Are you sure you want to delete the app data?';

  @override
  String get hidePushTokens => 'Hide push tokens';

  @override
  String get hidePushTokensDescription => 'Hide push tokens from the token list. This will not delete the tokens and they will still be visible on a separate screen.';

  @override
  String get settingsGroupGeneral => 'General';

  @override
  String get licensesAndVersion => 'Licenses and version';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get introScanQrCode => 'You can scan QR codes to add tokens.\nWe support every common Two-Factor-Authentication token and also the privacyIDEA tokens.';

  @override
  String get introAddTokenManually => 'If you don\'t want to scan a QR code, you can also add tokens manually.';

  @override
  String get introTokenSwipe => 'Swipe tokens to the left to see available actions.';

  @override
  String get introEditToken => 'Here you can edit the token name and see some details.';

  @override
  String get introLockToken => 'To improve security even more, you can lock tokens.\nThen the token can only be used after authentication.';

  @override
  String get introDragToken => 'Reorganize your tokens by pressing it for a few seconds and then dragging it to the desired position.';

  @override
  String get introAddFolder => 'You can create folders\nto organize your tokens.';

  @override
  String get introPollForChallenges => 'You can check for new challenges by dragging down the token list.';

  @override
  String get introHidePushTokens => 'Your push tokens are hidden now.\nBut you can still see them on the push token screen.';

  @override
  String legacySigningErrorTitle(Object tokenLabel) {
    return 'An error occured while using the legacy token: $tokenLabel';
  }

  @override
  String get legacySigningErrorMessage => 'The token was enrolled in a old version of this app, which may cause trouble using it.\nIt is suggested to enroll a new push token if the problem persist!';

  @override
  String get selectImportSource => 'Select import source';

  @override
  String get importTokens => 'Import token';

  @override
  String get selectFile => 'Select file';

  @override
  String get decrypt => 'Decrypt';

  @override
  String fileNoValidBackupFor(Object name) {
    return 'The selected file is not a valid backup for $name.';
  }

  @override
  String get fileIsEncrypted => 'The selected file is encrypted. Please enter the password to decrypt it.';

  @override
  String get fileNotEncrypted => 'The selected file is not encrypted. It can be imported directly.';

  @override
  String get fileSuccessfullyDecrypted => 'The tokens have been successfully decrypted and can now be imported.';

  @override
  String get password => 'Password';

  @override
  String get wrongPassword => 'Incorrect password';

  @override
  String importExistingToken(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The file contains $count tokens that are already in the application.',
      one: 'The file contains a token that is already in the application.',
      zero: 'The file does not contain a token that is already in the application.',
    );
    return '$_temp0';
  }

  @override
  String importConflictToken(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'There is a conflict with tokens that already exist.\nPlease select which one you would like to keep.',
      one: 'There is a conflict with tokens that already exist.\nPlease select which one you would like to keep.',
      zero: 'There is no conflict with tokens that already exist.',
    );
    return '$_temp0';
  }

  @override
  String importNewToken(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The file contains $count new tokens that will be imported.',
      one: 'The file contains a new token that will be imported.',
      zero: 'The file does not contain a new token.',
    );
    return '$_temp0';
  }

  @override
  String get importHint2FAS => 'Select your 2FAS backup. If you don\'t have a backup, create one in the 2FAS app.\nWe recommend using a password.';

  @override
  String get importHint2FASButton => 'Select 2FAS Backup';
}
