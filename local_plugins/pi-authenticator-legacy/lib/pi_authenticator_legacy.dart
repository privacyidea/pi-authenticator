// ignore_for_file: constant_identifier_names

/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2020 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:pi_authenticator_legacy/identifiers.dart';

const String METHOD_CHANNEL_ID = "it.netknights.piauthenticator.legacy";
const String METHOD_SIGN = "sign";
const String METHOD_VERIFY = "verify";

const String PARAMETER_SERIAL = "serial";
const String PARAMETER_MESSAGE = "message";
const String PARAMETER_SIGNED_DATA = "signedData";
const String PARAMETER_SIGNATURE = "signature";

class LegacyUtils {
  const LegacyUtils();
  static const MethodChannel _channel = MethodChannel(METHOD_CHANNEL_ID);

  Future<String> sign(String serial, String message) async => await (_channel.invokeMethod(METHOD_SIGN, {
        PARAMETER_SERIAL: serial,
        PARAMETER_MESSAGE: message,
      }).catchError((dynamic, stackTrace) {
        log(
          "Error occurred in [sign]",
          name: "pi_authenticator_legacy.dart",
          error: dynamic,
        );
        throw PlatformException(message: "Signing failed.", code: LEGACY_SIGNING_ERROR);
      }));

  Future<bool> verify(String serial, String signedData, String signature) async => await (_channel.invokeMethod(METHOD_VERIFY, {
        PARAMETER_SERIAL: serial,
        PARAMETER_SIGNED_DATA: signedData,
        PARAMETER_SIGNATURE: signature,
      }).catchError((dynamic, stackTrace) {
        log(
          "Error occurred in [verify]",
          name: "pi_authenticator_legacy.dart",
          error: dynamic,
        );

        return false;
      }));
}
