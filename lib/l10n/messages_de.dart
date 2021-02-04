// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
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
  String get localeName => 'de';

  static m0(name) => "Akzeptiere Authentifizierungsanfrage für ${name}.";

  static m1(name) => "Bestätigen Sie das Löschen von ${name}?";

  static m2(name) => "Lehne Authentifizierungsanfrage für ${name} ab.";

  static m3(e) => "Ein unbekannter Fehler ist aufgetreten. Authentifizierung fehlgeschlagen: ${e}";

  static m4(name) => "Die Firebase-Konfiguration des Tokens ${name} unterscheidet sich von der zur Zeit von der App verwendeten. Zwei verschiedene Konfigurationen werden nicht unterstützt.";

  static m5(name, errorCode) => "Akzeptieren der Authentifizierungsanfrage für ${name} fehlgeschlagen. Fehlercode: ${errorCode}";

  static m6(name, errorCode) => "Ausrollen von ${name} ist fehlgeschlagen. Fehlercode: ${errorCode}";

  static m7(e) => "Ein unbekannter Fehler ist aufgetreten. Aurollen nicht möglich: ${e}";

  static m8(name) => "Der Token ${name} ist nicht mehr gültig, ausrollen ist daher nicht möglich.";

  static m9(otpValue) => "Passwort \"${otpValue}\" wurde in die Zwischenablage kopiert.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "About" : MessageLookupByLibrary.simpleMessage("Über"),
    "Add token" : MessageLookupByLibrary.simpleMessage("Token hinzufügen"),
    "Algorithm" : MessageLookupByLibrary.simpleMessage("Algorithmus"),
    "All tokens are synchronized." : MessageLookupByLibrary.simpleMessage("Alle Token wurden synchronisiert."),
    "Cancel" : MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "Confirm deletion" : MessageLookupByLibrary.simpleMessage("Löschen bestätigen"),
    "Dark theme" : MessageLookupByLibrary.simpleMessage("Dunkles Thema"),
    "Delete" : MessageLookupByLibrary.simpleMessage("Löschen"),
    "Digits" : MessageLookupByLibrary.simpleMessage("Ziffern"),
    "Dismiss" : MessageLookupByLibrary.simpleMessage("Schließen"),
    "Enable polling" : MessageLookupByLibrary.simpleMessage("Aktives Stellen von Push-Anfragen"),
    "Encoding" : MessageLookupByLibrary.simpleMessage("Verschlüsselung"),
    "Enter details for token" : MessageLookupByLibrary.simpleMessage("Neuen Token konfigurieren"),
    "Generating phone part" : MessageLookupByLibrary.simpleMessage("Generiere Telefonanteil"),
    "Guide" : MessageLookupByLibrary.simpleMessage("Anleitung"),
    "Light theme" : MessageLookupByLibrary.simpleMessage("Helles Thema"),
    "Miscellaneous" : MessageLookupByLibrary.simpleMessage("Verschiedenes"),
    "Name" : MessageLookupByLibrary.simpleMessage("Name"),
    "Next" : MessageLookupByLibrary.simpleMessage("Weiter"),
    "Period" : MessageLookupByLibrary.simpleMessage("Periode"),
    "Phone part:" : MessageLookupByLibrary.simpleMessage("Telefonanteil:"),
    "Please enter a name for this token." : MessageLookupByLibrary.simpleMessage("Bitte geben Sie einen Namen für diesen Token ein."),
    "Please enter a secret for this token." : MessageLookupByLibrary.simpleMessage("Bitte geben Sie ein Geheimnis für diesen Token ein."),
    "Polling for new challenges" : MessageLookupByLibrary.simpleMessage("Frage ausstehende Authentifizierungsanfragen ab"),
    "Push Token" : MessageLookupByLibrary.simpleMessage("Push Token"),
    "Rename" : MessageLookupByLibrary.simpleMessage("Umbenennen"),
    "Rename token" : MessageLookupByLibrary.simpleMessage("Token umbenennen"),
    "Request push challenges from the server periodically. Enable this if push challenges are not received normally." : MessageLookupByLibrary.simpleMessage("Fordert regelmäßig Push-Anfragen vom Server an. Aktivieren Sie diese Funktion, wenn Nachrichten ansonsten nicht erhalten werden."),
    "Scan QR code" : MessageLookupByLibrary.simpleMessage("Scanne QR-code"),
    "Scan QR-Code" : MessageLookupByLibrary.simpleMessage("QR-Code scannen"),
    "Secret" : MessageLookupByLibrary.simpleMessage("Geheimnis"),
    "Settings" : MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "Show this screen on start:" : MessageLookupByLibrary.simpleMessage("Zeige bei App-Start:"),
    "Some of the tokens are outdated and do not support polling" : MessageLookupByLibrary.simpleMessage("Einige der Token sind veraltet und unterstützen keine aktiven Anfragen"),
    "Something went wrong." : MessageLookupByLibrary.simpleMessage("Etwas ist schiefgelaufen."),
    "Sync" : MessageLookupByLibrary.simpleMessage("Sync"),
    "Synchronization failed for the following tokens, please try again:" : MessageLookupByLibrary.simpleMessage("Synchronisation ist für die folgenden Tokens fehlgeschlagen, bitte versuchen Sie es erneut:"),
    "Synchronize push tokens" : MessageLookupByLibrary.simpleMessage("Synchronisiere Push Tokens"),
    "Synchronizes tokens with the privacyIDEA server." : MessageLookupByLibrary.simpleMessage("Synchronisiert Push Tokens mit dem privacyIDEA Server."),
    "Synchronizing tokens." : MessageLookupByLibrary.simpleMessage("Synchronisiere Tokens."),
    "The firebase configuration is corrupted and cannot be used." : MessageLookupByLibrary.simpleMessage("Die Firebase-Konfiguration ist beschädigt und kann nicht genutzt werden."),
    "The following tokens do not support synchronization and must be rolled out again:" : MessageLookupByLibrary.simpleMessage("Die folgenden Tokens unterstützen keine Synchronisation und müssen neu ausgerollt werden:"),
    "The secret does not fit the current encoding" : MessageLookupByLibrary.simpleMessage("Das Geheimnis entspricht nicht der gewählten\n Verschlüsselung."),
    "Theme" : MessageLookupByLibrary.simpleMessage("Thema"),
    "Type" : MessageLookupByLibrary.simpleMessage("Art"),
    "accept" : MessageLookupByLibrary.simpleMessage("Akzeptieren"),
    "acceptPushAuthRequestFor" : m0,
    "confirmDeletionOf" : m1,
    "decline" : MessageLookupByLibrary.simpleMessage("Ablehnen"),
    "decliningPushAuthRequestFor" : m2,
    "errorAuthenticationFailedUnknownError" : m3,
    "errorAuthenticationNotPossibleWithoutNetworkAccess" : MessageLookupByLibrary.simpleMessage("Fehlende Netzwerkverbindung. Authentifizierung nicht möglich."),
    "errorOnlyOneFirebaseProjectIsSupported" : m4,
    "errorPushAuthRequestFailedFor" : m5,
    "errorRollOutFailed" : m6,
    "errorRollOutNoNetworkConnection" : MessageLookupByLibrary.simpleMessage("Fehlende Netzwerkverbindung. Ausrollen nicht möglich."),
    "errorRollOutUnknownError" : m7,
    "errorSynchronizationNoNetworkConnection" : MessageLookupByLibrary.simpleMessage("Die Synchronisation ist fehlgeschlagen, da der privacyIDEA Server nicht erreicht werden konnte."),
    "errorTokenExpired" : m8,
    "otpValueCopiedMessage" : m9,
    "retry" : MessageLookupByLibrary.simpleMessage("Erneut versuchen"),
    "retryRollOut" : MessageLookupByLibrary.simpleMessage("Ausrollen fehlgeschlagen, nochmal versuchen?"),
    "rollingOut" : MessageLookupByLibrary.simpleMessage("Ausrollen")
  };
}
