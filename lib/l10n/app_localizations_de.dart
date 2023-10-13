import 'app_localizations.dart';

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get accept => 'Akzeptieren';

  @override
  String get decline => 'Ablehnen';

  @override
  String get name => 'Name';

  @override
  String get secret => 'Geheimnis';

  @override
  String get encoding => 'Kodierung';

  @override
  String get algorithm => 'Algorithmus';

  @override
  String get digits => 'Ziffern';

  @override
  String get type => 'Art';

  @override
  String get period => 'Periode';

  @override
  String get rename => 'Umbenennen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get dismiss => 'Schließen';

  @override
  String get addToken => 'Token hinzufügen';

  @override
  String get scanQrCode => 'QR-Code scannen';

  @override
  String get enterDetailsForToken => 'Neuen Token konfigurieren';

  @override
  String get pleaseEnterANameForThisToken => 'Bitte geben Sie einen Namen ein.';

  @override
  String get pleaseEnterASecretForThisToken => 'Bitte geben Sie ein Geheimnis ein.';

  @override
  String get theSecretDoesNotFitTheCurrentEncoding => 'Das Geheimnis entspricht nicht der gewählten Verschlüsselung.';

  @override
  String get renameToken => 'Token umbenennen';

  @override
  String get confirmDeletion => 'Löschen bestätigen';

  @override
  String confirmDeletionOf(Object name) {
    return 'Bestätigen Sie das Löschen von $name?';
  }

  @override
  String get generatingPhonePart => 'Generiere Telefonanteil';

  @override
  String get phonePart => 'Telefonanteil:';

  @override
  String otpValueCopiedMessage(Object otpValue) {
    return 'Passwort \"$otpValue\" wurde in Zwischenablage kopiert.';
  }

  @override
  String get settings => 'Einstellungen';

  @override
  String get pushToken => 'Push Token';

  @override
  String get theme => 'Farbschema';

  @override
  String get lightTheme => 'Hell';

  @override
  String get darkTheme => 'Dunkel';

  @override
  String get systemTheme => 'Nutze Farbschema des Geräts';

  @override
  String get enablePolling => 'Aktives Stellen von Push-Anfragen';

  @override
  String get requestPushChallengesPeriodically => 'Fordert regelmäßig Push-Anfragen vom Server an. Aktivieren Sie diese Funktion, wenn Nachrichten ansonsten nicht erhalten werden.';

  @override
  String get synchronizePushTokens => 'Synchronisiere Push Token';

  @override
  String get synchronizesTokensWithServer => 'Synchronisiert Token mit dem privacyIDEA Server.';

  @override
  String get sync => 'Sync';

  @override
  String get synchronizingTokens => 'Synchronisiere Token.';

  @override
  String get allTokensSynchronized => 'Alle Token wurden synchronisiert.';

  @override
  String get synchronizationFailed => 'Synchronisation ist für die folgenden Token fehlgeschlagen:';

  @override
  String get tokensDoNotSupportSynchronization => 'Die folgenden Token unterstützen keine Synchronisation und müssen erneut ausgerollt werden:';

  @override
  String errorRollOutFailed(Object name, Object errorCode) {
    return 'Ausrollen von $name ist fehlgeschlagen. Fehlercode: $errorCode';
  }

  @override
  String get errorSynchronizationNoNetworkConnection => 'Die Synchronisation ist fehlgeschlagen, da der privacyIDEA Server nicht erreicht werden konnte.';

  @override
  String errorRollOutNoConnectionToServer(Object name) {
    return 'Der Rollout von Token $name ist fehlgeschlagen, der Server konnte nicht erreicht werden.';
  }

  @override
  String errorRollOutUnknownError(Object e) {
    return 'Ein unbekannter Fehler ist aufgetreten. Aurollen nicht möglich: $e';
  }

  @override
  String get rollingOut => 'Ausrollen';

  @override
  String get pollingChallenges => 'Frage ausstehende Authentifizierungsanfragen ab';

  @override
  String get unexpectedError => 'Ein unerwarteter Fehler ist aufgetreten.';

  @override
  String get pollingFailNoNetworkConnection => 'Abfrage fehlgeschlagen, der Server ist nicht erreichbar.';

  @override
  String get useDeviceLocaleTitle => 'Nutze Systemsprache';

  @override
  String get useDeviceLocaleDescription => 'Nutze Systemsprache, falls diese unterstützt wird. Anderenfalls nutze Englisch. ';

  @override
  String get language => 'Sprache';

  @override
  String get authenticateToShowOtp => 'Bitte authentifizieren Sie sich, um das Einmalpasswort anzuzeigen.';

  @override
  String get authenticateToUnLockToken => 'Bitte authentifizieren Sie sich, um den Sperrstatus des Tokens zu ändern.';

  @override
  String get biometricRequiredTitle => 'Biometrie ist nicht eingerichtet';

  @override
  String get biometricHint => 'Authentifizierung wird benötigt';

  @override
  String get biometricNotRecognized => 'Biometrie wurde nicht erkannt, bitte versuchen Sie es erneut';

  @override
  String get biometricSuccess => 'Authentifizierung erfolgreich';

  @override
  String get deviceCredentialsRequiredTitle => 'Gerätepasswort ist nicht eingerichtet';

  @override
  String get deviceCredentialsSetupDescription => 'Setzen Sie bitte ein Gerätepasswort in den Einstellungen';

  @override
  String get signInTitle => 'Authentifizierung wird benötigt';

  @override
  String get goToSettingsButton => 'Gehe zu Einstellungen';

  @override
  String get goToSettingsDescription => 'Authentifizierung durch Gerätepasswort oder Biometrie ist nicht eingerichtet. Bitte aktivieren Sie dies in den Geräteeinstellungen.';

  @override
  String get lockOut => 'Biometrie ist deaktiviert. Bitte sperren und entsperren Sie Ihren Bildschirm um diese zu aktivieren.';

  @override
  String get authNotSupportedTitle => 'Gerätepasswort oder Biometrie wird benötigt';

  @override
  String get authNotSupportedBody => 'Diese Aktion erfordert, dass auf dem Gerät ein Passwort oder Biometrie eingerichtet ist.';

  @override
  String get lock => 'Sperren';

  @override
  String get unlock => 'Entsperren';

  @override
  String get noResultTitle => 'Keine Token vorhanden.';

  @override
  String get noResultText1 => 'Tippe auf das ';

  @override
  String get noResultText2 => ' Icon um loszulegen!';

  @override
  String onBoardingTitle1(String appName) {
    return '$appName';
  }

  @override
  String get onBoardingText1 => 'Zwei-Faktor-Authentifizierung\neinfach gemacht';

  @override
  String get onBoardingTitle2 => 'Maximale Sicherheit';

  @override
  String get onBoardingText2 => 'Speichern Sie Ihre Token sicher auf diesem Gerät\nGeschützt durch Ihre biometrischen Daten';

  @override
  String get onBoardingTitle3 => 'Besuchen Sie uns auf Github';

  @override
  String get onBoardingText3 => 'Diese App ist Open Source';

  @override
  String get errorLogTitle => 'Fehlerprotokolle';

  @override
  String get sendErrorHint => 'Senden Sie uns das Fehlerprotokoll per E-Mail';

  @override
  String get enableVerboseLogging => 'Fehler ausführlich protokollieren';

  @override
  String get clearErrorLogHint => 'Löscht die lokale Fehlerprotokolldatei';

  @override
  String get logMenu => 'Protokollmenu';

  @override
  String get sendErrorDialogHeader => 'Per E-Mail senden';

  @override
  String get ok => 'Ok';

  @override
  String get noLogToSend => 'Es gibt kein Protokoll zu senden.';

  @override
  String get errorLogFileAttached => 'Die Fehlerprotokolldatei ist angehängt.';

  @override
  String get errorLogCleared => 'Fehlerprotokolle gelöscht';

  @override
  String get showDetails => 'Details anzeigen';

  @override
  String get open => 'Öffnen';

  @override
  String get sendErrorDialogBody => 'Ein unbekannter Fehler ist aufgetreten. Die unten gezeigten Informationen können den Entwicklern per E-Mail zugesendet werden, um zu helfen, diesen Fehler in Zukunft zu vermeiden.';

  @override
  String get noFbToken => 'Kein Firebase Token vorhanden';

  @override
  String get firebaseToken => 'Firebase Token';

  @override
  String get noPublicKey => 'Kein öffentlicher Schlüssel vorhanden';

  @override
  String get publicKey => 'Öffentlicher Schlüssel';

  @override
  String get editToken => 'Token bearbeiten';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get validFor => 'Gültig für';

  @override
  String get validUntil => 'Gültig bis';

  @override
  String get deleteLockedToken => 'Bitte authentifizieren Sie sich, um den gesperrten Token zu löschen.';

  @override
  String get editLockedToken => 'Bitte authentifizieren Sie sich, um den gesperrten Token zu bearbeiten.';

  @override
  String get uncollapseLockedFolder => 'Bitte authentifizieren Sie sich, um den gesperrten Ordner zu öffnen.';

  @override
  String get renameTokenFolder => 'Ordner umbenennen';

  @override
  String get addANewFolder => 'Neuen Ordner anlegen';

  @override
  String get folderName => 'Ordnername';

  @override
  String get retryRollout => 'Erneut ausrollen';

  @override
  String get generatingRSAKeyPair => 'Generiere RSA Schlüsselpaar';

  @override
  String get generatingRSAKeyPairFailed => 'Generieren des RSA Schlüsselpaars fehlgeschlagen';

  @override
  String get sendingRSAPublicKey => 'Sende öffentlichen RSA Schlüssel';

  @override
  String get sendingRSAPublicKeyFailed => 'Senden des öffentlichen RSA Schlüssels fehlgeschlagen';

  @override
  String get parsingResponse => 'Analysiere Antwort';

  @override
  String get parsingResponseFailed => 'Analysieren der Antwort fehlgeschlagen';

  @override
  String get rolloutCompleted => 'Ausrollen abgeschlossen';

  @override
  String get authToAcceptPushRequest => 'Bitte authentifizieren Sie sich, um die Anfrage anzunehmen.';

  @override
  String get authToDeclinePushRequest => 'Bitte authentifizieren Sie sich, um die Anfrage abzulehnen.';

  @override
  String get incomingAuthRequestError => 'Die Nachricht enthielt nicht die erforderlichen Daten oder die Daten waren falsch formatiert.';

  @override
  String get imageUrl => 'Bild URL';

  @override
  String get errorRollOutSSLHandshakeFailed => 'SSL-Handshake fehlgeschlagen. Roll-out nicht möglich.';

  @override
  String errorWhenPullingChallenges(String name) {
    return 'Fehler beim Abrufen der Authentifizierungsanfragen von $name';
  }

  @override
  String errorRollOutTokenExpired(Object name) {
    return 'Das Ausrollen dieses Tokens ist nicht mehr möglich.\nDer Token $name ist abgelaufen.';
  }

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get butDiscardIt => 'aber verwerfen';

  @override
  String get declineIt => 'ablehnen';

  @override
  String get requestTriggerdByUserQuestion => 'Wurde diese Anfrage von Ihnen ausgelöst?';

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
}
