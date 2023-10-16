import 'app_localizations.dart';

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get accept => 'Accepteren';

  @override
  String get decline => 'Weigeren';

  @override
  String get name => 'Naam';

  @override
  String get secret => 'Geheim';

  @override
  String get encoding => 'Codering';

  @override
  String get algorithm => 'Algoritme';

  @override
  String get digits => 'Cijfers';

  @override
  String get type => 'Type';

  @override
  String get period => 'Duur';

  @override
  String get rename => 'Wijzigen';

  @override
  String get cancel => 'Annuleren';

  @override
  String get delete => 'Verwijderen';

  @override
  String get dismiss => 'Sluiten';

  @override
  String get addToken => 'Token toevoegen';

  @override
  String get scanQrCode => 'Scan QR-Code';

  @override
  String get enterDetailsForToken => 'Voer informatie over token in';

  @override
  String get pleaseEnterANameForThisToken => 'Voer de naam in voor deze token.';

  @override
  String get pleaseEnterASecretForThisToken => 'Voer de geheime sleutel in voor deze token.';

  @override
  String get theSecretDoesNotFitTheCurrentEncoding => 'De geheime sleutel past niet bij de huidige codering';

  @override
  String get renameToken => 'Hernoem token';

  @override
  String get confirmDeletion => 'Bevestig verwijderen';

  @override
  String confirmDeletionOf(Object name) {
    return 'Weet u zeker dat u $name wilt verwijderen?';
  }

  @override
  String get generatingPhonePart => 'Genereren telefoon gedeelte';

  @override
  String get phonePart => 'Telefoon gedeelte:';

  @override
  String otpValueCopiedMessage(Object otpValue) {
    return 'Wachtwoord \"$otpValue\" gekopieerd naar het klembord.';
  }

  @override
  String get settings => 'Instellingen';

  @override
  String get pushToken => 'Push Token';

  @override
  String get theme => 'Thema';

  @override
  String get lightTheme => 'Licht';

  @override
  String get darkTheme => 'Donker';

  @override
  String get systemTheme => 'Gebruik thema van het apparaat';

  @override
  String get enablePolling => 'Zoeken aanzetten';

  @override
  String get requestPushChallengesPeriodically => 'Activeer het zoeken naar berichten. Gebruik deze optie wanneer de push berichten niet worden ontvangen.';

  @override
  String get synchronizePushTokens => 'Synchroniseer push tokens';

  @override
  String get synchronizesTokensWithServer => 'Synchroniseert tokens met de privacyIDEA server.';

  @override
  String get sync => 'Synchroniseer';

  @override
  String get synchronizingTokens => 'Tokens synchroniseren.';

  @override
  String get allTokensSynchronized => 'Alle tokens zijn gesynchroniseerd.';

  @override
  String get synchronizationFailed => 'Synchroniseren mislukt voor de volgende tokens, probeer het opnieuw:';

  @override
  String get tokensDoNotSupportSynchronization => 'Voor de volgende tokens wordt synchroniseren niet ondersteunt, ze moeten opnieuw worden aangeleverd:';

  @override
  String errorRollOutFailed(Object name, Object errorCode) {
    return 'Uitrollen van token $name mislukt. Fout code: $errorCode';
  }

  @override
  String get errorSynchronizationNoNetworkConnection => 'Token synchroniseren mislukt, privacyIDEA server kan niet worden bereikt.';

  @override
  String errorRollOutNoConnectionToServer(Object name) {
    return 'Uitrollen mislukt. Geen verbinding met de server.';
  }

  @override
  String errorRollOutUnknownError(Object e) {
    return 'Een onbekende fout heeft plaats gevonden. Uitrollen is niet mogelijk: $e';
  }

  @override
  String get rollingOut => 'Uitrollen';

  @override
  String get pollingChallenges => 'Zoeken naar nieuwe aanvragen';

  @override
  String get unexpectedError => 'Er is een onverwachte fout opgetreden.';

  @override
  String get pollingFailNoNetworkConnection => 'Zoeken naar berichten mislukt. Server kan niet worden bereikt.';

  @override
  String get useDeviceLocaleTitle => 'Gebruik de taal van het apparaat';

  @override
  String get useDeviceLocaleDescription => 'Gebruik de taal van het apparaat wanneer het wordt ondersteund, val anders terug op Engels.';

  @override
  String get language => 'Taal';

  @override
  String get authenticateToShowOtp => 'Authenticeer om het eenmalige wachtwoord te tonen.';

  @override
  String get authenticateToUnLockToken => 'Authenticeer om de vergrendeling van de token te wijzigen.';

  @override
  String get biometricRequiredTitle => 'Biometrie is niet ingesteld';

  @override
  String get biometricHint => 'Authenticatie vereist';

  @override
  String get biometricNotRecognized => 'Niet herkend. Probeer opnieuw.';

  @override
  String get biometricSuccess => 'Authenticatie geslaagd';

  @override
  String get deviceCredentialsRequiredTitle => 'Inloggevens van het apparaat zijn niet ingesteld';

  @override
  String get deviceCredentialsSetupDescription => 'Stel de inloggegevens in, bij de instellingen van het apparaat';

  @override
  String get signInTitle => 'Authenticatie vereist';

  @override
  String get goToSettingsButton => 'Ga naar instellingen';

  @override
  String get goToSettingsDescription => 'Authenticatie via inloggegevens of biometrie is niet ingesteld. Stel het in bij de instellingen van het apparaat.';

  @override
  String get lockOut => 'Biometrische authenticatie staat uit. Vergrendel en ontgrendel het scherm om het aan te zetten.';

  @override
  String get authNotSupportedTitle => 'Apparaat inloggevens of biometrie is vereist';

  @override
  String get authNotSupportedBody => 'Deze actie vereist dat het apparaat is beveiligd met inlogggevens of biometrie.';

  @override
  String get lock => 'Vergrendel';

  @override
  String get unlock => 'Ontgrendel';

  @override
  String get noResultTitle => 'Nog geen token opgeslagen.';

  @override
  String get noResultText1 => 'Tik op ';

  @override
  String get noResultText2 => ' de knop om te beginnen!';

  @override
  String onBoardingTitle1(String appName) {
    return '$appName';
  }

  @override
  String get onBoardingText1 => 'Twee-factoren authenticatie\nmakkelijk gemaakt';

  @override
  String get onBoardingTitle2 => 'Maximale Beveiliging';

  @override
  String get onBoardingText2 => 'Bewaar tokens op uw apparaat\nbeveiligd door uw biometrische gegevens';

  @override
  String get onBoardingTitle3 => 'Bezoek ons op Github';

  @override
  String get onBoardingText3 => 'Deze app is open source';

  @override
  String get errorLogTitle => 'Foutlogs';

  @override
  String get sendErrorHint => 'Stuur ons de error log via e-mail';

  @override
  String get enableVerboseLogging => 'Uitgebreide logboekregistratie inschakelen';

  @override
  String get clearErrorLogHint => 'Wist het lokale foutenlogbestand';

  @override
  String get logMenu => 'Logmenu';

  @override
  String get sendErrorDialogHeader => 'Verzenden via e-mail';

  @override
  String get ok => 'Ok';

  @override
  String get noLogToSend => 'Er is een log om te verzenden.';

  @override
  String get errorLogFileAttached => 'Het foutlogbestand is bijgevoegd.';

  @override
  String get errorLogCleared => 'Foutlogs gewist';

  @override
  String get showDetails => 'Details tonen';

  @override
  String get open => 'Openen';

  @override
  String get sendErrorDialogBody => 'Een onverwachte fout heeft plaatsgevonden in de applicatie. De onderstaande informatie kan worden verstuurd naar de ontwikkelaars via e-mail om het probleem in de toekomst te voorkomen.';

  @override
  String get noFbToken => 'Geen Firebase Token beschikbaar';

  @override
  String get firebaseToken => 'Firebase Token';

  @override
  String get noPublicKey => 'Geen openbare sleutel beschikbaar';

  @override
  String get publicKey => 'Openbare sleutel';

  @override
  String get editToken => 'Token bewerken';

  @override
  String get edit => 'Bewerken';

  @override
  String get save => 'Opslaan';

  @override
  String get validFor => 'Geldig voor';

  @override
  String get validUntil => 'Geldig tot';

  @override
  String get deleteLockedToken => 'Verifieer om het vergrendelde token te verwijderen.';

  @override
  String get editLockedToken => 'Verifieer om het vergrendelde token te bewerken.';

  @override
  String get uncollapseLockedFolder => 'Verifieer om de vergrendelde map te openen.';

  @override
  String get renameTokenFolder => 'Map hernoemen';

  @override
  String get addANewFolder => 'Nieuwe map maken';

  @override
  String get folderName => 'Mapnaam';

  @override
  String get retryRollout => 'Opnieuw uitrollen';

  @override
  String get generatingRSAKeyPair => 'Genereren RSA sleutelpaar';

  @override
  String get generatingRSAKeyPairFailed => 'Genereren RSA sleutelpaar mislukt';

  @override
  String get sendingRSAPublicKey => 'Versturen van de openbare RSA sleutel';

  @override
  String get sendingRSAPublicKeyFailed => 'Versturen van de openbare RSA sleutel mislukt';

  @override
  String get parsingResponse => 'Antwoord analyseren';

  @override
  String get parsingResponseFailed => 'Antwoord analyseren mislukt';

  @override
  String get rolloutCompleted => 'Uitrollen voltooid';

  @override
  String get authToAcceptPushRequest => 'Authenticeer om de push aanvraag te accepteren.';

  @override
  String get authToDeclinePushRequest => 'Authenticeer om de push aanvraag te weigeren.';

  @override
  String get incomingAuthRequestError => 'Het bericht bevatte niet de benodigde gegevens of de gegevens waren misvormd.';

  @override
  String get imageUrl => 'Afbeeldings-URL';

  @override
  String get errorRollOutSSLHandshakeFailed => 'SSL-handdruk mislukt. Uitrollen niet mogelijk.';

  @override
  String errorWhenPullingChallenges(String name) {
    return 'Er is een fout opgetreden bij het zoeken naar uitdagingen van $name';
  }

  @override
  String errorRollOutTokenExpired(Object name) {
    return 'Het uitrollen van dit token is niet meer mogelijk.\nHet token $name is verlopen.';
  }

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nee';

  @override
  String get butDiscardIt => 'maar verwijder';

  @override
  String get declineIt => 'weigeren';

  @override
  String get requestTriggerdByUserQuestion => 'Is dit verzoek door jou gedaan?';

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
  String get decryptErrorContent => 'An error occurred while decrypting the tokens. Please try again.\nIf the error persists, you have to delete the corupted data';

  @override
  String get decryptErrorButton => 'Delete all Tokens';

  @override
  String get decryptErrorDeleteConfirmationContent => 'Are you sure you want to delete all tokens?';

  @override
  String get hidePushTokens => 'Hide push tokens';

  @override
  String get hidePushTokensDescription => 'Hide push tokens from the token list. This will not delete the tokens and they will still be visible on a separate screen.';
}
