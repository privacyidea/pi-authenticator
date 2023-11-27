import 'app_localizations.dart';

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get accept => 'Přijmout';

  @override
  String get decline => 'Odmítnout';

  @override
  String get name => 'Název';

  @override
  String get secretKey => 'Tajný klíč';

  @override
  String get encoding => 'Kódování';

  @override
  String get algorithm => 'Algoritmus';

  @override
  String get digits => 'Počet číslic';

  @override
  String get type => 'Typ';

  @override
  String get period => 'Časový interval';

  @override
  String get rename => 'Přejmenovat';

  @override
  String get cancel => 'Zrušit';

  @override
  String get delete => 'Smazat';

  @override
  String get dismiss => 'Zavřít';

  @override
  String get addToken => 'Přidat token';

  @override
  String get scanQrCode => 'Naskenovat QR kód';

  @override
  String get enterDetailsForToken => 'Vložte podrobnosti tokenu';

  @override
  String get pleaseEnterANameForThisToken => 'Vložte název pro tento token.';

  @override
  String get pleaseEnterASecretForThisToken => 'Vložte tajný klíč pro tento token.';

  @override
  String get theSecretDoesNotFitTheCurrentEncoding => 'Tajný klíč neodpovídá zvolenému kódování.';

  @override
  String get renameToken => 'Přejmenovat token';

  @override
  String get confirmDeletion => 'Potvrdit smazání';

  @override
  String confirmDeletionOf(Object name) {
    return 'Opravdu chcete smazat token $name?';
  }

  @override
  String get generatingPhonePart => 'Generování klientské části';

  @override
  String get phonePart => 'Klientská část:';

  @override
  String otpValueCopiedMessage(Object otpValue) {
    return 'Heslo \"$otpValue\" bylo zkopírováno do schránky.';
  }

  @override
  String get settings => 'Nastavení';

  @override
  String get pushToken => 'Push notifikace';

  @override
  String get theme => 'Vzhled';

  @override
  String get lightTheme => 'Světlý';

  @override
  String get darkTheme => 'Tmavý';

  @override
  String get systemTheme => 'Použít nastavení systému';

  @override
  String get enablePolling => 'Povolit polling';

  @override
  String get requestPushChallengesPeriodically => 'Periodicky získávat výzvy ze serveru. Povolte pokud nefunguje příjem push notifikací.';

  @override
  String get synchronizePushTokens => 'Synchronizace push tokenů';

  @override
  String get synchronizesTokensWithServer => 'Synchronizovat tokeny se serverem privacyIDEA.';

  @override
  String get sync => 'Synchronizovat';

  @override
  String get synchronizingTokens => 'Tokeny se synchronizují.';

  @override
  String get allTokensSynchronized => 'Všechny tokeny jsou synchronizované.';

  @override
  String get synchronizationFailed => 'Synchronizace následujících tokenů selhala, zkuste to znovu:';

  @override
  String get tokensDoNotSupportSynchronization => 'Následující tokeny nepodporují synchronizaci a musí být znovu zaregistrovány:';

  @override
  String errorRollOutFailed(Object name) {
    return 'Registrace tokenu $name selhala.';
  }

  @override
  String statusCode(Object statusCode) {
    return 'Stavový kód: $statusCode';
  }

  @override
  String get errorSynchronizationNoNetworkConnection => 'Synchronizace tokenů selhala, připojení k serveru privacyIDEA se nezdařilo.';

  @override
  String errorRollOutNoConnectionToServer(Object name) {
    return 'Registrace tokenu $name selhala. Server není dostupný.';
  }

  @override
  String errorRollOutUnknownError(Object e) {
    return 'Vyskytla se neznámá chyba. Registrace není možná: $e';
  }

  @override
  String get rollingOut => 'Registrace';

  @override
  String get pollingChallenges => 'Čekám na nové požadavky';

  @override
  String get unexpectedError => 'Nastala neočekávaná chyba.';

  @override
  String get pollingFailed => 'Dotaz se nezdařil.';

  @override
  String pollingFailedFor(Object serial) {
    return 'Dotaz na $serial se nezdařil.';
  }

  @override
  String get noNetworkConnection => 'Žádné připojení k síti.';

  @override
  String get connectionFailed => 'Připojení se nezdařilo.';

  @override
  String get checkYourNetwork => 'Zkontrolujte prosím síťové připojení a zkuste to znovu.';

  @override
  String get serverNotReachable => 'Na server se nepodařilo dovolat.';

  @override
  String get couldNotSignMessage => 'Zprávu se nepodařilo podepsat.';

  @override
  String get useDeviceLocaleTitle => 'Použít jazyk zařízení';

  @override
  String get useDeviceLocaleDescription => 'Použít jazyk zařízení, pokud je podporován, případně angličtinu.';

  @override
  String get language => 'Jazyk';

  @override
  String get authenticateToShowOtp => 'Pro zobrazení jednorázového kódu se přihlaste.';

  @override
  String get authenticateToUnLockToken => 'Pro změnu uzamčení tokenu se přihlaste.';

  @override
  String get biometricRequiredTitle => 'Biometrické ověření není nastaveno';

  @override
  String get biometricHint => 'Vyžadováno přihlášení';

  @override
  String get biometricNotRecognized => 'Ověření se nezdařilo. Zkuste to znovu.';

  @override
  String get biometricSuccess => 'Přihlášení bylo úspěšné';

  @override
  String get deviceCredentialsRequiredTitle => 'Není nastaven zámek zařízení';

  @override
  String get deviceCredentialsSetupDescription => 'Nastave zámek zařízení v nastavení zařízení';

  @override
  String get signInTitle => 'Vyžadováno přihlášení';

  @override
  String get goToSettingsButton => 'Otevřít nastavení';

  @override
  String get goToSettingsDescription => 'Není nastaveno přihlášení zámkem zařízení ani biometrické ověření. Aktivujte je v nastavení zařízení.';

  @override
  String get lockOut => 'Biometrické ověření je deaktivováno. Pro aktivaci zamkněte a znovu odemkněte obrazovku/zařízení.';

  @override
  String get authNotSupportedTitle => 'Vyžadován zámek zařízení nebo biometrické ověření';

  @override
  String get authNotSupportedBody => 'Tato akce vyžaduje, aby bylo zařízení chráněno zámkem zařízení nebo biometrickým ověřením.';

  @override
  String get lock => 'Zamknout';

  @override
  String get unlock => 'Odemknout';

  @override
  String get noResultTitle => 'Nejsou nainstalovány žádné tokeny.';

  @override
  String get noResultText1 => 'stiskněte tlačítko ';

  @override
  String get noResultText2 => ' a začněte s používáním.';

  @override
  String onBoardingTitle1(Object appName) {
    return '$appName';
  }

  @override
  String get onBoardingText1 => 'vícefázové ověření\nusnadněno';

  @override
  String get onBoardingTitle2 => 'Maximální Bezpečnost';

  @override
  String get onBoardingText2 => 'Uložte tokeny do svého zařízení\nchráněné biometrickým ověřením';

  @override
  String get onBoardingTitle3 => 'Navštivte náš profil Github';

  @override
  String get onBoardingText3 => 'Tuto aplikaci má open source';

  @override
  String get errorLogTitle => 'Protokol chyb';

  @override
  String get logMenu => 'Nabídka protokolu';

  @override
  String get sendErrorLog => 'Odeslat chybové hlášení';

  @override
  String get sendErrorLogDescription => 'Vytvoří se připravený e-mail.\nObsahuje informace o aplikaci, chybě a zařízení.\nPřed odesláním můžete e-mail upravit.';

  @override
  String get showPrivacyPolicy => 'Zobrazit zásady ochrany osobních údajů';

  @override
  String get errorLogEmpty => 'Protokol chyb je prázdný.';

  @override
  String get verboseLogging => 'Podrobný protokol';

  @override
  String get errorLogCleared => 'Protokol chyb vymazán.';

  @override
  String get ok => 'Ok';

  @override
  String get noLogToSend => 'Je třeba odeslat protokol.';

  @override
  String get errorMailBody => 'Přiložen je soubor protokolu o chybách.\nTento text můžete nahradit dalšími informacemi o chybě.';

  @override
  String get showDetails => 'Zobrazit podrobnosti';

  @override
  String get open => 'Otevřít';

  @override
  String get sendErrorDialogBody => 'V aplikaci se vyskytla neznámá chyba. Informace uvedené níže mohou být odeslány vývojářům e-mailem pro vyřešení chyby v budoucnu.';

  @override
  String get noFbToken => 'Není k dispozici žádný token Firebase.';

  @override
  String get firebaseToken => 'Token Firebase';

  @override
  String get noPublicKey => 'Není k dispozici žádný veřejný klíč.';

  @override
  String get publicKey => 'Veřejný klíč';

  @override
  String get editToken => 'Upravit token';

  @override
  String get edit => 'Upravit';

  @override
  String get save => 'Uložit';

  @override
  String get validFor => 'Platné pro';

  @override
  String get validUntil => 'Platné do';

  @override
  String get deleteLockedToken => 'Prosím, autentifikujte se pro smazání uzamčeného tokenu.';

  @override
  String get editLockedToken => 'Prosím, autentifikujte se pro úpravu uzamčeného tokenu.';

  @override
  String get uncollapseLockedFolder => 'Chcete-li otevřít uzamčenou složku, ověřte se.';

  @override
  String get renameTokenFolder => 'Přejmenování složky';

  @override
  String get addANewFolder => 'Vytvoření nové složky';

  @override
  String get folderName => 'Název složky';

  @override
  String get retryRollout => 'Zkusit znovu';

  @override
  String get generatingRSAKeyPair => 'Generování párů klíčů RSA';

  @override
  String get generatingRSAKeyPairFailed => 'Generování páru klíčů RSA se nezdařilo';

  @override
  String get sendingRSAPublicKey => 'Odeslání veřejného klíče RSA';

  @override
  String get sendingRSAPublicKeyFailed => 'Nepodařilo se odeslat veřejný klíč RSA';

  @override
  String get parsingResponse => 'Rozbor odpovědi';

  @override
  String get parsingResponseFailed => 'Parsování odpovědi se nezdařilo';

  @override
  String get rolloutCompleted => 'Zavedení dokončeno';

  @override
  String get authToAcceptPushRequest => 'Pro přijetí požadavku na push notifikaci se přihlaste.';

  @override
  String get authToDeclinePushRequest => 'Pro odmítnutí požadavku na push notifikaci se přihlaste.';

  @override
  String get pushRequestParseError => 'Požadavek na odeslání se nepodařilo zpracovat.';

  @override
  String get imageUrl => 'URL obrázku';

  @override
  String get errorRollOutSSLHandshakeFailed => 'SSL handshake se nezdařil. Roll-out není možný.';

  @override
  String errorWhenPullingChallenges(Object name) {
    return 'Při dotazování na výzvy $name došlo k chybě.';
  }

  @override
  String errorRollOutTokenExpired(Object name) {
    return 'Roll-out tohoto tokenu již není možný.\nPlatnost tokenu $name vypršela.';
  }

  @override
  String get yes => 'Ano';

  @override
  String get no => 'Ne';

  @override
  String get butDiscardIt => 'ale zahodit jej';

  @override
  String get declineIt => 'odmítnout jej ';

  @override
  String get requestTriggerdByUserQuestion => 'Byl tento požadavek vyvolán vámi?';

  @override
  String get grantCameraPermissionDialogTitle => 'Camera permission is not granted';

  @override
  String get grantCameraPermissionDialogContent => 'Please grant camera permission to scan QR codes.';

  @override
  String get grantCameraPermissionDialogPermanentlyDenied => 'Oprávnění kamery je trvale odepřeno. Udělte prosím oprávnění fotoaparátu v nastavení telefonu.';

  @override
  String get grantCameraPermissionDialogButton => 'Udělit oprávnění';

  @override
  String get decryptErrorTitle => 'Chyba dešifrování';

  @override
  String get decryptErrorContent => 'Bohužel se aplikaci nepodařilo dešifrovat vaše tokeny. To znamená, že šifrovací klíč je poškozen. Můžete to zkusit znovu nebo odstranit data aplikace, čímž by došlo k odstranění tokenů v aplikaci.';

  @override
  String get decryptErrorButtonDelete => 'Odstranit';

  @override
  String get decryptErrorButtonSendError => 'Odeslat chybu';

  @override
  String get decryptErrorButtonRetry => 'Opakování';

  @override
  String get decryptErrorDeleteConfirmationContent => 'Jste si jisti, že chcete data aplikace odstranit?';

  @override
  String get hidePushTokens => 'Skrýt push tokeny';

  @override
  String get hidePushTokensDescription => 'Skrýt push tokeny ze seznamu tokenů. Tím se tokeny neodstraní a budou stále viditelné na samostatné obrazovce.';

  @override
  String get settingsGroupGeneral => 'Obecné informace';

  @override
  String get licensesAndVersion => 'Licence a verze';

  @override
  String get privacyPolicy => 'Zásady ochrany osobních údajů';
}
