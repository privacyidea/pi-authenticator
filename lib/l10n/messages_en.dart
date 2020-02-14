// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static m0(otpValue) => "Password \"${otpValue}\" copied to clipboard.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "Dark theme" : MessageLookupByLibrary.simpleMessage("Dark theme"),
    "Dismiss" : MessageLookupByLibrary.simpleMessage("Dismiss"),
    "Generating phone part" : MessageLookupByLibrary.simpleMessage("Generating phone part"),
    "Light theme" : MessageLookupByLibrary.simpleMessage("Light theme"),
    "Phone part:" : MessageLookupByLibrary.simpleMessage("Phone part:"),
    "Scan QR code" : MessageLookupByLibrary.simpleMessage("Scan QR code"),
    "Theme" : MessageLookupByLibrary.simpleMessage("Theme"),
    "otpValueCopiedMessage" : m0
  };
}
