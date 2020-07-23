// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a messages locale. All the
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
  String get localeName => 'messages';

  static m0(name) => "Accepted authentication request for ${name}.";

  static m1(name) => "Declined authentication request for ${name}.";

  static m2(e) => "An unknown error occurred. Authentication failed: ${e}";

  static m3(name) =>
      "The firebase configuration of ${name} differs from the one currently used by the app. Currently only one is supported.";

  static m4(name, errorCode) =>
      "Accepting authentication request for ${name} failed. Error code: ${errorCode}";

  static m5(name, errorCode) =>
      "Rolling out token ${name} failed.Error code: ${errorCode}";

  static m6(e) => "An unknown error occurred. Roll-out not possible: ${e}";

  static m7(name) => "Token ${name} is expired, roll-out not possible.";

  static m8(otpValue) => "Password \"${otpValue}\" copied to clipboard.";

  final messages = _notInlinedMessages(_notInlinedMessages);

  static _notInlinedMessages(_) => <String, Function>{
        "About": MessageLookupByLibrary.simpleMessage("About"),
        "Add token": MessageLookupByLibrary.simpleMessage("Add token"),
        "Algorithm": MessageLookupByLibrary.simpleMessage("Algorithm"),
        "Are you sure you want to delete": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete"),
        "Cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "Confirm deletion":
            MessageLookupByLibrary.simpleMessage("Confirm deletion"),
        "Dark theme": MessageLookupByLibrary.simpleMessage("Dark theme"),
        "Delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "Digits": MessageLookupByLibrary.simpleMessage("Digits"),
        "Dismiss": MessageLookupByLibrary.simpleMessage("Dismiss"),
        "Encoding": MessageLookupByLibrary.simpleMessage("Encoding"),
        "Enter details for token":
            MessageLookupByLibrary.simpleMessage("Enter details for token"),
        "Generating phone part":
            MessageLookupByLibrary.simpleMessage("Generating phone part"),
        "Light theme": MessageLookupByLibrary.simpleMessage("Light theme"),
        "Name": MessageLookupByLibrary.simpleMessage("Name"),
        "Next": MessageLookupByLibrary.simpleMessage("Next"),
        "Period": MessageLookupByLibrary.simpleMessage("Period"),
        "Phone part:": MessageLookupByLibrary.simpleMessage("Phone part:"),
        "Please enter a name for this token.":
            MessageLookupByLibrary.simpleMessage(
                "Please enter a name for this token."),
        "Please enter a secret for this token.":
            MessageLookupByLibrary.simpleMessage(
                "Please enter a secret for this token."),
        "Rename": MessageLookupByLibrary.simpleMessage("Rename"),
        "Rename token": MessageLookupByLibrary.simpleMessage("Rename token"),
        "Scan QR code": MessageLookupByLibrary.simpleMessage("Scan QR code"),
        "Scan QR-Code": MessageLookupByLibrary.simpleMessage("Scan QR-Code"),
        "Secret": MessageLookupByLibrary.simpleMessage("Secret"),
        "Settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "The secret does not fit the current encoding":
            MessageLookupByLibrary.simpleMessage(
                "The secret does not fit the current encoding"),
        "Theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "Type": MessageLookupByLibrary.simpleMessage("Type"),
        "accept": MessageLookupByLibrary.simpleMessage("Accept"),
        "acceptPushAuthRequestFor": m0,
        "decline": MessageLookupByLibrary.simpleMessage("Decline"),
        "decliningPushAuthRequestFor": m1,
        "errorAuthenticationFailedUnknownError": m2,
        "errorAuthenticationNotPossibleWithoutNetworkAccess":
            MessageLookupByLibrary.simpleMessage(
                "No network connection. Authentication not possible."),
        "errorOnlyOneFirebaseProjectIsSupported": m3,
        "errorPushAuthRequestFailedFor": m4,
        "errorRollOutFailed": m5,
        "errorRollOutNoNetworkConnection": MessageLookupByLibrary.simpleMessage(
            "No network connection. Roll-out not possible."),
        "errorRollOutUnknownError": m6,
        "errorTokenExpired": m7,
        "otpValueCopiedMessage": m8,
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "retryRollOut": MessageLookupByLibrary.simpleMessage(
            "Roll-out failed, please try again."),
        "rollingOut": MessageLookupByLibrary.simpleMessage("Rolling out")
      };
}
