// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'fr';

  static m0(name) => "La requête push a été accepté pour le jeton ${name}.";

  static m1(name) => "Confirmer la suppression de ${name}?";

  static m2(name) => "Le requête push a été refusé pour le jeton ${name}.";

  static m3(e) => "L\'authentication a échoué pour une raison inconnue: ${e}";

  static m4(name) =>
      "La configuration firebase des jetons ${name} ne correspond à celle utilisée actuellement par l\'application et ne peut donc pas être utilisée.";

  static m5(name, errorCode) =>
      "La requête push pour le jeton ${name} a échoué. Code d\'erreur: ${errorCode}";

  static m6(name, errorCode) =>
      "L\'enrôlement du jeton ${name} a échoué. Erreur réseau: ${errorCode}";

  static m7(e) => "L\'enrôlement a échoué suite à une erreur inconnue: ${e}";

  static m8(name) => "Le jeton ${name} a expiré et ne plus être enrôlé.";

  static m9(otpValue) =>
      "Le mot de passe \"${otpValue}\" a été copié dans le presse-papier.";

  static m10(accept, cancel) =>
      "Une erreur inattendue est survenue dans l\'application. L\'information suivante peut être transmise aux développeurs par email afin d\'aider à corriger cette erreur dans le futur. Appuyer sur \'${accept}\' pour envoyer l\'information ou \'${cancel}\' pour ne rien envoyer.";

  final messages = _notInlinedMessages(_notInlinedMessages);

  static _notInlinedMessages(_) => <String, Function>{
        "About": MessageLookupByLibrary.simpleMessage("À propos"),
        "Add token": MessageLookupByLibrary.simpleMessage("Ajouter un jeton"),
        "Algorithm": MessageLookupByLibrary.simpleMessage("Algorithme"),
        "All tokens are synchronized.": MessageLookupByLibrary.simpleMessage(
            "Tous les jetons ont été synchronisés."),
        "All tokens migrated successfully.":
            MessageLookupByLibrary.simpleMessage(
                "Tous les jetons ont été migré."),
        "Cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "Confirm deletion":
            MessageLookupByLibrary.simpleMessage("Confirmer suppression"),
        "Dark theme": MessageLookupByLibrary.simpleMessage("Thème sombre"),
        "Delete": MessageLookupByLibrary.simpleMessage("Supprimer"),
        "Digits": MessageLookupByLibrary.simpleMessage("Chiffres"),
        "Dismiss": MessageLookupByLibrary.simpleMessage("Fermer"),
        "Enable polling":
            MessageLookupByLibrary.simpleMessage("Activer l\'interrogation."),
        "Encoding": MessageLookupByLibrary.simpleMessage("Encodage"),
        "Enter details for token": MessageLookupByLibrary.simpleMessage(
            "Saisissez les détails du jeton"),
        "Generating phone part": MessageLookupByLibrary.simpleMessage(
            "Générer la part du téléphone"),
        "Guide": MessageLookupByLibrary.simpleMessage("Assistant"),
        "Light theme": MessageLookupByLibrary.simpleMessage("Thème lumineux"),
        "Migrate": MessageLookupByLibrary.simpleMessage("Migrer"),
        "Migrate tokens from previous app version.":
            MessageLookupByLibrary.simpleMessage(
                "Migrer les jetons depuis une version précédente de l\'application."),
        "Migrating Token":
            MessageLookupByLibrary.simpleMessage("Migration des jetons"),
        "Migration": MessageLookupByLibrary.simpleMessage("Migration"),
        "Miscellaneous": MessageLookupByLibrary.simpleMessage("Divers"),
        "Name": MessageLookupByLibrary.simpleMessage("Nom"),
        "Next": MessageLookupByLibrary.simpleMessage("Suivant"),
        "No tokens exist that could be migrated.":
            MessageLookupByLibrary.simpleMessage(
                "Il n\'y a aucun jeton qui puisse être migrer."),
        "Period": MessageLookupByLibrary.simpleMessage("Période"),
        "Phone part:":
            MessageLookupByLibrary.simpleMessage("Part du téléphone:"),
        "Please enter a name for this token.":
            MessageLookupByLibrary.simpleMessage(
                "Veuillez saisir un nom pour ce jeton."),
        "Please enter a secret for this token.":
            MessageLookupByLibrary.simpleMessage(
                "Veuillez saisir un secret pour ce jeton."),
        "Polling for new challenges": MessageLookupByLibrary.simpleMessage(
            "Vérification de nouveaux challenges"),
        "Push Token":
            MessageLookupByLibrary.simpleMessage("Jeton de type Push"),
        "Rename": MessageLookupByLibrary.simpleMessage("Renommer"),
        "Rename token": MessageLookupByLibrary.simpleMessage("Renommer jeton"),
        "Request push challenges from the server periodically. Enable this if push challenges are not received normally.":
            MessageLookupByLibrary.simpleMessage(
                "Demander des challenges push depuis le serveur périodiquement. Activer cette fonction si les challenges push ne sont pas reçus normalement."),
        "Scan QR code": MessageLookupByLibrary.simpleMessage("Scanner QR-code"),
        "Scan QR-Code":
            MessageLookupByLibrary.simpleMessage("Numériser QR-Code"),
        "Secret": MessageLookupByLibrary.simpleMessage("Secret"),
        "Settings": MessageLookupByLibrary.simpleMessage("Paramètres"),
        "Show this screen on start:": MessageLookupByLibrary.simpleMessage(
            "Afficher cet écran au démarrage:"),
        "Some of the tokens are outdated and do not support polling":
            MessageLookupByLibrary.simpleMessage(
                "Certains jetons sont obsolètes et ne supportent pas l\'interrogation."),
        "Something went wrong.":
            MessageLookupByLibrary.simpleMessage("Une erreur est survenue."),
        "Sync": MessageLookupByLibrary.simpleMessage("Synchroniser"),
        "Synchronization failed for the following tokens, please try again:":
            MessageLookupByLibrary.simpleMessage(
                "La synchronisation a échoué pour ces jetons, veuillez reéssayer :"),
        "Synchronize push tokens":
            MessageLookupByLibrary.simpleMessage("Synchoniser les jetons Push"),
        "Synchronizes tokens with the privacyIDEA server.":
            MessageLookupByLibrary.simpleMessage(
                "Synchroniser les jeton Push avec le serveur privacyIDEA."),
        "Synchronizing tokens.":
            MessageLookupByLibrary.simpleMessage("Synchroniser les jetons."),
        "The firebase configuration is corrupted and cannot be used.":
            MessageLookupByLibrary.simpleMessage(
                "La configuration firebase est corrompue et ne peut être utilisée."),
        "The following tokens do not support synchronization and must be rolled out again:":
            MessageLookupByLibrary.simpleMessage(
                "Ces jetons ne supportent pas la synchronisation et doivent être désenrôlés:"),
        "The secret does not fit the current encoding":
            MessageLookupByLibrary.simpleMessage(
                "Le secret n\'est pas compatible avec \n l\'encodage actuel."),
        "Theme": MessageLookupByLibrary.simpleMessage("Thème"),
        "Type": MessageLookupByLibrary.simpleMessage("Type"),
        "Unexpected Error":
            MessageLookupByLibrary.simpleMessage("Erreur inattendue"),
        "accept": MessageLookupByLibrary.simpleMessage("Accepter"),
        "acceptPushAuthRequestFor": m0,
        "confirmDeletionOf": m1,
        "decline": MessageLookupByLibrary.simpleMessage("Refuser"),
        "decliningPushAuthRequestFor": m2,
        "deleteCache": MessageLookupByLibrary.simpleMessage(
            "Effacer les données de l\'application."),
        "errorAuthenticationFailedUnknownError": m3,
        "errorAuthenticationNotPossibleWithoutNetworkAccess":
            MessageLookupByLibrary.simpleMessage(
                "Aucune connectivité réseau. Authentification impossible."),
        "errorOnlyOneFirebaseProjectIsSupported": m4,
        "errorPushAuthRequestFailedFor": m5,
        "errorRollOutFailed": m6,
        "errorRollOutNoNetworkConnection": MessageLookupByLibrary.simpleMessage(
            "Pas de connectivité réseau. Enrôlement impossible."),
        "errorRollOutUnknownError": m7,
        "errorSynchronizationNoNetworkConnection":
            MessageLookupByLibrary.simpleMessage(
                "La synchronization a échoué car le serveur est injoignable."),
        "errorTokenExpired": m8,
        "otpValueCopiedMessage": m9,
        "paddingExceptionBody": MessageLookupByLibrary.simpleMessage(
            "Problème connu avec la configuration de l\'équipement. Merci d\'effacer les données de l\'application depuis les paramètres de l\'équipement ou désinstaller et réinstaller avant de réessayer."),
        "paddingExceptionTitle": MessageLookupByLibrary.simpleMessage(
            "Une erreur inattendue est survenue"),
        "pageReportModeBody": m10,
        "reportIssue":
            MessageLookupByLibrary.simpleMessage("Signaler le problème"),
        "retry": MessageLookupByLibrary.simpleMessage("Réessayer"),
        "retryRollOut":
            MessageLookupByLibrary.simpleMessage("Retenter l\'enrôlement"),
        "rollingOut":
            MessageLookupByLibrary.simpleMessage("Enrôlement en cours")
      };
}
