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
  String get errorLogTitle => 'Error logs';

  @override
  String get sendErrorHint => 'Send us the error log via e-mail';

  @override
  String get enableVerboseLogging => 'Enable verbose logging';

  @override
  String get clearErrorLogHint => 'Clears the local error log file';

  @override
  String get logMenu => 'Log menu';

  @override
  String get sendErrorDialogHeader => 'Send via e-mail';

  @override
  String get ok => 'Ok';

  @override
  String get noLogToSend => 'There is log to send.';

  @override
  String get errorMailBody => 'The error log file is attached.\nYou can replace this text with additional information about the error.';

  @override
  String get errorLogCleared => 'Error logs cleared.';

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
  String get incomingAuthRequestError => 'The message didn\'t provided the needed data or the data was malformed.';

  @override
  String get imageUrl => 'Image URL';

  @override
  String get errorRollOutSSLHandshakeFailed => 'SSL handshake failed. Roll-out not possible.';

  @override
  String errorWhenPullingChallenges(Object name) {
    return 'An error occured when polling for challenges of $name';
  }

  @override
  String errorRollOutTokenExpired(Object name) {
    return 'Rolling out this Token is not possible anymore.\nThe token $name has expired.';
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
  String get licensesAndVersion => 'Licenses and version';
}
