import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';

const String METHOD_CHANNEL_ID = "it.netknights.piauthenticator.legacy";
const String METHOD_SIGN = "sign";
const String METHOD_VERIFY = "verify";
const String METHOD_LOAD_ALL_TOKENS = "load_all_tokens";
const String METHOD_LOAD_FIREBASE_CONFIG = "load_firebase_config";

const String PARAMETER_SERIAL = "serial";
const String PARAMETER_MESSAGE = "message";
const String PARAMETER_SIGNED_DATA = "signedData";
const String PARAMETER_SIGNATURE = "signature";

// TODO Specifiy error handling in correspondence wiht ios
//  Android: secretKeyWrapper unavailable when no native app was installed ->
//            error
//  iOS: ?

class Legacy {
  static const MethodChannel _channel = const MethodChannel(METHOD_CHANNEL_ID);

  static Future<String> sign(String serial, String message) async =>
      await _channel.invokeMethod(METHOD_SIGN, {
        PARAMETER_SERIAL: serial,
        PARAMETER_MESSAGE: message,
      }).catchError((dynamic, stackTrace) {
        log(
          "Error occurred",
          name: "pi_authenticator_legacy.dart",
          error: dynamic,
        );
        return false;
      });

  static Future<bool> verify(
          String serial, String signedData, String signature) async =>
      await _channel.invokeMethod(METHOD_VERIFY, {
        PARAMETER_SERIAL: serial,
        PARAMETER_SIGNED_DATA: signedData,
        PARAMETER_SIGNATURE: signature,
      }).catchError((dynamic, stackTrace) {
        log(
          "Error occurred",
          name: "pi_authenticator_legacy.dart",
          error: dynamic,
        );

        return false;
      });

  static Future<String> loadAllTokens() async => await _channel
          .invokeMethod(METHOD_LOAD_ALL_TOKENS)
          .catchError((dynamic, stackTrace) {
        log(
          "Error occurred",
          name: "pi_authenticator_legacy.dart",
          error: dynamic,
        );

        return "[]";
      });

  static Future<String> loadFirebaseConfig() async => await _channel
          .invokeMethod(METHOD_LOAD_FIREBASE_CONFIG)
          .catchError((dynamic, stackTrace) {
        log(
          "Error occurred",
          name: "pi_authenticator_legacy.dart",
          error: dynamic,
        );

        return "{}";
      });
}
