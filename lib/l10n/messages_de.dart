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

  static m0(otpValue) => "Passwort \"${otpValue}\" wurde in die Zwischenablage kopiert.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "Dark theme" : MessageLookupByLibrary.simpleMessage("Dunkles Thema"),
    "Dismiss" : MessageLookupByLibrary.simpleMessage("Schließen"),
    "Generating phone part" : MessageLookupByLibrary.simpleMessage("Generiere Telefonanteil"),
    "Light theme" : MessageLookupByLibrary.simpleMessage("Helles Thema"),
    "Phone part:" : MessageLookupByLibrary.simpleMessage("Telefonanteil:"),
    "Scan QR code" : MessageLookupByLibrary.simpleMessage("Scanne QR code"),
    "Theme" : MessageLookupByLibrary.simpleMessage("Thema"),
    "otpValueCopiedMessage" : m0
  };
}
