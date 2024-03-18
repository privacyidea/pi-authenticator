import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get patchNotesNewFeatures => 'Nové funkce';

  @override
  String get patchNotesImprovements => 'Improvements';

  @override
  String get patchNotesBugFixes => 'Opravy chyb';

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
  String get confirmTokenDeletionHint => 'Pokud tento token odstraníte, nebude již možné se přihlásit.\nProsím, ujistěte se, že se můžete přihlásit k přidruženému účtu bez tohoto tokenu.';

  @override
  String get confirmFolderDeletionHint => 'Odstranění složky nemá žádný vliv na tokeny v ní.\nTokeny jsou přesunuty do hlavního seznamu.';

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
  String get showErrorLog => 'Zobrazit';

  @override
  String get clearErrorLog => 'Vymazat';

  @override
  String get send => 'Odeslat';

  @override
  String get sendErrorLogDescription => 'Vytvoří se připravený e-mail.\nObsahuje informace o aplikaci, chybě a zařízení.\nPřed odesláním můžete e-mail upravit.\nZde se můžete podívat, jak informace používáme:';

  @override
  String get showPrivacyPolicy => 'Zobrazit zásady ochrany osobních údajů';

  @override
  String get errorLogEmpty => 'Protokol chyb je prázdný.';

  @override
  String get verboseLogging => 'Zevrubné protokolování';

  @override
  String get errorLogCleared => 'Protokol chyb vymazán.';

  @override
  String get ok => 'Ok';

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
  String get create => 'Vytvořit';

  @override
  String get validFor => 'Platné pro';

  @override
  String get validUntil => 'Platné do';

  @override
  String get deleteLockedToken => 'Prosím, autentifikujte se pro smazání uzamčeného tokenu.';

  @override
  String get editLockedToken => 'Prosím, autentifikujte se pro úpravu uzamčeného tokenu.';

  @override
  String get expandLockedFolder => 'Chcete-li otevřít uzamčenou složku, ověřte se.';

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
  String get errorRollOutNotPossibleAnymore => 'Roll-out tohoto tokenu již není možný.';

  @override
  String errorTokenExpired(Object name) {
    return 'Platnost tokenu $name vypršela.';
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

  @override
  String get introScanQrCode => 'Podporujeme všechny běžné dvoufaktorové autentizační tokeny a také tokeny privacyIDEA.';

  @override
  String get introAddTokenManually => 'Pokud nechcete skenovat QR kód, můžete tokeny přidávat také ručně.';

  @override
  String get introTokenSwipe => 'Přejetím po tokenech doleva zobrazíte dostupné akce.';

  @override
  String get introEditToken => 'Zde můžete upravit název tokenu a zobrazit některé podrobnosti.';

  @override
  String get introLockToken => 'To improve security even more, you can lock tokens. Then the token can only be used after authentication.';

  @override
  String get introDragToken => 'Reorganizujte tokeny tak, že je na několik sekund stisknete a poté je přetáhnete na požadované místo.';

  @override
  String get introAddFolder => 'Můžete vytvářet složky\npro uspořádání svých tokenů.';

  @override
  String get introPollForChallenges => 'Můžete zkontrolovat nové výzvy přetažením seznamu tokenů dolů.';

  @override
  String get introHidePushTokens => 'Vaše push tokeny jsou nyní skryté.\nNa obrazovce push tokenů je však stále vidíte.';

  @override
  String legacySigningErrorTitle(Object tokenLabel) {
    return 'Při použití staršího tokenu došlo k chybě: $tokenLabel';
  }

  @override
  String get legacySigningErrorMessage => 'Token byl vytvořen v zastaralé verzi aplikace, což může vést k problémům při jeho používání.\nPokud problém přetrvává, doporučujeme vytvořit nový push token!';

  @override
  String get selectImportSource => 'Vyberte zdroj importu';

  @override
  String get selectImportType => 'Jak chcete importovat žetony?';

  @override
  String get importTokens => 'Importní token';

  @override
  String get selectFile => 'Vybrat soubor';

  @override
  String get decrypt => 'Dešifrovat';

  @override
  String get tokensAreEncrypted => 'Tokeny jsou zašifrované. Please enter the password to decrypt them.';

  @override
  String get tokensNotEncrypted => 'Tokeny nejsou šifrované a lze je importovat přímo.';

  @override
  String get tokensSuccessfullyDecrypted => 'Tokeny byly úspěšně dešifrovány a nyní je lze importovat.';

  @override
  String get password => 'Heslo';

  @override
  String get wrongPassword => 'Nesprávné heslo';

  @override
  String get qrScan => 'Skenování';

  @override
  String get enterLink => 'Zadejte odkaz';

  @override
  String invalidBackupFile(Object appName) {
    return 'Vybraný soubor není platnou zálohou $appName.';
  }

  @override
  String invalidQrScan(Object appName) {
    return 'Naskenovaný QR kód není platnou zálohou $appName.';
  }

  @override
  String invalidQrFile(Object appName) {
    return 'Vybraný soubor neobsahuje platný QR kód z $appName.';
  }

  @override
  String invalidLink(Object appName) {
    return 'Zadaný odkaz není platným tokenem $appName nebo není podporován.';
  }

  @override
  String importFailedToken(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Failed to import $count tokens.',
      one: 'Failed to import a token.',
      zero: 'Failed no token to import.',
    );
    return '$_temp0';
  }

  @override
  String importExistingToken(num count) {
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
  String importConflictToken(num count) {
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
  String importNewToken(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nalezen nový token $count, který bude importován.',
      one: 'Nalezen nový token, který bude importován.',
      zero: 'Nenalezen žádný nový token.',
    );
    return '$_temp0';
  }

  @override
  String get importHint2FAS => 'Vyberte zálohu 2FAS.\nPokud nemáte zálohu, vytvořte ji v aplikaci 2FAS. Doporučujeme použít heslo.';

  @override
  String get importHintAegisBackupFile => 'Vyberte svůj export Aegis (.JSON).\nPokud nemáte export, vytvořte si jej prostřednictvím nabídky nastavení v aplikaci Aegis. Doporučujeme použít heslo.';

  @override
  String get importHintAegisQrScan => 'Naskenujte QR kód, který obdržíte při přenosu záznamů z aplikace Aegis.';

  @override
  String get importHintAegisLink => 'Zadejte odkaz, který obdržíte při přenosu záznamů ze systému Aegis.';

  @override
  String get importHintGoogleQrScan => 'Naskenujte QR kód, který obdržíte při exportu účtů z Google Authenticator.';

  @override
  String get importHintGoogleQrFile => 'Vyberte obrazový soubor s QR kódem, který obdržíte při exportu účtů z Google Authenticator.\n!! Upozorňujeme, že není bezpečné ukládat QR kód do zařízení, protože tokeny nejsou šifrovány !!';

  @override
  String get importHintAuthenticatorProFile => 'Chcete-li vytvořit zálohu aplikace Authenticator Pro, přejděte do nastavení a klepněte na položku \"Automatické zálohování\". Vyberte umístění úložiště a nastavte heslo. Poté stiskněte \"Zálohovat nyní\" a exportujte tokeny.';

  @override
  String get qrFileDecodeError => 'Z vybraného obrázku nebylo možné dekódovat QR kód, použijte prosím místo toho skener QR kódů.';

  @override
  String get tokenLink => 'Token link';

  @override
  String get feedback => 'Zpětná vazba';

  @override
  String get feedbackTitle => 'Vaše zpětná vazba je vždy vítána!';

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
  String get addSystemInfo => 'Přidat systémové informace';

  @override
  String get feedbackSentTitle => 'Zpětná vazba odeslána';

  @override
  String get feedbackSentDescription => 'Děkujeme vám za pomoc při vylepšování této aplikace!';

  @override
  String get patchNotesDialogTitle => 'Co je nového?';

  @override
  String get version => 'Verze';

  @override
  String get noMailAppTitle => 'Není nainstalována žádná e-mailová aplikace';

  @override
  String get noMailAppDescription => 'There is no e-mail app installed or initialised on this device, please try again when you are able to send an email message.';

  @override
  String get authenticationRequest => 'Žádost o ověření';

  @override
  String requestInfo(Object issuer, Object account) {
    return 'Odesláno $issuer pro váš účet: \"$account\"';
  }

  @override
  String errorUnlinkingPushToken(Object label) {
    return 'Nepodařilo se odlinkovat push token $label.';
  }

  @override
  String get pleaseSyncManuallyWhenNetworkIsAvailable => 'Synchronizujte prosím push tokeny ručně prostřednictvím nastavení, když je k dispozici síťové připojení.';

  @override
  String get pushTokens => 'Žetony Push';

  @override
  String get continueButton => 'Pokračovat';

  @override
  String get addTokenManually => 'Přidat token ručně';

  @override
  String get addFolder => 'Přidat složku';

  @override
  String get searchTokens => 'Hledat tokeny';

  @override
  String get closeSearchTokens => 'Zavřít vyhledávání';

  @override
  String get increaseCounter => 'Zvýšit počítadla';

  @override
  String get copyOTPToClipboard => 'Zkopírovat OTP do schránky';

  @override
  String get licenses => 'Licence';

  @override
  String get optionalMessage => 'Volitelná zpráva';

  @override
  String get confirmation => 'Potvrzení';

  @override
  String get askLogSendedDescription => 'Odeslali jste protokol a chcete jej nyní vymazat?';
}
