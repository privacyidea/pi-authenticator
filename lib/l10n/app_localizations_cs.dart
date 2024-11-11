import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get a11yAddFolderButton => 'Přidat složku';

  @override
  String get a11yAddTokenManuallyButton => 'Přidat token ručně';

  @override
  String get a11yCloseSearchTokensButton => 'Zavřít vyhledávání';

  @override
  String get a11yLicensesButton => 'Licence';

  @override
  String get a11yPushTokensButton => 'Žetony Push';

  @override
  String get a11yScanQrCodeButton => 'Skenování QR-kódu';

  @override
  String get a11yScanQrCodeViewActive => 'Zobrazení Scan-QR-code. Cammera je aktivní';

  @override
  String get a11yScanQrCodeViewFlashlightOff => 'Klepnutím zapněte svítilnu.';

  @override
  String get a11yScanQrCodeViewFlashlightOn => 'Klepnutím vypnete svítilnu.';

  @override
  String get a11yScanQrCodeViewGallery => 'Otevřít galerii';

  @override
  String get a11yScanQrCodeViewInactive => 'Zobrazení skenování QR kódu. Kamera není aktivní';

  @override
  String get a11ySearchTokensButton => 'Hledat tokeny';

  @override
  String get a11ySettingsButton => 'Nastavení';

  @override
  String get accept => 'Přijmout';

  @override
  String get addANewFolder => 'Vytvoření nové složky';

  @override
  String get addSystemInfo => 'Přidat systémové informace';

  @override
  String get addToken => 'Přidat token';

  @override
  String get additionalErrorMessage => 'Volitelná zpráva';

  @override
  String get algorithm => 'Algoritmus';

  @override
  String algorithmUnsupported(String algorithm) {
    return 'Algoritmus $algorithm není podporován';
  }

  @override
  String get allTokensSynchronized => 'Všechny tokeny jsou synchronizované.';

  @override
  String get asFile => 'Jako soubor';

  @override
  String get asQrCode => 'Jako QR kód';

  @override
  String get askLogSendedDescription => 'Odeslali jste protokol a chcete jej nyní vymazat?';

  @override
  String get authNotSupportedBody => 'Tato akce vyžaduje, aby bylo zařízení chráněno zámkem zařízení nebo biometrickým ověřením.';

  @override
  String get authNotSupportedTitle => 'Vyžadován zámek zařízení nebo biometrické ověření';

  @override
  String get authToAcceptPushRequest => 'Pro přijetí požadavku na push notifikaci se přihlaste.';

  @override
  String get authToDeclinePushRequest => 'Pro odmítnutí požadavku na push notifikaci se přihlaste.';

  @override
  String get authenticateToShowOtp => 'Pro zobrazení jednorázového kódu se přihlaste.';

  @override
  String get authenticateToUnLockToken => 'Pro změnu uzamčení tokenu se přihlaste.';

  @override
  String get authenticationRequest => 'Žádost o ověření';

  @override
  String get biometricHint => 'Vyžadováno přihlášení';

  @override
  String get biometricNotRecognized => 'Ověření se nezdařilo. Zkuste to znovu.';

  @override
  String get biometricRequiredTitle => 'Biometrické ověření není nastaveno';

  @override
  String get biometricSuccess => 'Přihlášení bylo úspěšné';

  @override
  String get butDiscardIt => 'ale zahodit jej';

  @override
  String get cancel => 'Zrušit';

  @override
  String get checkServerCertificate => 'Zkontrolujte prosím certifikát serveru';

  @override
  String get checkYourNetwork => 'Zkontrolujte prosím síťové připojení a zkuste to znovu.';

  @override
  String get clearErrorLog => 'Vymazat';

  @override
  String get clipboardEmpty => 'Schránka je prázdná';

  @override
  String get confirmDeletion => 'Potvrdit smazání';

  @override
  String confirmDeletionOf(String name) {
    return 'Opravdu chcete smazat token $name?';
  }

  @override
  String get confirmFolderDeletionHint => 'Odstranění složky nemá žádný vliv na tokeny v ní.\nTokeny jsou přesunuty do hlavního seznamu.';

  @override
  String get confirmPassword => 'Potvrďte heslo';

  @override
  String get confirmTokenDeletionHint => 'Pokud tento token odstraníte, nebude již možné se přihlásit.\nProsím, ujistěte se, že se můžete přihlásit k přidruženému účtu bez tohoto tokenu.';

  @override
  String get confirmation => 'Potvrzení';

  @override
  String get connectionFailed => 'Připojení se nezdařilo.';

  @override
  String get container => 'Kontejner';

  @override
  String get containerAlreadyExists => 'Kontejner již existuje';

  @override
  String get containerDetails => 'Podrobnosti o kontejneru';

  @override
  String get containerSerial => 'Sériový kontejner';

  @override
  String get containerSyncUrl => 'Url pro synchronizaci kontejnerů';

  @override
  String get continueButton => 'Pokračovat';

  @override
  String get copyOTPToClipboard => 'Zkopírovat OTP do schránky';

  @override
  String get couldNotConnectToServer => 'Nepodařilo se připojit k serveru.';

  @override
  String get couldNotSignMessage => 'Zprávu se nepodařilo podepsat.';

  @override
  String get counter => 'Pult';

  @override
  String get create => 'Vytvořit';

  @override
  String get createdAt => 'Vytvořeno dne';

  @override
  String get creator => 'Tvůrce';

  @override
  String get dayPasswordValidFor => 'Platné pro';

  @override
  String get dayPasswordValidUntil => 'Platné do';

  @override
  String get decline => 'Odmítnout';

  @override
  String get declineIt => 'odmítnout jej ';

  @override
  String get decrypt => 'Dešifrovat';

  @override
  String get decryptErrorButtonDelete => 'Odstranit';

  @override
  String get decryptErrorButtonRetry => 'Opakování';

  @override
  String get decryptErrorButtonSendError => 'Odeslat chybu';

  @override
  String get decryptErrorContent => 'Bohužel se aplikaci nepodařilo dešifrovat vaše tokeny. To znamená, že šifrovací klíč je poškozen. Můžete to zkusit znovu nebo odstranit data aplikace, čímž by došlo k odstranění tokenů v aplikaci.';

  @override
  String get decryptErrorDeleteConfirmationContent => 'Jste si jisti, že chcete data aplikace odstranit?';

  @override
  String get decryptErrorTitle => 'Chyba dešifrování';

  @override
  String get delete => 'Smazat';

  @override
  String get deleteContainerDialogContent => 'Pokud tento kontejner odstraníte, smartphone se odpojí od serveru privacyIDEA a tokeny v tomto kontejneru nebudou použitelné. Před odstraněním se ujistěte, že příslušné tokeny již nejsou potřeba!';

  @override
  String deleteContainerDialogTitle(String serial) {
    return 'Odstranění kontejneru $serial';
  }

  @override
  String get deleteLockedToken => 'Prosím, autentifikujte se pro smazání uzamčeného tokenu.';

  @override
  String get details => 'Podrobnosti na';

  @override
  String get deviceCredentialsRequiredTitle => 'Není nastaven zámek zařízení';

  @override
  String get deviceCredentialsSetupDescription => 'Nastave zámek zařízení v nastavení zařízení';

  @override
  String get digits => 'Počet číslic';

  @override
  String get dismiss => 'Zavřít';

  @override
  String get done => 'Hotovo';

  @override
  String get edit => 'Upravit';

  @override
  String get editLockedToken => 'Prosím, autentifikujte se pro úpravu uzamčeného tokenu.';

  @override
  String get editToken => 'Upravit token';

  @override
  String get enablePolling => 'Povolit polling';

  @override
  String get encoding => 'Kódování';

  @override
  String get enterDetailsForToken => 'Vložte podrobnosti tokenu';

  @override
  String get enterLink => 'Zadejte odkaz';

  @override
  String get enterPasswordToEncrypt => 'Zadejte heslo pro šifrování žetonů. Toto heslo bude vyžadováno k importu žetonů.';

  @override
  String get errorLogCleared => 'Protokol chyb vymazán.';

  @override
  String get errorLogEmpty => 'Protokol chyb je prázdný.';

  @override
  String get errorLogTitle => 'Protokol chyb';

  @override
  String get errorMailBody => 'Přiložen je soubor protokolu o chybách.\nTento text můžete nahradit dalšími informacemi o chybě.';

  @override
  String get errorMissingPrivateKey => 'Chybějící soukromý klíč';

  @override
  String errorRollOutFailed(String name) {
    return 'Registrace tokenu $name selhala.';
  }

  @override
  String errorRollOutNoConnectionToServer(String name) {
    return 'Registrace tokenu $name selhala. Server není dostupný.';
  }

  @override
  String get errorRollOutNotPossibleAnymore => 'Roll-out tohoto tokenu již není možný.';

  @override
  String get errorRollOutSSLHandshakeFailed => 'SSL handshake se nezdařil. Roll-out není možný.';

  @override
  String errorRollOutUnknownError(String e) {
    return 'Vyskytla se neznámá chyba. Registrace není možná: $e';
  }

  @override
  String get errorSavingFile => 'Chyba při ukládání souboru';

  @override
  String get errorSynchronizationNoNetworkConnection => 'Synchronizace tokenů selhala, připojení k serveru privacyIDEA se nezdařilo.';

  @override
  String errorTokenExpired(String name) {
    return 'Platnost tokenu $name vypršela.';
  }

  @override
  String errorUnlinkingPushToken(String label) {
    return 'Nepodařilo se odlinkovat push token $label.';
  }

  @override
  String errorWhenPullingChallenges(String name) {
    return 'Při dotazování na výzvy $name došlo k chybě.';
  }

  @override
  String get exampleUrl => 'Zadejte prosím platnou adresu URL, například: \"https://example.com/\"';

  @override
  String get expandLockedFolder => 'Chcete-li otevřít uzamčenou složku, ověřte se.';

  @override
  String get export => 'Export';

  @override
  String get exportAllTokens => 'Exportovat všechny žetony';

  @override
  String get exportLockedTokenReason => 'Prosím, ověřte se, abyste mohli exportovat uzamčené žetony.';

  @override
  String get exportNonPrivacyIDEATokens => 'Exportovat ne-privacyIDEA žetony';

  @override
  String get exportOneMore => 'Ještě jeden';

  @override
  String get exportTokens => 'Exportovat žetony';

  @override
  String get exportingTokens => 'Probíhá export žetonů...';

  @override
  String failedToFinalizeContainer(String serial) {
    return 'Nepodařilo se dokončit kontejner $serial';
  }

  @override
  String failedToLoad(String name) {
    return 'Nepodařilo se načíst: $name';
  }

  @override
  String failedToSyncContainer(String serial) {
    return 'Nepodařilo se synchronizovat kontejner $serial';
  }

  @override
  String get feedback => 'Zpětná vazba';

  @override
  String get feedbackDescription => 'Pokud máte nějaké dotazy, návrhy nebo problémy, dejte nám prosím vědět.';

  @override
  String get feedbackHint => 'Otevře se připravený e-mail, který nám můžete zaslat. V případě potřeby budou doplněny informace o vašem zařízení a verzi aplikace. Před odesláním můžete e-mail zkontrolovat a upravit.';

  @override
  String get feedbackPrivacyPolicy1 => 'Odesláním zpětné vazby souhlasíte s našimi ';

  @override
  String get feedbackPrivacyPolicy2 => 'zásadami ochrany osobních údajů';

  @override
  String get feedbackPrivacyPolicy3 => '.';

  @override
  String get feedbackSentDescription => 'Děkujeme vám za pomoc při vylepšování této aplikace!';

  @override
  String get feedbackSentTitle => 'Zpětná vazba odeslána';

  @override
  String get feedbackTitle => 'Vaše zpětná vazba je vždy vítána!';

  @override
  String get fileSavedToDownloadsFolder => 'Soubor uložen do složky Stažené soubory';

  @override
  String get finalizationState => 'Stav finalizace';

  @override
  String get finalizeContainerFailed => 'Finalizace kontejneru se nezdařila';

  @override
  String get firebaseToken => 'Token Firebase';

  @override
  String get folderName => 'Název složky';

  @override
  String get generatingPhonePart => 'Generování klientské části';

  @override
  String get gitHubButton => 'Tato aplikace má otevřený zdrojový kód\nNavštivte nás na GitHub';

  @override
  String get goToSettingsButton => 'Otevřít nastavení';

  @override
  String get goToSettingsDescription => 'Není nastaveno přihlášení zámkem zařízení ani biometrické ověření. Aktivujte je v nastavení zařízení.';

  @override
  String get grantCameraPermissionDialogButton => 'Udělit oprávnění';

  @override
  String get grantCameraPermissionDialogContent => 'Please grant camera permission to scan QR codes.';

  @override
  String get grantCameraPermissionDialogPermanentlyDenied => 'Oprávnění kamery je trvale odepřeno. Udělte prosím oprávnění fotoaparátu v nastavení telefonu.';

  @override
  String get grantCameraPermissionDialogTitle => 'Camera permission is not granted';

  @override
  String get handshakeFailed => 'Handshake se nezdařil';

  @override
  String get hidePushTokens => 'Skrýt push tokeny';

  @override
  String get hidePushTokensDescription => 'Skrýt push tokeny ze seznamu tokenů. Tím se tokeny neodstraní a budou stále viditelné na samostatné obrazovce.';

  @override
  String get imageUrl => 'URL obrázku';

  @override
  String importConflictToken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Je konflikt s tokeny, které již existují.\nProsím, vyberte, který z nich chcete zachovat.',
      one: 'Je konflikt s tokeny, které již existují.\nProsím, vyberte, který z nich chcete zachovat.',
      zero: 'Není žádný konflikt s tokeny, které již existují.',
    );
    return '$_temp0';
  }

  @override
  String importExistingToken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count byly nalezeny tokeny, které se již v aplikaci nacházejí.',
      one: 'Byl nalezen token, který již v aplikaci existuje.',
      zero: 'Nebyl nalezen žádný token, který by se již v aplikaci nacházel.',
    );
    return '$_temp0';
  }

  @override
  String get importExportTokens => 'Import/Exportovat žetony';

  @override
  String importFailedToken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nepodařilo se importovat $count tokenů.',
      one: 'Nepodařilo se importovat token.',
      zero: 'Žádný token Nepodařilo se importovat.',
    );
    return '$_temp0';
  }

  @override
  String get importHint2FAS => 'Vyberte zálohu 2FAS.\nPokud nemáte zálohu, vytvořte ji v aplikaci 2FAS. Doporučujeme použít heslo.';

  @override
  String get importHintAegisBackupFile => 'Vyberte svůj export Aegis (.JSON).\nPokud nemáte export, vytvořte si jej prostřednictvím nabídky nastavení v aplikaci Aegis. Doporučujeme použít heslo.';

  @override
  String get importHintAegisLink => 'Zadejte odkaz, který obdržíte při přenosu záznamů ze systému Aegis.';

  @override
  String get importHintAegisQrScan => 'Naskenujte QR kód, který obdržíte při přenosu záznamů z aplikace Aegis.';

  @override
  String get importHintAuthenticatorProFile => 'Chcete-li vytvořit zálohu aplikace Authenticator Pro, přejděte do nastavení a klepněte na položku \"Automatické zálohování\". Vyberte umístění úložiště a nastavte heslo. Poté stiskněte \"Zálohovat nyní\" a exportujte tokeny.';

  @override
  String get importHintFreeOtpPlusFile => 'Chcete-li vytvořit zálohu aplikace FreeOTP+, klepněte na tři tečky v pravém horním rohu a vyberte možnost \"Exportovat\". Můžete si vybrat mezi formátem JSON a URI. Zálohu doporučujeme po importu odstranit, protože není šifrovaná.';

  @override
  String get importHintFreeOtpPlusQrScan => 'Naskenujte QR kód, který obdržíte po stisknutí tří teček na dlaždici tokenu, a vyberte možnost \"Sdílet QR kód\".';

  @override
  String get importHintGoogleQrFile => 'Vyberte obrazový soubor s QR kódem, který obdržíte při exportu účtů z Google Authenticator.\n!! Upozorňujeme, že není bezpečné ukládat QR kód do zařízení, protože tokeny nejsou šifrovány !!';

  @override
  String get importHintGoogleQrScan => 'Naskenujte QR kód, který obdržíte při exportu účtů z Google Authenticator.';

  @override
  String get importHintPrivacyIdeaFile => 'Chcete-li vytvořit zálohu, přejděte do nastavení a klepněte na položku \"Export\". Vyberte \"Jako soubor\" a vyberte tokeny, které chcete exportovat. Potom klepněte na \"Exportovat\" a nastavte heslo. Úložištěm je složka pro stahování ve vašem zařízení.';

  @override
  String get importHintPrivacyIdeaQrScan => 'Chcete-li vytvořit QR kódy žetonů, přejděte do nastavení a klepněte na \"Export\". Poté vyberte \"Jako QR kód\" a klepněte na token, který chcete exportovat. Tato varianta je vhodná pouze pro přímý přenos do jiného zařízení, protože QR kód není šifrovaný.';

  @override
  String importNTokens(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importovat $count tokenů',
      one: 'Importovat jeden token',
      zero: 'Neimportujte žádné tokeny',
    );
    return '$_temp0';
  }

  @override
  String importNewToken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bylo nalezeno $count nových tokenů, které lze importovat.',
      one: 'Byl nalezen nový token, který lze importovat.',
      zero: 'Nebyl nalezen žádný nový token.',
    );
    return '$_temp0';
  }

  @override
  String get importTokens => 'Importní token';

  @override
  String get importantInformationTitle => 'Important information';

  @override
  String get importedVia => 'Dovezeno prostřednictvím';

  @override
  String get increaseCounter => 'Zvýšit počítadla';

  @override
  String internalServerError(String code) {
    return 'Interní chyba serveru ($code)';
  }

  @override
  String get introAddFolder => 'Můžete vytvářet složky pro uspořádání svých tokenů.';

  @override
  String get introAddTokenManually => 'Pokud nechcete skenovat QR kód, můžete tokeny přidávat také ručně.';

  @override
  String get introDragToken => 'Reorganizujte tokeny tak, že je na několik sekund stisknete a poté je přetáhnete na požadované místo.';

  @override
  String get introEditToken => 'Zde můžete upravit název tokenu a zobrazit některé podrobnosti.';

  @override
  String get introHidePushTokens => 'Vaše push tokeny jsou nyní skryté.\nNa obrazovce push tokenů je však stále vidíte.';

  @override
  String get introLockToken => 'To improve security even more, you can lock tokens. Then the token can only be used after authentication.';

  @override
  String get introPollForChallenges => 'Můžete zkontrolovat nové výzvy přetažením seznamu tokenů dolů.';

  @override
  String get introScanQrCode => 'Podporujeme všechny běžné dvoufaktorové autentizační tokeny a také tokeny privacyIDEA.';

  @override
  String get introTokenSwipe => 'Přejetím po tokenech doleva zobrazíte dostupné akce.';

  @override
  String invalidBackupFile(String appName) {
    return 'Vybraný soubor není platnou zálohou $appName.';
  }

  @override
  String invalidLink(String appName) {
    return 'Zadaný odkaz není platným tokenem $appName nebo není podporován.';
  }

  @override
  String invalidQrFile(String appName) {
    return 'Vybraný soubor neobsahuje platný QR kód z $appName.';
  }

  @override
  String invalidQrScan(String appName) {
    return 'Naskenovaný QR kód není platnou zálohou $appName.';
  }

  @override
  String get invalidUrl => 'Neplatná adresa URL';

  @override
  String invalidValue(String parameter, String type, String value) {
    return 'Typ $type \'$value\' není platný pro \'$parameter\'.';
  }

  @override
  String invalidValueIn(String map, String parameter, String type, String value) {
    return '$type \'$value\' není platný pro \'$parameter\' v \'$map\'.';
  }

  @override
  String get isExpotableQuestion => 'Lze exportovat?';

  @override
  String get isPiTokenQuestion => 'Je to token privacyIDEA?';

  @override
  String get issuer => 'Vydavatel';

  @override
  String issuerLabel(String name) {
    return 'Vydavatel: $name';
  }

  @override
  String get language => 'Jazyk';

  @override
  String get legacySigningErrorMessage => 'Token byl vytvořen v zastaralé verzi aplikace, což může vést k problémům při jeho používání.\nPokud problém přetrvává, doporučujeme vytvořit nový push token!';

  @override
  String legacySigningErrorTitle(String tokenLabel) {
    return 'Při použití staršího tokenu došlo k chybě: $tokenLabel';
  }

  @override
  String get licensesAndVersion => 'Licence a verze';

  @override
  String get linkMustOtpAuth => 'Odkaz musí začínat otpauth://';

  @override
  String get linkedContainer => 'Propojený kontejner';

  @override
  String get lock => 'Zamknout';

  @override
  String get lockOut => 'Biometrické ověření je deaktivováno. Pro aktivaci zamkněte a znovu odemkněte obrazovku/zařízení.';

  @override
  String get logMenu => 'Nabídka protokolu';

  @override
  String get malformedData => 'Data nejsou ve správném formátu';

  @override
  String get markQrCode => 'Označte QR kód';

  @override
  String missingRequiredParameter(String parameter) {
    return 'Hodnota parametru [$parameter] je povinná, ale chybí.';
  }

  @override
  String missingRequiredParameterIn(String map, String parameter) {
    return 'Hodnota parametru [$parameter] je povinná, ale v \"$map\" chybí.';
  }

  @override
  String mustNotBeEmpty(String field) {
    return '$field nesmí být prázdné';
  }

  @override
  String get name => 'Název';

  @override
  String get no => 'Ne';

  @override
  String get noFbToken => 'Není k dispozici žádný token Firebase.';

  @override
  String get noMailAppDescription => 'There is no e-mail app installed or initialised on this device, please try again when you are able to send an email message.';

  @override
  String get noMailAppTitle => 'Není nainstalována žádná e-mailová aplikace';

  @override
  String get noNetworkConnection => 'Žádné připojení k síti.';

  @override
  String get noPublicKey => 'Není k dispozici žádný veřejný klíč.';

  @override
  String get noResultText1 => 'stiskněte tlačítko ';

  @override
  String get noResultText2 => ' a začněte s používáním.';

  @override
  String get noResultTitle => 'Nejsou nainstalovány žádné tokeny.';

  @override
  String get noTokenToExport => 'Pro export není k dispozici žádný token';

  @override
  String get noTokenToImport => 'Nebyl nalezen žádný token pro import';

  @override
  String get notAnInteger => 'Hodnota není celé číslo.';

  @override
  String get notAnNumber => 'Hodnota není číslo.';

  @override
  String get ok => 'Ok';

  @override
  String get open => 'Otevřít';

  @override
  String get originApp => 'Aplikace Origin';

  @override
  String get originDetails => 'Podrobnosti o původu';

  @override
  String otpValueCopiedMessage(String otpValue) {
    return 'Heslo \"$otpValue\" bylo zkopírováno do schránky.';
  }

  @override
  String get password => 'Heslo';

  @override
  String get passwordCannotBeEmpty => 'Heslo nesmí být prázdné';

  @override
  String get passwordCannotContainWhitespace => 'Heslo nesmí obsahovat mezery';

  @override
  String get passwordMustBeAtLeast8Characters => 'Heslo musí obsahovat alespoň 8 znaků';

  @override
  String get passwordMustContainLowercaseLetter => 'Heslo musí obsahovat malé písmeno';

  @override
  String get passwordMustContainNumber => 'Heslo musí obsahovat číslo';

  @override
  String get passwordMustContainSpecialCharacter => 'Heslo musí obsahovat speciální znak';

  @override
  String get passwordMustContainUppercaseLetter => 'Heslo musí obsahovat velké písmeno';

  @override
  String get passwordsDoNotMatch => 'Hesla se neshodují';

  @override
  String get patchNotesBugFixes => 'Opravy chyb';

  @override
  String get patchNotesDialogTitle => 'Co je nového?';

  @override
  String get patchNotesImprovements => 'Improvements';

  @override
  String get patchNotesNewFeatures => 'Nové funkce';

  @override
  String get patchNotesV4_3_0NewFeatures1 => 'Přidána podpora pro import tokenů z Google, Aegis a 2FAS Authenticator. Další zdroje importu budou přidány v budoucnu.';

  @override
  String get patchNotesV4_3_0NewFeatures2 => 'Do nastavení byla přidána možnost zpětné vazby.';

  @override
  String get patchNotesV4_3_0NewFeatures3 => 'Tokeny Push lze nyní skrýt ze seznamu tokenů.';

  @override
  String get patchNotesV4_3_0NewFeatures4 => 'Byly přidány úvodní informace, které novým uživatelům usnadní začátky.';

  @override
  String get patchNotesV4_3_0NewFeatures5 => 'Žetony nyní můžete vyhledávat klepnutím na lupu v pravém horním rohu.';

  @override
  String get patchNotesV4_3_0NewFeatures6 => 'Přidán token HomeWidget pro systém Android 12 a novější.';

  @override
  String get patchNotesV4_3_1BugFix1 => 'Opraven problém, kdy nebyla zobrazena hodnota otp po ověření na některých zařízeních.';

  @override
  String get patchNotesV4_3_1Improvement1 => 'Skener QR kódů byl vylepšen.';

  @override
  String get patchNotesV4_4_0Improvement1 => 'Byly přidány další dovozní zdroje.';

  @override
  String get patchNotesV4_4_0Improvement2 => 'Bylo vylepšeno rozpoznávání QR kódů z obrazových souborů.';

  @override
  String get patchNotesV4_4_0NewFeatures1 => 'Nyní je možné exportovat tokeny, u kterých lze zajistit, že se nejedná o tokeny privacyIDEA. V současné době nelze vyloučit, že tokeny přidané prostřednictvím čtečky QR kódů pocházejí z aplikace privacyIDEA. Rozlišování bude v budoucích verzích vylepšeno.';

  @override
  String get patchNotesV4_4_0NewFeatures2 => 'Přidána podpora pro \"require presence\" aplikace privacyIDEA.';

  @override
  String get patchNotesV4_4_2Improvement1 => 'Přidána podpora svítilny pro skenování QR kódů.';

  @override
  String get patchNotesV4_4_2NewFeatures1 => 'Žetony lze nyní vkládat pomocí kopírování a vkládání.';

  @override
  String get patchNotesV4_4_2NewFeatures2 => 'Přidána podpora galerie pro skenování QR kódů.';

  @override
  String get period => 'Časový interval';

  @override
  String get phonePart => 'Klientská část:';

  @override
  String piServerCode(String code) {
    return 'Kód serveru PI: $code';
  }

  @override
  String get pleaseEnterANameForThisToken => 'Vložte název pro tento token.';

  @override
  String get pleaseEnterASecretForThisToken => 'Vložte tajný klíč pro tento token.';

  @override
  String get pollingFailed => 'Dotaz se nezdařil.';

  @override
  String pollingFailedFor(String serial) {
    return 'Dotaz na $serial se nezdařil.';
  }

  @override
  String get privacyPolicy => 'Zásady ochrany osobních údajů';

  @override
  String get publicKey => 'Veřejný klíč';

  @override
  String get pushEndpointUrl => 'URL koncového bodu push';

  @override
  String get pushRequestParseError => 'Požadavek na odeslání se nepodařilo zpracovat.';

  @override
  String get pushToken => 'Push notifikace';

  @override
  String get qrFileDecodeError => 'Z vybraného obrázku nebylo možné dekódovat QR kód, použijte prosím místo toho skener QR kódů.';

  @override
  String get qrInFileNotFound => 'Ve vybraném obrázku nebyl nalezen žádný QR kód.';

  @override
  String get qrInFileNotFound2 => 'Můžete mi ukázat, kde se QR kód nachází.';

  @override
  String get qrInFileNotFound3 => 'Předpokládám, že kód najdu, pokud se nachází uprostřed označené oblasti.';

  @override
  String get qrNotFound => 'Žádný QR kód nebyl nalezen!';

  @override
  String get rename => 'Přejmenovat';

  @override
  String get renameToken => 'Přejmenovat token';

  @override
  String get renameTokenFolder => 'Přejmenování složky';

  @override
  String get replaceButton => 'Vyměňte';

  @override
  String requestInfo(String account, String issuer) {
    return 'Odesláno $issuer pro váš účet: \"$account\"';
  }

  @override
  String get requestPushChallengesPeriodically => 'Periodicky získávat výzvy ze serveru. Povolte pokud nefunguje příjem push notifikací.';

  @override
  String get requestTriggerdByUserQuestion => 'Byl tento požadavek vyvolán vámi?';

  @override
  String get retryRolloutButton => 'Zkusit znovu';

  @override
  String get rolloutStateCompleted => 'Zavedení dokončeno';

  @override
  String get rolloutStateGeneratingKeyPair => 'Generování páru klíčů';

  @override
  String get rolloutStateGeneratingKeyPairCompleted => 'Generování páru klíčů dokončeno';

  @override
  String get rolloutStateGeneratingKeyPairFailed => 'Nepodařilo se vygenerovat pár klíčů';

  @override
  String get rolloutStateNotStarted => 'Začít zavádění';

  @override
  String get rolloutStateParsingResponse => 'Rozbor odpovědi';

  @override
  String get rolloutStateParsingResponseCompleted => 'Parsování odpovědi dokončeno';

  @override
  String get rolloutStateParsingResponseFailed => 'Parsování odpovědi se nezdařilo';

  @override
  String get rolloutStateSendingPublicKey => 'Odeslání veřejného klíče';

  @override
  String get rolloutStateSendingPublicKeyCompleted => 'Odeslání veřejného klíče dokončeno';

  @override
  String get rolloutStateSendingPublicKeyFailed => 'Odeslání veřejného klíče se nezdařilo';

  @override
  String get saveButton => 'Uložit';

  @override
  String get scanQrCode => 'Naskenovat QR kód';

  @override
  String get scanThisQrWithNewDevice => 'Naskenujte tento QR kód svým novým zařízením pro import žetonu.';

  @override
  String get secondsUntilNextOTP => 'Sekundy do dalšího OTP';

  @override
  String get secretIsRequired => 'Tajné je vyžadováno';

  @override
  String get secretKey => 'Tajný klíč';

  @override
  String get selectFile => 'Vybrat soubor';

  @override
  String get selectImportSource => 'Vyberte zdroj importu';

  @override
  String get selectImportType => 'Jak chcete importovat žetony?';

  @override
  String selectTokensToExport(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vyberte žetony k exportu',
      one: 'Vyberte žeton k exportu',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get selectTokensToExportHelpContent1 => 'Pokud token není uveden v seznamu, není zaručeno, že se nejedná o token privacyIDEA.';

  @override
  String get selectTokensToExportHelpContent2 => 'V současné době lze exportovat pouze ručně přidané a importované tokeny.';

  @override
  String get selectTokensToExportHelpContent3 => 'Pracujeme na řešení, které by umožnilo rozlišovat mezi tokeny privacyIDEA a soukromými tokeny.';

  @override
  String get selectTokensToExportHelpContent4 => 'Nový QR kód můžete získat od služby, od které jste token obdrželi.';

  @override
  String get selectTokensToExportHelpTitle => 'Není váš token uveden?';

  @override
  String get send => 'Odeslat';

  @override
  String get sendErrorDialogBody => 'V aplikaci se vyskytla neznámá chyba. Informace uvedené níže mohou být odeslány vývojářům e-mailem pro vyřešení chyby v budoucnu.';

  @override
  String get sendErrorLogDescription => 'Vytvoří se připravený e-mail.\nObsahuje informace o aplikaci, chybě a zařízení.\nPřed odesláním můžete e-mail upravit.\nZde se můžete podívat, jak informace používáme:';

  @override
  String get sendPushRequestResponseFailed => 'Odpověď se nepodařilo odeslat.';

  @override
  String get serverNotReachable => 'Na server se nepodařilo dovolat.';

  @override
  String get settings => 'Nastavení';

  @override
  String get settingsGroupGeneral => 'Obecné informace';

  @override
  String get showDetails => 'Zobrazit podrobnosti';

  @override
  String get showErrorLog => 'Zobrazit';

  @override
  String get showPrivacyPolicy => 'Zobrazit zásady ochrany osobních údajů';

  @override
  String get signInTitle => 'Vyžadováno přihlášení';

  @override
  String get someTokensDoNotSupportPolling => 'Některé tokeny jsou zastaralé a nepodporují polling';

  @override
  String statusCode(int statusCode) {
    return 'Stavový kód: $statusCode';
  }

  @override
  String get sync => 'Synchronizovat';

  @override
  String get syncContainerFailed => 'Synchronizace kontejneru se nezdařila';

  @override
  String get syncFbTokenFailed => 'Synchronizace následujících tokenů selhala, zkuste to znovu:';

  @override
  String get syncFbTokenManuallyWhenNetworkIsAvailable => 'Synchronizujte prosím push tokeny ručně prostřednictvím nastavení, když je k dispozici síťové připojení.';

  @override
  String get syncState => 'Stav synchronizace';

  @override
  String get syncStateCompletedDescription => 'Synchronizace dokončena';

  @override
  String get syncStateFailedDescription => 'Synchronizace selhala';

  @override
  String get syncStateNotStartedDescription => 'Synchronizace nebyla spuštěna';

  @override
  String get syncStateSyncingDescription => 'Aktuálně synchronizováno';

  @override
  String get synchronizePushTokens => 'Synchronizace push tokenů';

  @override
  String get synchronizesTokensWithServer => 'Synchronizovat tokeny se serverem privacyIDEA.';

  @override
  String get synchronizingTokens => 'Tokeny se synchronizují.';

  @override
  String get theSecretDoesNotFitTheCurrentEncoding => 'Tajný klíč neodpovídá zvolenému kódování.';

  @override
  String get theme => 'Vzhled';

  @override
  String get timeOut => 'Časový limit';

  @override
  String get tokenDataParseError => 'Tokenová data nelze analyzovat';

  @override
  String get tokenDetails => 'Podrobnosti o tokenu';

  @override
  String get tokenLinkImport => 'Token link';

  @override
  String get tokenSerial => 'Token serial';

  @override
  String get tokensAreEncrypted => 'Tokeny jsou zašifrované. Please enter the password to decrypt them.';

  @override
  String get tokensDoNotSupportSynchronization => 'Následující tokeny nepodporují synchronizaci a musí být znovu zaregistrovány:';

  @override
  String get tokensSuccessfullyDecrypted => 'Tokeny byly úspěšně dešifrovány a nyní je lze importovat.';

  @override
  String get type => 'Typ';

  @override
  String get unexpectedError => 'Nastala neočekávaná chyba.';

  @override
  String get unknown => 'Neznámý';

  @override
  String get unlock => 'Odemknout';

  @override
  String unsupported(String name, String value) {
    return 'Příkaz $name [$value] není touto verzí aplikace podporován.';
  }

  @override
  String get useDeviceLocaleDescription => 'Použít jazyk zařízení, pokud je podporován, případně angličtinu.';

  @override
  String get useDeviceLocaleTitle => 'Použít jazyk zařízení';

  @override
  String valueNotAllowed(String parameter, String type, String value) {
    return 'Typ $type „$value“ není povolenou hodnotou pro „$parameter“';
  }

  @override
  String valueNotAllowedIn(String map, String parameter, String type, String value) {
    return 'Typ $type „$value“ není povolenou hodnotou pro „$parameter“ v „$map“';
  }

  @override
  String get verboseLogging => 'Zevrubné protokolování';

  @override
  String get versionTitle => 'Verze';

  @override
  String get wrongPassword => 'Nesprávné heslo';

  @override
  String get yes => 'Ano';
}
