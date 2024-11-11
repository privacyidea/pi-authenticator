import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get a11yAddFolderButton => 'Map toevoegen';

  @override
  String get a11yAddTokenManuallyButton => 'Voeg token handmatig toe';

  @override
  String get a11yCloseSearchTokensButton => 'Zoekopdracht sluiten';

  @override
  String get a11yLicensesButton => 'Licenties';

  @override
  String get a11yPushTokensButton => 'Push Tokens';

  @override
  String get a11yScanQrCodeButton => 'QR-code scannen';

  @override
  String get a11yScanQrCodeViewActive => 'Scan-QR-codeweergave. Cammera is actief';

  @override
  String get a11yScanQrCodeViewFlashlightOff => 'Tik om de zaklamp aan te zetten.';

  @override
  String get a11yScanQrCodeViewFlashlightOn => 'Tik om de zaklamp uit te schakelen.';

  @override
  String get a11yScanQrCodeViewGallery => 'Galerij openen';

  @override
  String get a11yScanQrCodeViewInactive => 'Scan-QR-code weergave. Cammera is niet actief';

  @override
  String get a11ySearchTokensButton => 'Zoek tokens';

  @override
  String get a11ySettingsButton => 'Instellingen';

  @override
  String get accept => 'Accepteren';

  @override
  String get addANewFolder => 'Nieuwe map maken';

  @override
  String get addSystemInfo => 'Systeeminformatie toevoegen';

  @override
  String get addToken => 'Token toevoegen';

  @override
  String get additionalErrorMessage => 'Optioneel bericht';

  @override
  String get algorithm => 'Algoritme';

  @override
  String algorithmUnsupported(String algorithm) {
    return 'Het algoritme $algorithm wordt niet ondersteund';
  }

  @override
  String get allTokensSynchronized => 'Alle tokens zijn gesynchroniseerd.';

  @override
  String get asFile => 'Als bestand';

  @override
  String get asQrCode => 'Als QR-code';

  @override
  String get askLogSendedDescription => 'Heb je het logboek verzonden en wil je het nu wissen?';

  @override
  String get authNotSupportedBody => 'Deze actie vereist dat het apparaat is beveiligd met inlogggevens of biometrie.';

  @override
  String get authNotSupportedTitle => 'Apparaat inloggevens of biometrie is vereist';

  @override
  String get authToAcceptPushRequest => 'Authenticeer om de push aanvraag te accepteren.';

  @override
  String get authToDeclinePushRequest => 'Authenticeer om de push aanvraag te weigeren.';

  @override
  String get authenticateToShowOtp => 'Authenticeer om het eenmalige wachtwoord te tonen.';

  @override
  String get authenticateToUnLockToken => 'Authenticeer om de vergrendeling van de token te wijzigen.';

  @override
  String get authenticationRequest => 'Verificatieverzoek';

  @override
  String get biometricHint => 'Authenticatie vereist';

  @override
  String get biometricNotRecognized => 'Niet herkend. Probeer opnieuw.';

  @override
  String get biometricRequiredTitle => 'Biometrie is niet ingesteld';

  @override
  String get biometricSuccess => 'Authenticatie geslaagd';

  @override
  String get butDiscardIt => 'maar verwijder';

  @override
  String get cancel => 'Annuleren';

  @override
  String get checkServerCertificate => 'Controleer het servercertificaat';

  @override
  String get checkYourNetwork => 'Controleer je netwerkverbinding en probeer het opnieuw.';

  @override
  String get clearErrorLog => 'Verwijderen';

  @override
  String get clipboardEmpty => 'Klembord is leeg';

  @override
  String get confirmDeletion => 'Bevestig verwijderen';

  @override
  String confirmDeletionOf(String name) {
    return 'Weet u zeker dat u $name wilt verwijderen?';
  }

  @override
  String get confirmFolderDeletionHint => 'Het verwijderen van een map heeft geen effect op de tokens in de map. De tokens worden verplaatst naar de hoofdlijst.';

  @override
  String get confirmPassword => 'Wachtwoord bevestigen';

  @override
  String get confirmTokenDeletionHint => 'U kunt mogelijk niet meer inloggen als u dit token verwijdert. Controleer of u zonder dit token kunt inloggen op het gekoppelde account.';

  @override
  String get confirmation => 'Bevestiging';

  @override
  String get connectionFailed => 'Verbinding mislukt.';

  @override
  String get container => 'Container';

  @override
  String get containerAlreadyExists => 'Container bestaat al';

  @override
  String get containerDetails => 'Containergegevens';

  @override
  String get containerSerial => 'Container serie';

  @override
  String get containerSyncUrl => 'Url voor containersynchronisatie';

  @override
  String get continueButton => 'Ga verder';

  @override
  String get copyOTPToClipboard => 'Kopieer OTP naar klembord';

  @override
  String get couldNotConnectToServer => 'Kan geen verbinding maken met de server.';

  @override
  String get couldNotSignMessage => 'Bericht niet kunnen ondertekenen.';

  @override
  String get counter => 'Tegen';

  @override
  String get create => 'Creëer';

  @override
  String get createdAt => 'Gemaakt op';

  @override
  String get creator => 'Schepper';

  @override
  String get dayPasswordValidFor => 'Geldig voor';

  @override
  String get dayPasswordValidUntil => 'Geldig tot';

  @override
  String get decline => 'Weigeren';

  @override
  String get declineIt => 'weigeren';

  @override
  String get decrypt => 'Decoderen';

  @override
  String get decryptErrorButtonDelete => 'Verwijderen';

  @override
  String get decryptErrorButtonRetry => 'Opnieuw proberen';

  @override
  String get decryptErrorButtonSendError => 'Fout verzenden';

  @override
  String get decryptErrorContent => 'Helaas heeft de app je tokens niet kunnen decoderen. Dit geeft aan dat de coderingssleutel is verbroken. U kunt het opnieuw proberen of de app-gegevens verwijderen, waardoor de tokens in de app worden verwijderd.';

  @override
  String get decryptErrorDeleteConfirmationContent => 'Weet je zeker dat je de app-gegevens wilt verwijderen?';

  @override
  String get decryptErrorTitle => 'Fout bij decoderen';

  @override
  String get delete => 'Verwijderen';

  @override
  String get deleteContainerDialogContent => 'Als u deze container verwijdert, wordt de smartphone losgekoppeld van de privacyIDEA server en worden de tokens in deze container onbruikbaar. Controleer voor het verwijderen of de bijbehorende tokens niet meer nodig zijn!';

  @override
  String deleteContainerDialogTitle(String serial) {
    return 'Container verwijderen $serial';
  }

  @override
  String get deleteLockedToken => 'Verifieer om het vergrendelde token te verwijderen.';

  @override
  String get details => 'Details';

  @override
  String get deviceCredentialsRequiredTitle => 'Inloggevens van het apparaat zijn niet ingesteld';

  @override
  String get deviceCredentialsSetupDescription => 'Stel de inloggegevens in, bij de instellingen van het apparaat';

  @override
  String get digits => 'Cijfers';

  @override
  String get dismiss => 'Sluiten';

  @override
  String get done => 'Klaar';

  @override
  String get edit => 'Bewerken';

  @override
  String get editLockedToken => 'Verifieer om het vergrendelde token te bewerken.';

  @override
  String get editToken => 'Token bewerken';

  @override
  String get enablePolling => 'Zoeken aanzetten';

  @override
  String get encoding => 'Codering';

  @override
  String get enterDetailsForToken => 'Voer informatie over token in';

  @override
  String get enterLink => 'Link invoeren';

  @override
  String get enterPasswordToEncrypt => 'Voer een wachtwoord in om de tokens te versleutelen. Dit wachtwoord is vereist om de tokens te importeren.';

  @override
  String get errorLogCleared => 'Foutenlogboek gewist.';

  @override
  String get errorLogEmpty => 'Het foutenlogboek is leeg.';

  @override
  String get errorLogTitle => 'Foutenlogboek';

  @override
  String get errorMailBody => 'Het foutlogbestand is bijgevoegd.\nU kunt deze tekst vervangen door aanvullende informatie over de fout.';

  @override
  String get errorMissingPrivateKey => 'Ontbrekende privésleutel';

  @override
  String errorRollOutFailed(String name) {
    return 'Uitrollen van token $name mislukt.';
  }

  @override
  String errorRollOutNoConnectionToServer(String name) {
    return 'Het uitrollen van token $name is mislukt, de server kan niet worden bereikt.';
  }

  @override
  String get errorRollOutNotPossibleAnymore => 'Het uitrollen van dit token is niet meer mogelijk.';

  @override
  String get errorRollOutSSLHandshakeFailed => 'SSL-handdruk mislukt. Uitrollen niet mogelijk.';

  @override
  String errorRollOutUnknownError(String e) {
    return 'Een onbekende fout heeft plaats gevonden. Uitrollen is niet mogelijk: $e';
  }

  @override
  String get errorSavingFile => 'Fout bij het opslaan van het bestand';

  @override
  String get errorSynchronizationNoNetworkConnection => 'Token synchroniseren mislukt, privacyIDEA server kan niet worden bereikt.';

  @override
  String errorTokenExpired(String name) {
    return 'Het token $name is verlopen.';
  }

  @override
  String errorUnlinkingPushToken(String label) {
    return 'Het is niet gelukt om het push token $label te ontkoppelen.';
  }

  @override
  String errorWhenPullingChallenges(String name) {
    return 'Er is een fout opgetreden bij het zoeken naar uitdagingen van $name';
  }

  @override
  String get exampleUrl => 'Voer een geldige URL in zoals: \"https://example.com/\"';

  @override
  String get expandLockedFolder => 'Verifieer om de vergrendelde map te openen.';

  @override
  String get export => 'Exporteren';

  @override
  String get exportAllTokens => 'Alle tokens exporteren';

  @override
  String get exportLockedTokenReason => 'Authenticeer om vergrendelde tokens te exporteren.';

  @override
  String get exportNonPrivacyIDEATokens => 'Niet-privacyIDEA tokens exporteren';

  @override
  String get exportOneMore => 'Nog een';

  @override
  String get exportTokens => 'Tokens exporteren';

  @override
  String get exportingTokens => 'Tokens exporteren...';

  @override
  String failedToFinalizeContainer(String serial) {
    return 'Fout bij het afsluiten van de container $serial';
  }

  @override
  String failedToLoad(String name) {
    return 'Mislukt bij het laden: $name';
  }

  @override
  String failedToSyncContainer(String serial) {
    return 'Synchronisatie van container $serial mislukt';
  }

  @override
  String get feedback => 'Feedback';

  @override
  String get feedbackDescription => 'Als je vragen, suggesties of problemen hebt, laat het ons dan weten.';

  @override
  String get feedbackHint => 'Er wordt een kant-en-klare e-mail geopend die je naar ons kunt sturen. Indien gewenst wordt informatie over je apparaat en de versie van de applicatie toegevoegd. U kunt de e-mail controleren en bewerken voordat u deze verzendt.';

  @override
  String get feedbackPrivacyPolicy1 => 'Door feedback te sturen ga je akkoord met ons ';

  @override
  String get feedbackPrivacyPolicy2 => 'privacybeleid';

  @override
  String get feedbackPrivacyPolicy3 => '.';

  @override
  String get feedbackSentDescription => 'Hartelijk dank voor je hulp om deze applicatie beter te maken!';

  @override
  String get feedbackSentTitle => 'Feedback verzonden';

  @override
  String get feedbackTitle => 'Uw feedback is altijd welkom!';

  @override
  String get fileSavedToDownloadsFolder => 'Bestand opgeslagen in de map Downloads';

  @override
  String get finalizationState => 'Afrondingsstatus';

  @override
  String get finalizeContainerFailed => 'Container voltooien mislukt';

  @override
  String get firebaseToken => 'Firebase Token';

  @override
  String get folderName => 'Mapnaam';

  @override
  String get generatingPhonePart => 'Genereren telefoon gedeelte';

  @override
  String get gitHubButton => 'Deze app is open source\nBezoek ons op GitHub';

  @override
  String get goToSettingsButton => 'Ga naar instellingen';

  @override
  String get goToSettingsDescription => 'Authenticatie via inloggegevens of biometrie is niet ingesteld. Stel het in bij de instellingen van het apparaat.';

  @override
  String get grantCameraPermissionDialogButton => 'Toestemming verlenen';

  @override
  String get grantCameraPermissionDialogContent => 'Geef de camera toestemming om QR-codes te scannen.';

  @override
  String get grantCameraPermissionDialogPermanentlyDenied => 'Cameratoestemming is permanent geweigerd. Geef de camera toestemming in de instellingen van uw telefoon.';

  @override
  String get grantCameraPermissionDialogTitle => 'Cameratoestemming is niet verleend';

  @override
  String get handshakeFailed => 'Handshake mislukt';

  @override
  String get hidePushTokens => 'Verberg push tokens';

  @override
  String get hidePushTokensDescription => 'Verberg push tokens uit de token lijst. Hierdoor worden de tokens niet verwijderd en blijven ze zichtbaar op een apart scherm.';

  @override
  String get imageUrl => 'Afbeeldings-URL';

  @override
  String importConflictToken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Er is een conflict met tokens die al bestaan.Selecteer welke u wilt behouden.',
      one: 'Er is een conflict met tokens die al bestaan.Selecteer welke u wilt behouden.',
      zero: 'Er is geen conflict met tokens die al bestaan.',
    );
    return '$_temp0';
  }

  @override
  String importExistingToken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tokens gevonden die al in de applicatie staan.',
      one: 'Er is een token gevonden dat al bestaat in de applicatie.',
      zero: 'Er is geen token gevonden dat al in de toepassing aanwezig is.',
    );
    return '$_temp0';
  }

  @override
  String get importExportTokens => 'Tokens importeren/exporteren';

  @override
  String importFailedToken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kan $count tokens niet importeren.',
      one: 'Kan geen token importeren.',
      zero: 'Geen token Niet geïmporteerd.',
    );
    return '$_temp0';
  }

  @override
  String get importHint2FAS => 'Selecteer uw 2FAS-back-up. Als u geen back-up hebt, maak er dan een aan in de 2FAS-app. Wij raden u aan een wachtwoord te gebruiken.';

  @override
  String get importHintAegisBackupFile => 'Selecteer uw Aegis-export (.JSON).Als u geen export hebt, maak er dan een aan via het instellingenmenu in de Aegis-app. Het gebruik van een wachtwoord wordt aanbevolen.';

  @override
  String get importHintAegisLink => 'Voer de link in die u ontvangt wanneer u vermeldingen van Aegis overdraagt.';

  @override
  String get importHintAegisQrScan => 'Scan de QR-code die u ontvangt bij het overbrengen van items uit Aegis.';

  @override
  String get importHintAuthenticatorProFile => 'Om een back-up te maken van de Authenticator Pro app, navigeer je naar de instellingen en tik je op \"Auto back-up\". Selecteer een opslaglocatie en stel een wachtwoord in. Druk vervolgens op \"Nu back-uppen\" om de tokens te exporteren.';

  @override
  String get importHintFreeOtpPlusFile => 'Om een back-up van de FreeOTP+ app te maken, tikt u op de drie puntjes in de rechterbovenhoek en selecteert u \"Exporteren\". U kunt kiezen tussen JSON en URI formaat. We raden u aan de back-up te verwijderen na het importeren, omdat deze niet versleuteld is.';

  @override
  String get importHintFreeOtpPlusQrScan => 'Scan de QR-code die u ontvangt wanneer u op de drie stippen in de tegel van de token drukt en selecteer \"QR-code delen\".';

  @override
  String get importHintGoogleQrFile => 'Selecteer een afbeeldingsbestand met de QR-code die u ontvangt wanneer u uw accounts exporteert vanuit Google Authenticator.\n!! Let op: het is niet veilig om de QR-code op je apparaat op te slaan, omdat de tokens niet versleuteld zijn !!';

  @override
  String get importHintGoogleQrScan => 'Scan de QR-code die u ontvangt wanneer u uw accounts exporteert vanuit Google Authenticator.';

  @override
  String get importHintPrivacyIdeaFile => 'Om een back-up te maken, ga je naar de instellingen en tik je op \"Exporteren\". Selecteer \"Als bestand\" en selecteer de tokens die je wilt exporteren. Tik dan op \"Exporteren\" en stel een wachtwoord in. De opslaglocatie is de downloadmap op je apparaat.';

  @override
  String get importHintPrivacyIdeaQrScan => 'Om QR-codes van de tokens te maken, navigeer je naar de instellingen en tik je op \"Exporteren\". Selecteer vervolgens \"Als QR-code\" en tik op het muntje dat geëxporteerd moet worden. Deze variant is alleen geschikt voor directe overdracht naar een ander apparaat, omdat de QR-code niet versleuteld is.';

  @override
  String importNTokens(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importeer $count tokens',
      one: 'Eén token importeren',
      zero: 'Geen tokens importeren',
    );
    return '$_temp0';
  }

  @override
  String importNewToken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Er zijn $count nieuwe tokens gevonden die geïmporteerd kunnen worden.',
      one: 'Er is een nieuw token gevonden dat geïmporteerd kan worden.',
      zero: 'Er is geen nieuw token gevonden.',
    );
    return '$_temp0';
  }

  @override
  String get importTokens => 'Importer un jeton';

  @override
  String get importantInformationTitle => 'Important information';

  @override
  String get importedVia => 'Geïmporteerd via';

  @override
  String get increaseCounter => 'Verhoog teller';

  @override
  String internalServerError(String code) {
    return 'Interne serverfout ($code)';
  }

  @override
  String get introAddFolder => 'Je kunt mappen maken om je tokens te organiseren.';

  @override
  String get introAddTokenManually => 'Als je geen QR-code wilt scannen, kun je tokens ook handmatig toevoegen.';

  @override
  String get introDragToken => 'Reorganiseer je tokens door er een paar seconden op te drukken en het dan naar de gewenste positie te slepen.';

  @override
  String get introEditToken => 'Hier kun je de naam van het token bewerken en enkele details bekijken.';

  @override
  String get introHidePushTokens => 'Je push tokens zijn nu verborgen, maar je kunt ze nog steeds zien op het push token scherm.';

  @override
  String get introLockToken => 'Om de beveiliging nog meer te verbeteren, kun je tokens vergrendelen.¨Dan kan het token alleen gebruikt worden na authenticatie.';

  @override
  String get introPollForChallenges => 'Je kunt controleren of er nieuwe uitdagingen zijn door de lijst met tokens naar beneden te slepen.';

  @override
  String get introScanQrCode => 'Je kunt QR-codes scannen om tokens toe te voegen.We ondersteunen alle gangbare Two-Factor-Authenticatie tokens en ook de privacyIDEA tokens.';

  @override
  String get introTokenSwipe => 'Veeg tokens naar links om beschikbare acties te zien.';

  @override
  String invalidBackupFile(String appName) {
    return 'Het geselecteerde bestand is geen geldige backup van $appName.';
  }

  @override
  String invalidLink(String appName) {
    return 'De ingevoerde link is geen geldig token van $appName, of wordt niet ondersteund.';
  }

  @override
  String invalidQrFile(String appName) {
    return 'Het geselecteerde bestand bevat geen geldige QR code van $appName.';
  }

  @override
  String invalidQrScan(String appName) {
    return 'De gescande QR code is geen geldige backup van $appName.';
  }

  @override
  String get invalidUrl => 'Ongeldige URL';

  @override
  String invalidValue(String parameter, String type, String value) {
    return 'Het $type \'$value\' is niet geldig voor \'$parameter\'.';
  }

  @override
  String invalidValueIn(String map, String parameter, String type, String value) {
    return 'Het $type \'$value\' is niet geldig voor \'$parameter\' in \'$map\'.';
  }

  @override
  String get isExpotableQuestion => 'Is exporteerbaar?';

  @override
  String get isPiTokenQuestion => 'Is het een privacyIDEA token?';

  @override
  String get issuer => 'Verstrekker';

  @override
  String issuerLabel(String name) {
    return 'Verstrekker: $name';
  }

  @override
  String get language => 'Taal';

  @override
  String get legacySigningErrorMessage => 'Het token is aangemaakt in een verouderde versie van de app, wat kan leiden tot problemen bij het gebruik ervan.\nHet wordt aanbevolen om een nieuw push token aan te maken als het probleem zich blijft voordoen!';

  @override
  String legacySigningErrorTitle(String tokenLabel) {
    return 'Er is een fout opgetreden bij het gebruik van het verouderde token: $tokenLabel';
  }

  @override
  String get licensesAndVersion => 'Licenties en versie';

  @override
  String get linkMustOtpAuth => 'De link moet beginnen met otpauth://';

  @override
  String get linkedContainer => 'Gekoppelde container';

  @override
  String get lock => 'Vergrendel';

  @override
  String get lockOut => 'Biometrische authenticatie staat uit. Vergrendel en ontgrendel het scherm om het aan te zetten.';

  @override
  String get logMenu => 'Log menu';

  @override
  String get malformedData => 'De QR code bevat onjuiste gegevens.';

  @override
  String get markQrCode => 'Markeer QR Code';

  @override
  String missingRequiredParameter(String parameter) {
    return 'De waarde voor de parameter [$parameter] is vereist, maar ontbreekt.';
  }

  @override
  String missingRequiredParameterIn(String map, String parameter) {
    return 'De waarde voor de parameter [$parameter] is vereist, maar ontbreekt in \"$map\".';
  }

  @override
  String mustNotBeEmpty(String field) {
    return '$field mag niet leeg zijn';
  }

  @override
  String get name => 'Naam';

  @override
  String get no => 'Nee';

  @override
  String get noFbToken => 'Geen Firebase Token beschikbaar';

  @override
  String get noMailAppDescription => 'Er is geen e-mail app geïnstalleerd of geïnitialiseerd op dit apparaat, probeer het opnieuw wanneer u in staat bent om een e-mailbericht te verzenden.';

  @override
  String get noMailAppTitle => 'Geen mail app gevonden';

  @override
  String get noNetworkConnection => 'Geen netwerkverbinding.';

  @override
  String get noPublicKey => 'Geen openbare sleutel beschikbaar';

  @override
  String get noResultText1 => 'Tik op ';

  @override
  String get noResultText2 => ' de knop om te beginnen!';

  @override
  String get noResultTitle => 'Nog geen token opgeslagen.';

  @override
  String get noTokenToExport => 'Geen token beschikbaar voor export';

  @override
  String get noTokenToImport => 'Geen token gevonden om te importeren';

  @override
  String get notAnInteger => 'De waarde is geen geheel getal.';

  @override
  String get notAnNumber => 'De waarde is geen getal.';

  @override
  String get ok => 'Ok';

  @override
  String get open => 'Openen';

  @override
  String get originApp => 'Oorsprong app';

  @override
  String get originDetails => 'Details over de oorsprong';

  @override
  String otpValueCopiedMessage(String otpValue) {
    return 'Wachtwoord \"$otpValue\" gekopieerd naar het klembord.';
  }

  @override
  String get password => 'Wachtwoord';

  @override
  String get passwordCannotBeEmpty => 'Wachtwoord mag niet leeg zijn';

  @override
  String get passwordCannotContainWhitespace => 'Wachtwoord mag geen spaties bevatten';

  @override
  String get passwordMustBeAtLeast8Characters => 'Wachtwoord moet minimaal 8 tekens lang zijn';

  @override
  String get passwordMustContainLowercaseLetter => 'Wachtwoord moet een kleine letter bevatten';

  @override
  String get passwordMustContainNumber => 'Wachtwoord moet een cijfer bevatten';

  @override
  String get passwordMustContainSpecialCharacter => 'Wachtwoord moet een speciaal teken bevatten';

  @override
  String get passwordMustContainUppercaseLetter => 'Wachtwoord moet een hoofdletter bevatten';

  @override
  String get passwordsDoNotMatch => 'Wachtwoorden komen niet overeen';

  @override
  String get patchNotesBugFixes => 'Bugfixes';

  @override
  String get patchNotesDialogTitle => 'Wat is er nieuw?';

  @override
  String get patchNotesImprovements => 'Verbeteringen';

  @override
  String get patchNotesNewFeatures => 'Nieuwe functies';

  @override
  String get patchNotesV4_3_0NewFeatures1 => 'Ondersteuning toegevoegd voor het importeren van tokens van Google, Aegis en 2FAS Authenticator. Meer importbronnen zullen in de toekomst worden toegevoegd.';

  @override
  String get patchNotesV4_3_0NewFeatures2 => 'Feedbackoptie toegevoegd aan de instellingen.';

  @override
  String get patchNotesV4_3_0NewFeatures3 => 'Push tokens kunnen nu verborgen worden in de tokenlijst.';

  @override
  String get patchNotesV4_3_0NewFeatures4 => 'Introducties zijn toegevoegd om nieuwe gebruikers op weg te helpen.';

  @override
  String get patchNotesV4_3_0NewFeatures5 => 'Je kunt nu naar tokens zoeken door op het vergrootglas in de rechterbovenhoek te tikken.';

  @override
  String get patchNotesV4_3_0NewFeatures6 => 'HomeWidget Token toegevoegd voor Android 12 en hoger.';

  @override
  String get patchNotesV4_3_1BugFix1 => 'Een probleem is opgelost waarbij de otp-waarde niet werd weergegeven na authenticatie op sommige apparaten.';

  @override
  String get patchNotesV4_3_1Improvement1 => 'De QR-code scanner is verbeterd.';

  @override
  String get patchNotesV4_4_0Improvement1 => 'Er zijn meer invoerbronnen toegevoegd.';

  @override
  String get patchNotesV4_4_0Improvement2 => 'De herkenning van QR-codes uit afbeeldingsbestanden is verbeterd.';

  @override
  String get patchNotesV4_4_0NewFeatures1 => 'Het is nu mogelijk om tokens te exporteren waarvan kan worden gegarandeerd dat het geen privacyIDEA tokens zijn. Op dit moment kan niet worden uitgesloten dat tokens die zijn toegevoegd via de QR-code scanner afkomstig zijn van privacyIDEA. De differentiatie zal in toekomstige versies worden verbeterd.';

  @override
  String get patchNotesV4_4_0NewFeatures2 => 'Ondersteuning toegevoegd voor privacyIDEA\'s \"require presence\".';

  @override
  String get patchNotesV4_4_2Improvement1 => 'Zaklampondersteuning toegevoegd voor QR-code scannen.';

  @override
  String get patchNotesV4_4_2NewFeatures1 => 'Tokens kunnen nu worden ingevoegd met kopiëren en plakken.';

  @override
  String get patchNotesV4_4_2NewFeatures2 => 'Galerijondersteuning toegevoegd voor QR-code scannen.';

  @override
  String get period => 'Duur';

  @override
  String get phonePart => 'Telefoon gedeelte:';

  @override
  String piServerCode(String code) {
    return 'PI-servercode: $code';
  }

  @override
  String get pleaseEnterANameForThisToken => 'Voer de naam in voor deze token.';

  @override
  String get pleaseEnterASecretForThisToken => 'Voer de geheime sleutel in voor deze token.';

  @override
  String get pollingFailed => 'Vraag mislukt.';

  @override
  String pollingFailedFor(String serial) {
    return 'Query voor $serial mislukt.';
  }

  @override
  String get privacyPolicy => 'Privacybeleid';

  @override
  String get publicKey => 'Openbare sleutel';

  @override
  String get pushEndpointUrl => 'Push Endpoint URL';

  @override
  String get pushRequestParseError => 'Het pushverzoek kon niet worden verwerkt.';

  @override
  String get pushToken => 'Push Token';

  @override
  String get qrFileDecodeError => 'Het was niet mogelijk om de QR code te decoderen van de geselecteerde afbeelding, gebruik in plaats daarvan de QR code scanner.';

  @override
  String get qrInFileNotFound => 'Er is geen QR code gevonden in de geselecteerde afbeelding.';

  @override
  String get qrInFileNotFound2 => 'U kunt mij laten zien waar de QR code is.';

  @override
  String get qrInFileNotFound3 => 'Ik verwacht dat ik de code zal vinden als het in het midden van het gemarkeerde gebied is.';

  @override
  String get qrNotFound => 'Geen QR code gevonden!';

  @override
  String get rename => 'Wijzigen';

  @override
  String get renameToken => 'Hernoem token';

  @override
  String get renameTokenFolder => 'Map hernoemen';

  @override
  String get replaceButton => 'vervangen';

  @override
  String requestInfo(String account, String issuer) {
    return 'Verzonden door $issuer voor uw account: \"$account\"';
  }

  @override
  String get requestPushChallengesPeriodically => 'Activeer het zoeken naar berichten. Gebruik deze optie wanneer de push berichten niet worden ontvangen.';

  @override
  String get requestTriggerdByUserQuestion => 'Is dit verzoek door jou gedaan?';

  @override
  String get retryRolloutButton => 'Opnieuw uitrollen';

  @override
  String get rolloutStateCompleted => 'Uitrollen voltooid';

  @override
  String get rolloutStateGeneratingKeyPair => 'Sleutelpaar genereren';

  @override
  String get rolloutStateGeneratingKeyPairCompleted => 'Genereren sleutelpaar voltooid';

  @override
  String get rolloutStateGeneratingKeyPairFailed => 'Het sleutelpaar is niet gegenereerd';

  @override
  String get rolloutStateNotStarted => 'Start uitrollen';

  @override
  String get rolloutStateParsingResponse => 'Antwoord analyseren';

  @override
  String get rolloutStateParsingResponseCompleted => 'Antwoord ontleden voltooid';

  @override
  String get rolloutStateParsingResponseFailed => 'Antwoord analyseren mislukt';

  @override
  String get rolloutStateSendingPublicKey => 'Publieke sleutel verzenden';

  @override
  String get rolloutStateSendingPublicKeyCompleted => 'Verzenden openbare sleutel voltooid';

  @override
  String get rolloutStateSendingPublicKeyFailed => 'Versturen openbare sleutel mislukt';

  @override
  String get saveButton => 'Opslaan';

  @override
  String get scanQrCode => 'Scan QR-Code';

  @override
  String get scanThisQrWithNewDevice => 'Scan deze QR-code met uw nieuwe apparaat om de token te importeren.';

  @override
  String get secondsUntilNextOTP => 'Seconden tot volgende OTP';

  @override
  String get secretIsRequired => 'Geheim is vereist';

  @override
  String get secretKey => 'Geheime sleutel';

  @override
  String get selectFile => 'Selecteer bestand';

  @override
  String get selectImportSource => 'Selecteer importbron';

  @override
  String get selectImportType => 'Hoe wilt u de tokens importeren?';

  @override
  String selectTokensToExport(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Selecteer tokens om te exporteren',
      one: 'Selecteer token om te exporteren',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get selectTokensToExportHelpContent1 => 'Als een token niet in de lijst staat, is het niet gegarandeerd dat het geen privacyIDEA token is.';

  @override
  String get selectTokensToExportHelpContent2 => 'Momenteel kunnen alleen handmatig toegevoegde en geïmporteerde tokens worden geëxporteerd.';

  @override
  String get selectTokensToExportHelpContent3 => 'We werken aan een oplossing om onderscheid te maken tussen privacyIDEA tokens en privé tokens.';

  @override
  String get selectTokensToExportHelpContent4 => ' Je kunt een nieuwe QR code krijgen van de dienst waarvan je het token hebt ontvangen.';

  @override
  String get selectTokensToExportHelpTitle => 'Staat jouw token er niet bij?';

  @override
  String get send => 'verzenden';

  @override
  String get sendErrorDialogBody => 'Een onverwachte fout heeft plaatsgevonden in de applicatie. De onderstaande informatie kan worden verstuurd naar de ontwikkelaars via e-mail om het probleem in de toekomst te voorkomen.';

  @override
  String get sendErrorLogDescription => 'Er wordt een kant-en-klare e-mail gemaakt die informatie bevat over de app, de fout en het apparaat.\nJe kunt de e-mail bewerken voordat je hem verstuurt.\nJe kunt hier zien hoe we de informatie gebruiken:';

  @override
  String get sendPushRequestResponseFailed => 'Het verzenden van het antwoord is mislukt. ';

  @override
  String get serverNotReachable => 'De server kon niet worden bereikt.';

  @override
  String get settings => 'Instellingen';

  @override
  String get settingsGroupGeneral => 'Algemene informatie';

  @override
  String get showDetails => 'Details tonen';

  @override
  String get showErrorLog => 'Weergeven';

  @override
  String get showPrivacyPolicy => 'Privacybeleid tonen';

  @override
  String get signInTitle => 'Authenticatie vereist';

  @override
  String get someTokensDoNotSupportPolling => 'Sommige tokens zijn verouderd en ondersteunen geen actief zoeken';

  @override
  String statusCode(int statusCode) {
    return 'Statuscode: $statusCode';
  }

  @override
  String get sync => 'Synchroniseer';

  @override
  String get syncContainerFailed => 'Container synchronisatie mislukt';

  @override
  String get syncFbTokenFailed => 'Synchroniseren mislukt voor de volgende tokens, probeer het opnieuw:';

  @override
  String get syncFbTokenManuallyWhenNetworkIsAvailable => 'Synchroniseer de push tokens handmatig via de instellingen als er een netwerkverbinding beschikbaar is.';

  @override
  String get syncState => 'Sync-status';

  @override
  String get syncStateCompletedDescription => 'Sync voltooid';

  @override
  String get syncStateFailedDescription => 'Sync mislukt';

  @override
  String get syncStateNotStartedDescription => 'Synchronisatie niet gestart';

  @override
  String get syncStateSyncingDescription => 'Momenteel aan het synchroniseren';

  @override
  String get synchronizePushTokens => 'Synchroniseer push tokens';

  @override
  String get synchronizesTokensWithServer => 'Synchroniseert tokens met de privacyIDEA server.';

  @override
  String get synchronizingTokens => 'Tokens synchroniseren.';

  @override
  String get theSecretDoesNotFitTheCurrentEncoding => 'De geheime sleutel past niet bij de huidige codering';

  @override
  String get theme => 'Thema';

  @override
  String get timeOut => 'Time-out';

  @override
  String get tokenDataParseError => 'Token-gegevens konden niet worden verwerkt';

  @override
  String get tokenDetails => 'Details van de token';

  @override
  String get tokenLinkImport => 'tokenlink';

  @override
  String get tokenSerial => 'Token serial';

  @override
  String get tokensAreEncrypted => 'De tokens zijn gecodeerd. Voer het wachtwoord in om ze te decoderen.';

  @override
  String get tokensDoNotSupportSynchronization => 'Voor de volgende tokens wordt synchroniseren niet ondersteunt, ze moeten opnieuw worden aangeleverd:';

  @override
  String get tokensSuccessfullyDecrypted => 'De tokens zijn succesvol gedecodeerd en kunnen nu worden geïmporteerd.';

  @override
  String get type => 'Type';

  @override
  String get unexpectedError => 'Er is een onverwachte fout opgetreden.';

  @override
  String get unknown => 'Onbekend';

  @override
  String get unlock => 'Ontgrendel';

  @override
  String unsupported(String name, String value) {
    return 'De $name [$value] wordt niet ondersteund door deze versie van de app.';
  }

  @override
  String get useDeviceLocaleDescription => 'Gebruik de taal van het apparaat wanneer het wordt ondersteund, val anders terug op Engels.';

  @override
  String get useDeviceLocaleTitle => 'Gebruik de taal van het apparaat';

  @override
  String valueNotAllowed(String parameter, String type, String value) {
    return 'Type $type “$value” is geen toegestane waarde voor ‘$parameter’';
  }

  @override
  String valueNotAllowedIn(String map, String parameter, String type, String value) {
    return 'Type $type “$value” is geen geldige waarde voor ‘$parameter’ in ”$map”';
  }

  @override
  String get verboseLogging => 'Verbose loggen';

  @override
  String get versionTitle => 'Versie';

  @override
  String get wrongPassword => 'Onjuist wachtwoord';

  @override
  String get yes => 'Ja';
}
