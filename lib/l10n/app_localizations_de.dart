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
  String get secretKey => 'Geheimer Schlüssel';

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
  String errorRollOutFailed(Object name) {
    return 'Ausrollen von $name ist fehlgeschlagen.';
  }

  @override
  String statusCode(Object statusCode) {
    return 'Statuscode: $statusCode';
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
  String get pollingFailed => 'Abfrage fehlgeschlagen.';

  @override
  String pollingFailedFor(Object serial) {
    return 'Abfrage für $serial fehlgeschlagen.';
  }

  @override
  String get noNetworkConnection => 'Keine Netzwerkverbindung.';

  @override
  String get connectionFailed => 'Verbindung fehlgeschlagen.';

  @override
  String get checkYourNetwork => 'Bitte überprüfen Sie Ihre Netzwerkverbindung und versuchen Sie es erneut.';

  @override
  String get serverNotReachable => 'Der Server konnte nicht erreicht werden.';

  @override
  String get couldNotSignMessage => 'Nachricht konnte nicht signiert werden.';

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
  String onBoardingTitle1(Object appName) {
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
  String get enableVerboseLogging => 'Enable verbose logging';

  @override
  String get logMenu => 'Protokollmenü';

  @override
  String get sendErrorDialogHeader => 'Send via e-mail';

  @override
  String get sendErrorLog => 'Fehlerbericht senden';

  @override
  String get sendErrorLogDescription => 'Es wird eine vorgefertigte E-Mail erstellt.\nSie enthält Informationen über die App, den Fehler und das Gerät.\nSie können die E-Mail vor dem Senden bearbeiten.';

  @override
  String get showPrivacyPolicy => 'Datenschutzerklärung anzeigen';

  @override
  String get errorLogEmpty => 'Das Fehlerprotokoll ist leer.';

  @override
  String get verboseLogging => 'Ausführlich protokollieren';

  @override
  String get errorLogCleared => 'Fehlerprotokolle gelöscht';

  @override
  String get ok => 'Ok';

  @override
  String get noLogToSend => 'There is log to send.';

  @override
  String get errorMailBody => 'Die Fehlerprotokolldatei ist angehängt.\nSie können diesen Text durch zusätzliche Informationen über den Fehler ersetzen.';

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
  String get pushRequestParseError => 'Die Push-Anfrage konnte nicht verarbeitet werden.';

  @override
  String get imageUrl => 'Bild URL';

  @override
  String get errorRollOutSSLHandshakeFailed => 'SSL-Handshake fehlgeschlagen. Roll-out nicht möglich.';

  @override
  String errorWhenPullingChallenges(Object name) {
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
  String get grantCameraPermissionDialogTitle => 'Kamera-Berechtigung erforderlich';

  @override
  String get grantCameraPermissionDialogContent => 'Um QR-Codes zu scannen, benötigt die App Zugriff auf die Kamera.';

  @override
  String get grantCameraPermissionDialogPermanentlyDenied => 'Sie haben die Berechtigung für den Kamerazugriff permanent verweigert. Bitte aktivieren Sie die Berechtigung in den Einstellungen ihres Smartphones.';

  @override
  String get grantCameraPermissionDialogButton => 'Berechtigung erteilen';

  @override
  String get decryptErrorTitle => 'Entschlüsselung fehlgeschlagen';

  @override
  String get decryptErrorContent => 'Leider konnten Ihre Token nicht entschlüsselt werden. Das deutet darauf hin, dass der Verschlüsselungsschlüssel nicht mehr verfügbar ist. Sie können es erneut versuchen oder die App Daten löschen. Dabei werden alle Token aus der App geschlöscht.';

  @override
  String get decryptErrorButtonDelete => 'Löschen.';

  @override
  String get decryptErrorButtonSendError => 'Fehler senden';

  @override
  String get decryptErrorButtonRetry => 'Wiederholen';

  @override
  String get decryptErrorDeleteConfirmationContent => 'Sind Sie sicher, dass Sie die App Daten löschen möchten?';

  @override
  String get hidePushTokens => 'Push-Token ausblenden';

  @override
  String get hidePushTokensDescription => 'Push-Token aus der Token-Liste ausblenden. Dadurch werden die Token nicht gelöscht und sind weiterhin auf einem separaten Bildschirm sichtbar.';

  @override
  String get settingsGroupGeneral => 'Allgemeines';

  @override
  String get licensesAndVersion => 'Lizenzen und Version';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';
}
