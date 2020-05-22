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

  static m1(name) => "Lehne Authentifizierungsanfrage für ${name} ab.";

  static m2(e) =>
      "Ein unbekannter Fehler ist aufgetreten. Authentifizierung fehlgeschlagen: ${e}";

  static m3(name) =>
      "Die Firebase-Konfiguration des Tokens ${name} unterscheidet sich von der zur Zeit von der App verwendeten. Zwei verschiedene Konfigurationen werden nicht unterstützt.";

  static m4(name, errorCode) =>
      "Akzeptieren der Authentifizierungsanfrage für ${name} fehlgeschlagen. Fehlercode: ${errorCode}";

  static m5(name, errorCode) =>
      "Ausrollen von ${name} ist fehlgeschlagen. Fehlercode: ${errorCode}";

  static m6(e) =>
      "Ein unbekannter Fehler ist aufgetreten. Aurollen nicht möglich: ${e}";

  static m7(name) =>
      "Der Token ${name} ist nicht mehr gültig, ausrollen ist daher nicht möglich.";

  static m8(otpValue) =>
      "Passwort \"${otpValue}\" wurde in die Zwischenablage kopiert.";

  final messages = _notInlinedMessages(_notInlinedMessages);

  static _notInlinedMessages(_) => <String, Function>{
        "About": MessageLookupByLibrary.simpleMessage("Über"),
        "Add token": MessageLookupByLibrary.simpleMessage("Token hinzufügen"),
        "Algorithm": MessageLookupByLibrary.simpleMessage("Algorithmus"),
        "Are you sure you want to delete": MessageLookupByLibrary.simpleMessage(
            "Bestätigen sie das Löschen von"),
        "Cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "Confirm deletion":
            MessageLookupByLibrary.simpleMessage("Löschen bestätigen"),
        "Dark theme": MessageLookupByLibrary.simpleMessage("Dunkles Thema"),
        "Delete": MessageLookupByLibrary.simpleMessage("Löschen"),
        "Digits": MessageLookupByLibrary.simpleMessage("Ziffern"),
        "Dismiss": MessageLookupByLibrary.simpleMessage("Schließen"),
        "Encoding": MessageLookupByLibrary.simpleMessage("Verschlüsselung"),
        "Enter details for token":
            MessageLookupByLibrary.simpleMessage("Neuen Token konfigurieren"),
        "Generating phone part":
            MessageLookupByLibrary.simpleMessage("Generiere Telefonanteil"),
        "Light theme": MessageLookupByLibrary.simpleMessage("Helles Thema"),
        "Name": MessageLookupByLibrary.simpleMessage("Name"),
        "Next": MessageLookupByLibrary.simpleMessage("Weiter"),
        "Period": MessageLookupByLibrary.simpleMessage("Periode"),
        "Phone part:": MessageLookupByLibrary.simpleMessage("Telefonanteil:"),
        "Please enter a name for this token.":
            MessageLookupByLibrary.simpleMessage(
                "Bitte geben Sie einen Namen für diesen Token ein."),
        "Please enter a secret for this token.":
            MessageLookupByLibrary.simpleMessage(
                "Bitte geben Sie ein Geheimnis für diesen Token ein."),
        "Rename": MessageLookupByLibrary.simpleMessage("Umbenennen"),
        "Rename token":
            MessageLookupByLibrary.simpleMessage("Token umbenennen"),
        "Scan QR code": MessageLookupByLibrary.simpleMessage("Scanne QR-code"),
        "Scan QR-Code": MessageLookupByLibrary.simpleMessage("QR-Code scannen"),
        "Secret": MessageLookupByLibrary.simpleMessage("Geheimnis"),
        "Settings": MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "The secret does not fit the current encoding":
            MessageLookupByLibrary.simpleMessage(
                "Das Geheimnis entspricht nicht der gewählten\n Verschlüsselung."),
        "Theme": MessageLookupByLibrary.simpleMessage("Thema"),
        "Type": MessageLookupByLibrary.simpleMessage("Art"),
        "accept": MessageLookupByLibrary.simpleMessage("Akzeptieren"),
        "acceptPushAuthRequestFor": m0,
        "decline": MessageLookupByLibrary.simpleMessage("Ablehnen"),
        "decliningPushAuthRequestFor": m1,
        "errorAuthenticationFailedUnknownError": m2,
        "errorAuthenticationNotPossibleWithoutNetworkAccess":
            MessageLookupByLibrary.simpleMessage(
                "Fehlende Netzwerkverbindung. Authentifizierung nicht möglich."),
        "errorOnlyOneFirebaseProjectIsSupported": m3,
        "errorPushAuthRequestFailedFor": m4,
        "errorRollOutFailed": m5,
        "errorRollOutNoNetworkConnection": MessageLookupByLibrary.simpleMessage(
            "Fehlende Netzwerkverbindung. Ausrollen nicht möglich."),
        "errorRollOutUnknownError": m6,
        "errorTokenExpired": m7,
        "otpValueCopiedMessage": m8,
        "retry": MessageLookupByLibrary.simpleMessage("Erneut versuchen"),
        "retryRollOut": MessageLookupByLibrary.simpleMessage(
            "Ausrollen fehlgeschlagen, nochmal versuchen?"),
        "rollingOut": MessageLookupByLibrary.simpleMessage("Ausrollen")
      };
}
