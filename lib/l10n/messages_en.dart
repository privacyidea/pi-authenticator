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

  static m0(name) => "Accepted authentication request for ${name}.";

  static m1(name) => "Are you sure you want to delete ${name}?";

  static m2(name) => "Declined authentication request for ${name}.";

  static m3(e) => "An unknown error occurred. Authentication failed: ${e}";

  static m4(name) => "The firebase configuration of ${name} differs from the one currently used by the app. Currently only one is supported.";

  static m5(name, errorCode) => "Accepting authentication request for ${name} failed. Error code: ${errorCode}";

  static m6(name, errorCode) => "Rolling out token ${name} failed. Error code: ${errorCode}";

  static m7(e) => "An unknown error occurred. Roll-out not possible: ${e}";

  static m8(name) => "Token ${name} is expired, roll-out not possible.";

  static m9(otpValue) => "Password \"${otpValue}\" copied to clipboard.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "About" : MessageLookupByLibrary.simpleMessage("About"),
    "Add token" : MessageLookupByLibrary.simpleMessage("Add token"),
    "Algorithm" : MessageLookupByLibrary.simpleMessage("Algorithm"),
    "Cancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "Confirm deletion" : MessageLookupByLibrary.simpleMessage("Confirm deletion"),
    "Dark theme" : MessageLookupByLibrary.simpleMessage("Dark theme"),
    "Delete" : MessageLookupByLibrary.simpleMessage("Delete"),
    "Digits" : MessageLookupByLibrary.simpleMessage("Digits"),
    "Dismiss" : MessageLookupByLibrary.simpleMessage("Dismiss"),
    "Enable polling" : MessageLookupByLibrary.simpleMessage("Enable polling"),
    "Encoding" : MessageLookupByLibrary.simpleMessage("Encoding"),
    "Enter details for token" : MessageLookupByLibrary.simpleMessage("Enter details for token"),
    "Generating phone part" : MessageLookupByLibrary.simpleMessage("Generating phone part"),
    "Light theme" : MessageLookupByLibrary.simpleMessage("Light theme"),
    "Miscellaneous" : MessageLookupByLibrary.simpleMessage("Miscellaneous"),
    "Name" : MessageLookupByLibrary.simpleMessage("Name"),
    "Next" : MessageLookupByLibrary.simpleMessage("Next"),
    "Period" : MessageLookupByLibrary.simpleMessage("Period"),
    "Phone part:" : MessageLookupByLibrary.simpleMessage("Phone part:"),
    "Please enter a name for this token." : MessageLookupByLibrary.simpleMessage("Please enter a name for this token."),
    "Please enter a secret for this token." : MessageLookupByLibrary.simpleMessage("Please enter a secret for this token."),
    "Rename" : MessageLookupByLibrary.simpleMessage("Rename"),
    "Rename token" : MessageLookupByLibrary.simpleMessage("Rename token"),
    "Request push challenges from the server periodically. Enable this if push challenges are not received normally." : MessageLookupByLibrary.simpleMessage("Request push challenges from the server periodically. Enable this if push challenges are not received normally."),
    "Scan QR code" : MessageLookupByLibrary.simpleMessage("Scan QR code"),
    "Scan QR-Code" : MessageLookupByLibrary.simpleMessage("Scan QR-Code"),
    "Secret" : MessageLookupByLibrary.simpleMessage("Secret"),
    "Settings" : MessageLookupByLibrary.simpleMessage("Settings"),
    "Some of the tokens are outdated and do not support polling" : MessageLookupByLibrary.simpleMessage("Some of the tokens are outdated and do not support polling"),
    "The firebase configuration is corrupted and cannot be used." : MessageLookupByLibrary.simpleMessage("The firebase configuration is corrupted and cannot be used."),
    "The secret does not fit the current encoding" : MessageLookupByLibrary.simpleMessage("The secret does not fit the current encoding"),
    "Theme" : MessageLookupByLibrary.simpleMessage("Theme"),
    "Type" : MessageLookupByLibrary.simpleMessage("Type"),
    "accept" : MessageLookupByLibrary.simpleMessage("Accept"),
    "acceptPushAuthRequestFor" : m0,
    "confirmDeletionOf" : m1,
    "decline" : MessageLookupByLibrary.simpleMessage("Decline"),
    "decliningPushAuthRequestFor" : m2,
    "errorAuthenticationFailedUnknownError" : m3,
    "errorAuthenticationNotPossibleWithoutNetworkAccess" : MessageLookupByLibrary.simpleMessage("No network connection. Authentication not possible."),
    "errorOnlyOneFirebaseProjectIsSupported" : m4,
    "errorPushAuthRequestFailedFor" : m5,
    "errorRollOutFailed" : m6,
    "errorRollOutNoNetworkConnection" : MessageLookupByLibrary.simpleMessage("No network connection. Roll-out not possible."),
    "errorRollOutUnknownError" : m7,
    "errorTokenExpired" : m8,
    "otpValueCopiedMessage" : m9,
    "retry" : MessageLookupByLibrary.simpleMessage("Retry"),
    "retryRollOut" : MessageLookupByLibrary.simpleMessage("Roll-out failed, please try again."),
    "rollingOut" : MessageLookupByLibrary.simpleMessage("Rolling out")
  };
}
