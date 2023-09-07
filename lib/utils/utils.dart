/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2023 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/l10n/app_localizations.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';

import 'identifiers.dart';

/// Inserts [char] at the position [pos] in the given String ([str]),
/// and returns the resulting String.
///
/// Example: insertCharAt('ABCD', ' ', 2) --> 'AB CD'
String insertCharAt(String str, String char, int pos) {
  return str.substring(0, pos) + char + str.substring(pos, str.length);
}

/// Inserts [' '] after every [period] characters in [str].
/// Trims leading and trailing whitespaces. Returns the resulting String.
///
/// Example: 'ABCD', 1 --> 'A B C D'
/// Example: 'ABCD', 2 --> 'AB CD'
///
/// If [period] is less than 1, the original String is returned.
String splitPeriodically(String str, int period) {
  if (period < 1) return str;
  String result = '';
  for (int i = 0; i < str.length; i++) {
    i % period == 0 ? result += ' ${str[i]}' : result += str[i];
  }

  return result.trim();
}

Algorithms mapStringToAlgorithm(String algoAsString) {
  for (Algorithms alg in Algorithms.values) {
    if (equalsIgnoreCase(enumAsString(alg), algoAsString)) {
      return alg;
    }
  }

  throw ArgumentError.value(algoAsString, 'algorAsString', '$algoAsString cannot be mapped to $Algorithms');
}

/// This implementation is taken from the library
/// [foundation](https://api.flutter.dev/flutter/foundation/describeEnum.html).
/// That library sadly depends on [dart.ui] and thus cannot be used in tests.
/// Therefore, only using this code enables us to use this library ([utils.dart])
/// in tests.
String enumAsString(Enum enumEntry) {
  final String description = enumEntry.toString();
  final int indexOfDot = description.indexOf('.');
  assert(indexOfDot != -1 && indexOfDot < description.length - 1);
  return description.substring(indexOfDot + 1);
}

bool equalsIgnoreCase(String s1, String s2) {
  return s1.toLowerCase() == s2.toLowerCase();
}

/// If permission is already given, this function does nothing
void checkNotificationPermission() async {
  if (kIsWeb || !Platform.isAndroid && !Platform.isIOS) return;
  var status = await Permission.notification.status;
  // TODO what to do if permanently denied?
  // Add a dialog before requesting?
  if (status.isPermanentlyDenied) return;
  if (status.isDenied) {
    await Permission.notification.request();
  }
}

String rolloutMsg(PushTokenRollOutState rolloutState, BuildContext context) => switch (rolloutState) {
      PushTokenRollOutState.rolloutNotStarted => AppLocalizations.of(context)!.rollingOut,
      PushTokenRollOutState.generatingRSAKeyPair => AppLocalizations.of(context)!.generatingRSAKeyPair,
      PushTokenRollOutState.generatingRSAKeyPairFailed => AppLocalizations.of(context)!.generatingRSAKeyPairFailed,
      PushTokenRollOutState.sendRSAPublicKey => AppLocalizations.of(context)!.sendingRSAPublicKey,
      PushTokenRollOutState.sendRSAPublicKeyFailed => AppLocalizations.of(context)!.sendingRSAPublicKeyFailed,
      PushTokenRollOutState.parsingResponse => AppLocalizations.of(context)!.parsingResponse,
      PushTokenRollOutState.parsingResponseFailed => AppLocalizations.of(context)!.parsingResponseFailed,
      PushTokenRollOutState.rolloutComplete => AppLocalizations.of(context)!.rolloutCompleted,
    };

String? getErrorMessageFromResponse(Response response) {
  String body = response.body;
  String? errorMessage;
  try {
    final json = jsonDecode(body) as Map<String, dynamic>;
    errorMessage = json['result']?['error']?['message'] as String?;
  } catch (e) {
    errorMessage = null;
  }
  if (errorMessage == null) {
    final statusMessage = _statusMessageFromCode[response.statusCode];
    if (statusMessage != null) {
      errorMessage = '${response.statusCode}: $statusMessage';
    } else {
      errorMessage = 'Status Code: ${response.statusCode}';
    }
  }
  return errorMessage;
}

Map<int, String> _statusMessageFromCode = {
  100: "Continue",
  101: "Switching Protocols",
  102: "Processing",
  200: "OK",
  201: "Created",
  202: "Accepted",
  203: "Non Authoritative Information",
  204: "No Content",
  205: "Reset Content",
  206: "Partial Content",
  207: "Multi-Status",
  300: "Multiple Choices",
  301: "Moved Permanently",
  302: "Moved Temporarily",
  303: "See Other",
  304: "Not Modified",
  305: "Use Proxy",
  307: "Temporary Redirect",
  308: "Permanent Redirect",
  400: "Bad Request",
  401: "Unauthorized",
  402: "Payment Required",
  403: "Forbidden",
  404: "Not Found",
  405: "Method Not Allowed",
  406: "Not Acceptable",
  407: "Proxy Authentication Required",
  408: "Request Timeout",
  409: "Conflict",
  410: "Gone",
  411: "Length Required",
  412: "Precondition Failed",
  413: "Request Entity Too Large",
  414: "Request-URI Too Long",
  415: "Unsupported Media Type",
  416: "Requested Range Not Satisfiable",
  417: "Expectation Failed",
  418: "I'm a teapot",
  419: "Insufficient Space on Resource",
  420: "Method Failure",
  422: "Unprocessable Entity",
  423: "Locked",
  424: "Failed Dependency",
  428: "Precondition Required",
  429: "Too Many Requests",
  431: "Request Header Fields Too Large",
  451: "Unavailable For Legal Reasons",
  500: "Internal Server Error",
  501: "Not Implemented",
  502: "Bad Gateway",
  503: "Service Unavailable",
  504: "Gateway Timeout",
  505: "HTTP Version Not Supported",
  507: "Insufficient Storage",
  511: "Network Authentication Required"
};
