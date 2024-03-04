import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get patchNotesNewFeatures => 'Neue Funktionen';

  @override
  String get patchNotesImprovements => 'Verbesserungen';

  @override
  String get patchNotesBugFixes => 'Fehlerbehebungen';

  @override
  String get patchNotesV4_3_0NewFeatures1 => 'Unterstützung für den Import von Token von Google, Aegis und 2FAS Authenticator hinzugefügt. Weitere Importquellen werden in Zukunft hinzugefügt.';

  @override
  String get patchNotesV4_3_0NewFeatures2 => 'Feedback-Option zu den Einstellungen hinzugefügt.';

  @override
  String get patchNotesV4_3_0NewFeatures3 => 'Push-Tokens können jetzt aus der Token-Liste ausgeblendet werden.';

  @override
  String get patchNotesV4_3_0NewFeatures4 => 'Es wurden Einführungen hinzugefügt, um neuen Benutzern den Einstieg zu erleichtern.';

  @override
  String get patchNotesV4_3_0NewFeatures5 => 'Sie können jetzt nach Token suchen, indem Sie auf die Lupe in der oberen rechten Ecke tippen.';

  @override
  String get patchNotesV4_3_0NewFeatures6 => 'Ab Android 12 kann für einen Token ein Widget auf dem Homescreen erstellt werden.';

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
    return 'Sind Sie sicher dass Sie $name löschen möchten?';
  }

  @override
  String get confirmTokenDeletionHint => 'Unter Umständen können Sie sich nicht mehr einloggen, wenn Sie diesen Token löschen.\nBitte stellen Sie sicher, dass Sie sich ohne diesen Token in den dazugehörigen Account einloggen können.';

  @override
  String get confirmFolderDeletionHint => 'Das Löschen eines Ordners hat keine Auswirkungen auf die Token, die sich darin befinden.\nDie Token werden in die Hauptliste verschoben.';

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
  String get errorLogTitle => 'Fehlerprotokoll';

  @override
  String get logMenu => 'Log-Menü';

  @override
  String get showErrorLog => 'Anzeigen';

  @override
  String get clearErrorLog => 'Löschen';

  @override
  String get send => 'Senden';

  @override
  String get sendErrorLogDescription => 'Es wird eine vorgefertigte E-Mail erstellt.\nSie enthält Informationen über die App, den Fehler und das Gerät.\nSie können die E-Mail vor dem Senden bearbeiten.\nWie wir die Informationen verwenden, sehen Sie hier:';

  @override
  String get showPrivacyPolicy => 'Datenschutzerklärung anzeigen';

  @override
  String get errorLogEmpty => 'Das Fehlerprotokoll ist leer.';

  @override
  String get verboseLogging => 'Ausführliche Protokollierung';

  @override
  String get errorLogCleared => 'Fehlerprotokoll gelöscht.';

  @override
  String get ok => 'Ok';

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
  String get create => 'Erstellen';

  @override
  String get validFor => 'Gültig für';

  @override
  String get validUntil => 'Gültig bis';

  @override
  String get deleteLockedToken => 'Bitte authentifizieren Sie sich, um den gesperrten Token zu löschen.';

  @override
  String get editLockedToken => 'Bitte authentifizieren Sie sich, um den gesperrten Token zu bearbeiten.';

  @override
  String get expandLockedFolder => 'Bitte authentifizieren Sie sich, um den gesperrten Ordner zu öffnen.';

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
  String get errorRollOutNotPossibleAnymore => 'Das Ausrollen dieses Tokens ist nicht mehr möglich.';

  @override
  String errorTokenExpired(Object name) {
    return 'Der Token $name ist abgelaufen.';
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

  @override
  String get introScanQrCode => 'Sie können QR-Codes scannen, um Token hinzuzufügen.\nWir unterstützen alle gängigen Two-Factor-Authentication Token und auch die privacyIDEA Token.';

  @override
  String get introAddTokenManually => 'Wenn Sie keinen QR-Code scannen möchten, können Sie Token auch manuell hinzufügen.';

  @override
  String get introTokenSwipe => 'Wischen Sie Token nach links, um die verfügbaren Aktionen zu sehen.';

  @override
  String get introEditToken => 'Hier können Sie den Namen des Tokens bearbeiten und einige Details einsehen.';

  @override
  String get introLockToken => 'Um die Sicherheit noch weiter zu erhöhen, können Sie Token sperren.\nDer Token kann dann erst nach der Authentifizierung verwendet werden.';

  @override
  String get introDragToken => 'Reorganisieren Sie Ihre Token, indem Sie sie einige Sekunden lang drücken und dann an die gewünschte Position ziehen.';

  @override
  String get introAddFolder => 'Sie können Ordner erstellen, um Ihre Token zu organisieren.';

  @override
  String get introPollForChallenges => 'Sie können neue Push-Anmeldungen abfragen, indem Sie die Liste der Token nach unten ziehen.';

  @override
  String get introHidePushTokens => 'Deine Push-Token sind jetzt versteckt.\nAber du kannst sie immer noch auf dem Bildschirm mit den Push-Token sehen.';

  @override
  String legacySigningErrorTitle(Object tokenLabel) {
    return 'Bei der Verwendung des veralteten Tokens ist ein Fehler aufgetreten: $tokenLabel';
  }

  @override
  String get legacySigningErrorMessage => 'Der Token wurde in einer veralteten Version der App erstellt, was zu Problemen bei der Verwendung führen kann. Es wird empfohlen, einen neuen Push-Token zu erstellen, wenn das Problem weiterhin besteht!';

  @override
  String get selectImportSource => 'Importquelle auswählen';

  @override
  String get selectImportType => 'Wie wollen Sie die Token importieren?';

  @override
  String get importTokens => 'Token importieren';

  @override
  String get selectFile => 'Datei auswählen';

  @override
  String get decrypt => 'Entschlüsseln';

  @override
  String get tokensAreEncrypted => 'Die Token sind verschlüsselt. Bitte gib das Passwort ein, um sie zu entschlüsseln.';

  @override
  String get tokensNotEncrypted => 'Die Token sind unverschlüsselt und können direkt importiert werden.';

  @override
  String get tokensSuccessfullyDecrypted => 'Die Token wurden erfolgreich entschlüsselt, sie können nun importiert werden.';

  @override
  String get password => 'Passwort';

  @override
  String get wrongPassword => 'Falsches Passwort';

  @override
  String get qrScan => 'Scannen';

  @override
  String get enterLink => 'Link eingeben';

  @override
  String invalidBackupFile(Object appName) {
    return 'Die ausgewählte Datei ist kein gültiges Backup von $appName.';
  }

  @override
  String invalidQrScan(Object appName) {
    return 'Der gescannte QR-Code ist kein gültiges Backup von $appName.';
  }

  @override
  String invalidQrFile(Object appName) {
    return 'Die ausgewählte Datei enthällt kein gültigen QR-Code von $appName.';
  }

  @override
  String invalidLink(Object appName) {
    return 'Der eingegebene Link ist kein gültiger Token von $appName, oder er wird nicht unterstützt.';
  }

  @override
  String importExistingToken(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Es wurden $count Token gefunden, die sich bereits in der Anwendung befinden.',
      one: 'Es wurde ein Token gefunden, das sich bereits in der Anwendung befindet.',
      zero: 'Es wurde kein Token gefunden, das sich bereits in der App befindet.',
    );
    return '$_temp0';
  }

  @override
  String importConflictToken(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Es besteht ein Konflikt mit bereits existierenden Token.\nBitte wählen Sie aus, welches Sie behalten möchten.',
      one: 'Es besteht ein Konflikt mit bereits existierenden Token.\nBitte wählen Sie aus, welches Sie behalten möchten.',
      zero: 'Es besteht kein Konflikt mit bereits existierenden Token.',
    );
    return '$_temp0';
  }

  @override
  String importNewToken(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Es wurden $count neue Token gefunden, die importiert werden.',
      one: 'Es wurde ein neues Token gefunden, das importiert wird.',
      zero: 'Es wurde kein neues Token gefunden.',
    );
    return '$_temp0';
  }

  @override
  String get importHint2FAS => 'Wählen Sie das 2FAS-Backup aus.\nFalls Sie kein Backup haben, erstellen Sie eins in der 2FAS-App. Wir empfehlen die Verwendung eines Passworts.';

  @override
  String get importHintAegisBackupFile => 'Wähle dein Aegis-Export (.json) aus.\nWenn Sie keinen Export haben, erstellen Sie bitte eins über das Einstellungen Menu in der Aegis-App. Wir empfehlen die Verwendung eines Passworts.';

  @override
  String get importHintAegisQrScan => 'Scannen Sie den QR-Code, den Sie erhalten, wenn Sie Einträge aus Aegis übertragen.';

  @override
  String get importHintAegisLink => 'Geben Sie den Link ein, den Sie erhalten, wenn Sie Einträge aus Aegis übertragen.';

  @override
  String get importHintGoogleQrScan => 'Scannen Sie den QR-Code, den Sie erhalten, wenn Sie Ihre Konten aus Google Authenticator exportieren.';

  @override
  String get importHintGoogleQrFile => 'Wählen Sie eine Bilddatei mit dem QR-Code, den Sie erhalten, wenn Sie Ihre Konten aus dem Google Authenticator exportieren.\n!! Der QR-Code enthält die Token in unverschlüsselter Form. Es ist deshalb nicht sicher, diesen länger als nötig aufzubewahren !!';

  @override
  String get qrFileDecodeError => 'Es war nicht möglich, den QR-Code aus dem ausgewählten Bild zu dekodieren. Bitte verwenden Sie stattdessen den QR-Code-Scanner.';

  @override
  String get tokenLink => 'Token Link';

  @override
  String get feedback => 'Feedback';

  @override
  String get feedbackTitle => 'Ihr Feedback ist immer willkommen!';

  @override
  String get feedbackDescription => 'Wenn Sie Fragen, Anregungen oder Probleme haben, lassen Sie es uns wissen.';

  @override
  String get feedbackHint => 'Es öffnet sich eine vorgefertigte E-Mail, die Sie an uns senden können. Falls gewünscht, werden Informationen über Ihr Gerät und die Version der Anwendung hinzugefügt. Vor dem Versenden können Sie die E-Mail überprüfen und bearbeiten.';

  @override
  String get feedbackPrivacyPolicy1 => 'Mit dem Senden des Feedbacks stimmen Sie unserer ';

  @override
  String get feedbackPrivacyPolicy2 => 'Datenschutzerklärung';

  @override
  String get feedbackPrivacyPolicy3 => ' zu.';

  @override
  String get addSystemInfo => 'Systeminfos hinzufügen';

  @override
  String get feedbackSentTitle => 'Feedback gesendet';

  @override
  String get feedbackSentDescription => 'Vielen Dank für Ihre Hilfe bei der Verbesserung dieser App!';

  @override
  String get patchNotesDialogTitle => 'Was ist neu?';

  @override
  String get version => 'Version';

  @override
  String get noMailAppTitle => 'Keine Mail-App gefunden';

  @override
  String get noMailAppDescription => 'Auf diesem Gerät ist keine E-Mail-App installiert oder initialisiert, bitte versuchen Sie es erneut, wenn Sie eine E-Mail-Nachricht senden können.';

  @override
  String get authenticationRequest => 'Authentifizierung';

  @override
  String requestInfo(Object issuer, Object account) {
    return 'Gesendet von $issuer für Ihr Konto: \"$account\"';
  }

  @override
  String errorUnlinkingPushToken(Object label) {
    return 'Entkoppeln des Push Tokens $label fehlgeschlagen.';
  }

  @override
  String get pleaseSyncManuallyWhenNetworkIsAvailable => 'Bitte synchronisieren Sie die Push Token über die Einstellungen manuell, wenn eine Netzwerkverbindung verfügbar ist.';

  @override
  String get pushTokens => 'Push-Tokens';

  @override
  String get continueButton => 'Weiter';

  @override
  String get addTokenManually => 'Token manuell hinzufügen';

  @override
  String get addFolder => 'Ordner hinzufügen';

  @override
  String get searchTokens => 'Token suchen';

  @override
  String get closeSearchTokens => 'Suche schließen';

  @override
  String get increaseCounter => 'Zähler erhöhen';

  @override
  String get copyOTPToClipboard => 'OTP in die Zwischenablage kopieren';

  @override
  String get licenses => 'Lizenzen';
}
