import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get patchNotesNewFeatures => 'Nouvelles caractéristiques';

  @override
  String get patchNotesImprovements => 'Améliorations';

  @override
  String get patchNotesBugFixes => 'Bug fixes';

  @override
  String get patchNotesV4_3_1BugFix1 => 'Un problème a été corrigé où la valeur OTP n\'était pas affichée après l\'authentification sur certains appareils.';

  @override
  String get patchNotesV4_3_1Improvement1 => 'Le scanner de codes QR a été amélioré.';

  @override
  String get patchNotesV4_3_0NewFeatures1 => 'Ajout de la prise en charge de l\'importation de jetons depuis Google, Aegis et 2FAS Authenticator. D\'autres sources d\'importation seront ajoutées à l\'avenir.';

  @override
  String get patchNotesV4_3_0NewFeatures2 => 'Ajout d\'une option de retour d\'information dans les paramètres';

  @override
  String get patchNotesV4_3_0NewFeatures3 => 'Les jetons de poussée peuvent maintenant être cachés de la liste des jetons';

  @override
  String get patchNotesV4_3_0NewFeatures4 => 'Des introductions ont été ajoutées pour aider les nouveaux utilisateurs à démarrer';

  @override
  String get patchNotesV4_3_0NewFeatures5 => 'Vous pouvez désormais rechercher des jetons en appuyant sur la loupe dans le coin supérieur droit';

  @override
  String get patchNotesV4_3_0NewFeatures6 => 'Ajout du jeton HomeWidget pour Android 12 et les versions ultérieures';

  @override
  String get accept => 'Accepter';

  @override
  String get decline => 'Refuser';

  @override
  String get name => 'Nom';

  @override
  String get secretKey => 'Clé secrète';

  @override
  String get encoding => 'Encodage';

  @override
  String get algorithm => 'Algorithme';

  @override
  String get digits => 'Chiffres';

  @override
  String get type => 'Type';

  @override
  String get period => 'Période';

  @override
  String get rename => 'Renommer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get dismiss => 'Fermer';

  @override
  String get addToken => 'Ajouter un jeton';

  @override
  String get scanQrCode => 'Numériser QR-Code';

  @override
  String get enterDetailsForToken => 'Saisissez les détails du jeton';

  @override
  String get pleaseEnterANameForThisToken => 'Veuillez saisir un nom pour ce jeton.';

  @override
  String get pleaseEnterASecretForThisToken => 'Veuillez saisir un secret pour ce jeton.';

  @override
  String get theSecretDoesNotFitTheCurrentEncoding => 'Le secret n\'est pas compatible avec \nl\'encodage actuel.';

  @override
  String get renameToken => 'Renommer jeton';

  @override
  String get confirmDeletion => 'Confirmer suppression';

  @override
  String confirmDeletionOf(Object name) {
    return 'Confirmer la suppression de $name?';
  }

  @override
  String get confirmTokenDeletionHint => 'Il se peut que vous ne puissiez plus vous connecter si vous supprimez ce token.\nVeuillez vous assurer que vous pouvez vous connecter au compte associé sans ce token.';

  @override
  String get confirmFolderDeletionHint => 'La suppression d\'un dossier n\'a aucun effet sur les tokens qui s\'y trouvent.\nLes tokens sont déplacés dans la liste principale.';

  @override
  String get generatingPhonePart => 'Générer la part du téléphone';

  @override
  String get phonePart => 'Part du téléphone:';

  @override
  String otpValueCopiedMessage(Object otpValue) {
    return 'Le mot de passe \"$otpValue\" a été copié dans le presse-papier.';
  }

  @override
  String get settings => 'Paramètres';

  @override
  String get pushToken => 'Jeton de type Push';

  @override
  String get theme => 'Thème';

  @override
  String get lightTheme => 'Thème lumineux';

  @override
  String get darkTheme => 'Thème sombre';

  @override
  String get systemTheme => 'Utiliser le thème de l\'appareil';

  @override
  String get someTokensDoNotSupportPolling => 'Certains jetons sont obsolètes et ne supportent pas l\'interrogation due serveur.';

  @override
  String get enablePolling => 'Activer l\'interrogation du serveur.';

  @override
  String get requestPushChallengesPeriodically => 'Demander des challenges push depuis le serveur périodiquement. Activer cette fonction si les challenges push ne sont pas reçus normalement.';

  @override
  String get synchronizePushTokens => 'Synchoniser les jetons Push';

  @override
  String get synchronizesTokensWithServer => 'Synchroniser les jetons Push avec le serveur privacyIDEA.';

  @override
  String get sync => 'Synchroniser';

  @override
  String get synchronizingTokens => 'Synchroniser les jetons.';

  @override
  String get allTokensSynchronized => 'Tous les jetons ont été synchronisés.';

  @override
  String get synchronizationFailed => 'La synchronisation a échoué pour ces jetons, veuillez reéssayer:';

  @override
  String get tokensDoNotSupportSynchronization => 'Ces jetons ne supportent pas la synchronisation et doivent être de nouveau générés:';

  @override
  String errorRollOutFailed(Object name) {
    return 'Le déploiement du jeton $name a échoué.';
  }

  @override
  String statusCode(Object statusCode) {
    return 'Code d\'état : $statusCode';
  }

  @override
  String get errorSynchronizationNoNetworkConnection => 'La synchronization a échoué car le serveur est injoignable.';

  @override
  String errorRollOutNoConnectionToServer(Object name) {
    return 'El despliegue del token $name ha fallado, no se ha podido acceder al servidor.';
  }

  @override
  String errorRollOutUnknownError(Object e) {
    return 'Le déploiement a échoué suite à une erreur inconnue: $e';
  }

  @override
  String get rollingOut => 'Déploiement en cours';

  @override
  String get pollingChallenges => 'Vérification de nouveaux challenges';

  @override
  String get unexpectedError => 'Une erreur inattendue s\'est produite.';

  @override
  String get pollingFailed => 'Échec de la requête.';

  @override
  String pollingFailedFor(Object serial) {
    return 'Echec de la requête pour $serial.';
  }

  @override
  String get noNetworkConnection => 'Pas de connexion au réseau.';

  @override
  String get connectionFailed => 'La connexion a échoué.';

  @override
  String get checkYourNetwork => 'Veuillez vérifier votre connexion réseau et réessayer.';

  @override
  String get serverNotReachable => 'Le serveur n\'a pas pu être atteint.';

  @override
  String get couldNotSignMessage => 'Impossible de signer le message.';

  @override
  String get useDeviceLocaleTitle => 'Utiliser la langue de l\'appareil';

  @override
  String get useDeviceLocaleDescription => 'Utilisez la langue de l\'appareil si elle est prise en charge, sinon l\'anglais par défaut.';

  @override
  String get language => 'Langue';

  @override
  String get authenticateToShowOtp => 'Veuillez vous authentifier pour afficher un mot de passe à usage unique.';

  @override
  String get authenticateToUnLockToken => 'Veuillez vous authentifier pour modifier l\'état de verrouillage du jeton.';

  @override
  String get biometricRequiredTitle => 'La biométrie n\'est pas configurée';

  @override
  String get biometricHint => 'Authentification requise';

  @override
  String get biometricNotRecognized => 'Pas reconnu. Réessayer.';

  @override
  String get biometricSuccess => 'Authentification réussie';

  @override
  String get deviceCredentialsRequiredTitle => 'Les informations d\'identification de l\'appareil ne sont pas configurées';

  @override
  String get deviceCredentialsSetupDescription => 'Configurer les informations d\'identification de l\'appareil dans les paramètres de l\'appareil';

  @override
  String get signInTitle => 'Authentification requise';

  @override
  String get goToSettingsButton => 'Aller aux paramètres';

  @override
  String get goToSettingsDescription => 'L\'authentification par identifiants ou biométrie n\'est pas configurée sur votre appareil. Veuillez le configurer dans les paramètres de l\'appareil.';

  @override
  String get lockOut => 'L\'authentification biométrique est désactivée. Veuillez verrouiller et déverrouiller votre écran pour l\'activer.';

  @override
  String get authNotSupportedTitle => 'Informations d\'identification de l\'appareil ou données biométriques requises';

  @override
  String get authNotSupportedBody => 'Cette action nécessite que l\'appareil soit sécurisé par des identifiants ou des données biométriques.';

  @override
  String get lock => 'Bloquer';

  @override
  String get unlock => 'Ouvrir';

  @override
  String get noResultTitle => 'Aucun jeton n\'est encore stocké.';

  @override
  String get noResultText1 => 'Appuyez sur le \n';

  @override
  String get noResultText2 => 'bouton pour commencer!';

  @override
  String onBoardingTitle1(Object appName) {
    return '$appName';
  }

  @override
  String get onBoardingText1 => 'Authentification à deux facteurs\nrendue facile';

  @override
  String get onBoardingTitle2 => 'Sécurité Maximale';

  @override
  String get onBoardingText2 => 'Stockez les jetons sur votre \nappareil en toute sécurité\nProtégé par votre biométrie';

  @override
  String get onBoardingTitle3 => 'Rendez-nous visite sur Github';

  @override
  String get onBoardingText3 => 'Cette application est open source';

  @override
  String get errorLogTitle => 'Journal d\'erreur';

  @override
  String get logMenu => 'Menu du journal';

  @override
  String get showErrorLog => 'Afficher';

  @override
  String get clearErrorLog => 'Effacer';

  @override
  String get send => 'Envoyer';

  @override
  String get sendErrorLogDescription => 'Un e-mail pré-rempli est créé.\nIl contient des informations sur l\'application, l\'erreur et le périphérique.\nVous pouvez modifier l\'e-mail avant de l\'envoyer.\nVous pouvez voir ici comment nous utilisons les informations:';

  @override
  String get showPrivacyPolicy => 'Afficher la déclaration de confidentialité';

  @override
  String get errorLogEmpty => 'Le journal des erreurs est vide';

  @override
  String get verboseLogging => 'Journalisation verbeuse';

  @override
  String get errorLogCleared => 'Journal d\'erreur nettoyé';

  @override
  String get ok => 'Ok';

  @override
  String get errorMailBody => 'Le fichier journal des erreurs est joint.\nVous pouvez remplacer ce texte par des informations supplémentaires sur l\'erreur.';

  @override
  String get showDetails => 'Afficher les détails';

  @override
  String get open => 'Ouvrir';

  @override
  String get sendErrorDialogBody => 'Une erreur inattendue est survenue dans l\'application. L\'information suivante peut être transmise aux développeurs par email afin d\'aider à corriger cette erreur dans le futur.';

  @override
  String get noFbToken => 'Pas de jeton Firebase';

  @override
  String get firebaseToken => 'Jeton Firebase';

  @override
  String get noPublicKey => 'Pas de clé publique';

  @override
  String get publicKey => 'Clé publique';

  @override
  String get editToken => 'Modifier le jeton';

  @override
  String get edit => 'Modifier';

  @override
  String get save => 'Enregistrer';

  @override
  String get create => 'créer';

  @override
  String get validFor => 'Valide pour';

  @override
  String get validUntil => 'Valide jusqu\'à';

  @override
  String get deleteLockedToken => 'Veuillez vous authentifier pour supprimer le jeton verrouillé.';

  @override
  String get editLockedToken => 'Veuillez vous authentifier pour modifier le jeton verrouillé.';

  @override
  String get expandLockedFolder => 'Veuillez vous authentifier pour ouvrir le dossier verrouillé.';

  @override
  String get renameTokenFolder => 'Renommer le dossier';

  @override
  String get addANewFolder => 'Créer un nouveau dossier';

  @override
  String get folderName => 'Nom du dossier';

  @override
  String get retryRollout => 'Réessayer le déploiement';

  @override
  String get generatingRSAKeyPair => 'Génération de la paire de clés RSA';

  @override
  String get generatingRSAKeyPairFailed => 'La génération de la paire de clés RSA a échoué';

  @override
  String get sendingRSAPublicKey => 'Envoi de la clé publique RSA';

  @override
  String get sendingRSAPublicKeyFailed => 'L\'envoi de la clé publique RSA a échoué';

  @override
  String get parsingResponse => 'Analyse de la réponse';

  @override
  String get parsingResponseFailed => 'L\'analyse de la réponse a échoué';

  @override
  String get rolloutCompleted => 'Déploiement terminé';

  @override
  String get authToAcceptPushRequest => 'Veuillez vous authentifier pour accepter la demande de connexion.';

  @override
  String get authToDeclinePushRequest => 'Veuillez vous authentifier pour refuser la demande de connexion.';

  @override
  String get pushRequestParseError => 'La demande push n\'a pas pu être traitée.';

  @override
  String get imageUrl => 'URL de l\'image';

  @override
  String get errorRollOutSSLHandshakeFailed => 'Échec de la prise de contact SSL. Le déploiement n\'est pas possible.';

  @override
  String errorWhenPullingChallenges(Object name) {
    return 'Une erreur s\'est produite lors de l\'interrogation des défis de $name';
  }

  @override
  String get errorRollOutNotPossibleAnymore => 'Le déploiement de ce jeton n\'est plus possible.';

  @override
  String errorTokenExpired(Object name) {
    return 'Le jeton $name a expiré.';
  }

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get butDiscardIt => 'mais l\'écarter';

  @override
  String get declineIt => 'refuser';

  @override
  String get requestTriggerdByUserQuestion => 'Cette demande a-t-elle été déclenchée par vous ?';

  @override
  String get grantCameraPermissionDialogTitle => 'L\'autorisation de la caméra n\'est pas accordée';

  @override
  String get grantCameraPermissionDialogContent => 'Veuillez accorder à la caméra l\'autorisation de scanner les codes QR';

  @override
  String get grantCameraPermissionDialogPermanentlyDenied => 'L\'autorisation de l\'appareil photo est refusée de manière permanente. Veuillez accorder l\'autorisation à l\'appareil photo dans les paramètres de votre téléphone.';

  @override
  String get grantCameraPermissionDialogButton => 'Accorder l\'autorisation';

  @override
  String get decryptErrorTitle => 'Erreur de décryptage';

  @override
  String get decryptErrorContent => 'Malheureusement, l\'application n\'a pas pu décrypter vos jetons. Cela indique que la clé de cryptage est cassée. Vous pouvez réessayer ou supprimer les données de l\'application, ce qui supprimera les jetons dans l\'application.';

  @override
  String get decryptErrorButtonDelete => 'Supprimer';

  @override
  String get decryptErrorButtonSendError => 'Erreur d\'envoi';

  @override
  String get decryptErrorButtonRetry => 'Réessayer';

  @override
  String get decryptErrorDeleteConfirmationContent => 'Êtes-vous sûr de vouloir supprimer les données de l\'application ?';

  @override
  String get hidePushTokens => 'Hide push tokens';

  @override
  String get hidePushTokensDescription => 'Masquer les jetons de poussée de la liste des jetons. Cela ne supprimera pas les jetons et ils seront toujours visibles sur un écran séparé';

  @override
  String get settingsGroupGeneral => 'Généralités';

  @override
  String get licensesAndVersion => 'Licences et version';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get introScanQrCode => 'You can scan QR codes to add tokens.\nWe support every common Two-Factor-Authentication token and also the privacyIDEA tokens.';

  @override
  String get introAddTokenManually => 'Si vous ne souhaitez pas scanner un code QR, vous pouvez également ajouter des jetons manuellement.';

  @override
  String get introTokenSwipe => 'Balayez les tokens vers la gauche pour voir les actions disponibles';

  @override
  String get introEditToken => 'Ici, vous pouvez modifier le nom du token et voir quelques détails';

  @override
  String get introLockToken => 'Pour améliorer encore la sécurité, vous pouvez verrouiller les tokens. Le token ne peut alors être utilisé qu\'après l\'authentification.';

  @override
  String get introDragToken => 'Réorganisez vos jetons en appuyant dessus pendant quelques secondes, puis en les faisant glisser jusqu\'à la position souhaitée';

  @override
  String get introAddFolder => 'Vous pouvez créer des dossiers pour organiser vos jetons';

  @override
  String get introPollForChallenges => 'Vous pouvez vérifier la présence de nouveaux défis en faisant glisser la liste des jetons vers le bas';

  @override
  String get introHidePushTokens => 'Vos jetons sont maintenant cachés, mais vous pouvez toujours les voir sur l\'écran des jetons';

  @override
  String legacySigningErrorTitle(Object tokenLabel) {
    return 'Une erreur s\'est produite lors de l\'utilisation du jeton obsolète : $tokenLabel';
  }

  @override
  String get legacySigningErrorMessage => 'Le token a été créé dans une version obsolète de l\'application, ce qui peut entraîner des problèmes d\'utilisation.\nIl est recommandé de créer un nouveau token push si le problème persiste !';

  @override
  String get selectImportSource => 'Sélectionner la source d\'importation';

  @override
  String get selectImportType => 'Comment voulez-vous importer les jetons ?';

  @override
  String get importTokens => 'Importer un jeton';

  @override
  String get selectFile => 'Sélectionner un fichier';

  @override
  String get decrypt => 'Décrypter';

  @override
  String get tokensAreEncrypted => 'Les jetons sont cryptés. Veuillez saisir le mot de passe pour les décrypter';

  @override
  String get tokensNotEncrypted => 'Les tokens ne sont pas cryptés, et peuvent être importés directement';

  @override
  String get tokensSuccessfullyDecrypted => 'Les tokens ont été décryptés avec succès, ils peuvent maintenant être importés.';

  @override
  String get password => 'Mot de passe';

  @override
  String get wrongPassword => 'Mot de passe incorrect';

  @override
  String get qrScan => 'Numériser';

  @override
  String get enterLink => 'Saisir le lien';

  @override
  String invalidBackupFile(Object appName) {
    return 'Le fichier sélectionné n\'est pas une sauvegarde valide de $appName';
  }

  @override
  String invalidQrScan(Object appName) {
    return 'Le code QR scanné n\'est pas une sauvegarde valide de $appName';
  }

  @override
  String invalidQrFile(Object appName) {
    return 'Le fichier sélectionné ne contient pas de code QR valide de $appName';
  }

  @override
  String invalidLink(Object appName) {
    return 'Le lien saisi n\'est pas un jeton valide de $appName, ou il n\'est pas pris en charge';
  }

  @override
  String importFailedToken(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Échec de l\'importation des jetons $count.',
      one: 'Échec de l\'importation d\'un jeton.',
      zero: 'Pas de jeton Échec de l\'importation.',
    );
    return '$_temp0';
  }

  @override
  String importExistingToken(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Des jetons $count déjà présents dans l\'application ont été trouvés.',
      one: 'Un jeton qui existe déjà dans l\'application a été trouvé.',
      zero: 'Aucun jeton déjà présent dans l\'application n\'a été trouvé.',
    );
    return '$_temp0';
  }

  @override
  String importConflictToken(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a un conflit avec des tokens déjà existants.\nVeuillez choisir celui que vous voulez garder.',
      one: 'Il y a un conflit avec des tokens déjà existants.\nVeuillez choisir celui que vous voulez garder.',
      zero: 'Il n\'y a pas de conflit avec des tokens déjà existants.',
    );
    return '$_temp0';
  }

  @override
  String importNewToken(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aucun $count nouveau token a été trouvé et sera importé.',
      one: 'Un nouveau token a été trouvé et sera importé.',
      zero: 'Aucun nouveau token n\'a été trouvé.',
    );
    return '$_temp0';
  }

  @override
  String get importHint2FAS => 'Choisissez votre sauvegarde 2FAS.\nSi vous n\'avez pas de sauvegarde, créez-en une dans l\'application 2FAS. Nous vous recommandons d\'utiliser un mot de passe';

  @override
  String get importHintAegisBackupFile => 'Choisissez votre exportation Aegis (.JSON).\nSi vous n\'avez pas d\'exportation, veuillez en créer une via le menu Paramètres dans l\'application Aegis. Il est recommandé d\'utiliser un mot de passe';

  @override
  String get importHintAegisQrScan => 'Scannez le code QR que vous recevez lorsque vous transférez des entrées depuis Aegis';

  @override
  String get importHintAegisLink => 'Saisissez le lien que vous recevez lorsque vous transférez des entrées depuis Aegis';

  @override
  String get importHintGoogleQrScan => 'Scannez le code QR que vous recevez lorsque vous exportez vos comptes depuis Google Authenticator';

  @override
  String get importHintGoogleQrFile => 'Sélectionnez un fichier image avec le code QR que vous obtenez lorsque vous exportez vos comptes depuis Google Authenticator.\n!! Notez qu\'il n\'est pas sûr d\'enregistrer le code QR sur votre appareil, car les jetons ne sont pas cryptés !!';

  @override
  String get importHintAuthenticatorProFile => 'Pour créer une sauvegarde de l\'application Authenticator Pro, accédez aux paramètres et appuyez sur \"Sauvegarde automatique\". Sélectionnez un emplacement de stockage et définissez un mot de passe. Puis appuyez sur \"Sauvegarder maintenant\" pour exporter les tokens.';

  @override
  String get importHintFreeOtpPlusQrScan => 'Scannez le code QR que vous recevez lorsque vous appuyez sur les trois points dans la tuile du jeton et sélectionnez \"Partager le code QR\".';

  @override
  String get importHintFreeOtpPlusFile => 'Pour créer une sauvegarde de l\'application FreeOTP+, appuyez sur les trois points dans le coin supérieur droit et sélectionnez \"Exporter\". Vous pouvez choisir entre les formats JSON et URI. Nous recommandons de supprimer la sauvegarde après l\'avoir importée, car elle n\'est pas cryptée.';

  @override
  String get qrFileDecodeError => 'Il n\'a pas été possible de décoder le code QR à partir de l\'image sélectionnée, veuillez utiliser le scanner de code QR à la place';

  @override
  String get tokenLink => 'Lien vers le token';

  @override
  String get feedback => 'Retour d\'information';

  @override
  String get feedbackTitle => 'Vos commentaires sont toujours les bienvenus !';

  @override
  String get feedbackDescription => 'Si vous avez des questions, des suggestions ou des problèmes, n\'hésitez pas à nous en faire part';

  @override
  String get feedbackHint => 'Un e-mail prêt à l\'emploi s\'ouvre, que vous pouvez nous envoyer. Si vous le souhaitez, des informations sur votre appareil et la version de l\'application seront ajoutées. Vous pouvez vérifier et modifier l\'e-mail avant de l\'envoyer.';

  @override
  String get feedbackPrivacyPolicy1 => 'En envoyant le retour d\'information, vous acceptez notre ';

  @override
  String get feedbackPrivacyPolicy2 => 'politique de confidentialité';

  @override
  String get feedbackPrivacyPolicy3 => '.';

  @override
  String get addSystemInfo => 'Ajouter des informations sur le système';

  @override
  String get feedbackSentTitle => 'Retour d\'information envoyé';

  @override
  String get feedbackSentDescription => 'Merci beaucoup pour votre aide dans l\'amélioration de cette application !';

  @override
  String get patchNotesDialogTitle => 'Quoi de neuf ?';

  @override
  String get version => 'Version';

  @override
  String get noMailAppTitle => 'Aucune application de messagerie trouvée';

  @override
  String get noMailAppDescription => 'Aucune application de messagerie n\'est installée ou initialisée sur cet appareil. Veuillez réessayer lorsque vous serez en mesure d\'envoyer un message électronique.';

  @override
  String get authenticationRequest => 'Authentification';

  @override
  String requestInfo(Object issuer, Object account) {
    return 'Envoyé par $issuer pour votre compte : \"$account\"';
  }

  @override
  String errorUnlinkingPushToken(Object label) {
    return 'Echec du découplage du push token $label';
  }

  @override
  String get pleaseSyncManuallyWhenNetworkIsAvailable => 'Veuillez synchroniser manuellement les jetons Push via les paramètres lorsqu\'une connexion réseau est disponible';

  @override
  String get pushTokens => 'Push Tokens';

  @override
  String get continueButton => 'Continue';

  @override
  String get addTokenManually => 'Add token manually';

  @override
  String get addFolder => 'Ajouter un dossier';

  @override
  String get searchTokens => 'Jetons de recherche';

  @override
  String get closeSearchTokens => 'Fermer la recherche';

  @override
  String get increaseCounter => 'Augmenter le compteur';

  @override
  String get copyOTPToClipboard => 'Copier l\'OTP dans le presse-papiers';

  @override
  String get licenses => 'Licences';

  @override
  String get optionalMessage => 'Message optionnel';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get askLogSendedDescription => 'Avez-vous envoyé le journal et voulez-vous l\'effacer maintenant ?';

  @override
  String algorithmUnsupported(Object algorithm) {
    return 'L\'algorithme $algorithm n\'est pas pris en charge';
  }

  @override
  String get thisAppIsOpenSource => 'Cette application est open source\nRendez-nous visite sur GitHub';

  @override
  String get importExportTokens => 'Importer/Exporter les jetons';

  @override
  String get exportNonPrivacyIDEATokens => 'Exporter les jetons non privacyIDEA';

  @override
  String selectTokensToExport(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sélectionner les jetons à exporter',
      one: 'Sélectionner le jeton à exporter',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get noTokensToExport => 'Aucun jeton à exporter';

  @override
  String get exportAllTokens => 'Exporter tous les jetons';

  @override
  String get export => 'Exporter';

  @override
  String get exportingTokens => 'Exportation des jetons en cours...';

  @override
  String get exportTokens => 'Exporter les jetons';

  @override
  String get enterPasswordToEncrypt => 'Entrez un mot de passe pour chiffrer les jetons. Ce mot de passe sera requis pour importer les jetons.';

  @override
  String get exportLockedTokenReason => 'Veuillez vous authentifier pour exporter les jetons verrouillés.';

  @override
  String get fileSavedToDownloadsFolder => 'Fichier enregistré dans le dossier Téléchargements';

  @override
  String get errorSavingFile => 'Erreur lors de l\'enregistrement du fichier';

  @override
  String get toFile => 'Vers fichier';

  @override
  String get asQrCode => 'Sous forme de code QR';

  @override
  String get scanThisQrWithNewDevice => 'Scannez ce code QR avec votre nouvel appareil pour importer le jeton.';

  @override
  String get oneMore => 'Encore un';

  @override
  String get done => 'Terminé';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get secretIsRequired => 'Secret is required';

  @override
  String get tokenDataParseError => 'Token data could not be parsed';

  @override
  String missingRequiredParameter(Object counter) {
    return 'Value for parameter [$counter] is required and is missing';
  }

  @override
  String invalidValueForParameter(Object value, Object parameter) {
    return '[$value] is not a valid value for uri parameter [parameter].';
  }

  @override
  String unsupported(Object name, Object value) {
    return 'The $name [$value] is not supported by this version of the app.';
  }
}
