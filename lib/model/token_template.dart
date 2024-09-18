// /*
//  * privacyIDEA Authenticator
//  *
//  * Author: Frank Merkel <frank.merkel@netknights.it>
//  *
//  * Copyright (c) 2024 NetKnights GmbH
//  *
//  * Licensed under the Apache License, Version 2.0 (the 'License');
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an 'AS IS' BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */

// We need some unnecessary_overrides to force to add the fields in factory constructors
// ignore_for_file: unnecessary_overrides

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:privacyidea_authenticator/model/enums/token_origin_source_type.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/model/tokens/otp_token.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';

import 'token_import/token_origin_data.dart';
import 'tokens/token.dart';

part 'token_template.freezed.dart';
part 'token_template.g.dart';

@freezed
class TokenTemplate with _$TokenTemplate {
  TokenTemplate._();

  factory TokenTemplate.withSerial({
    required Map<String, dynamic> otpAuthMap,
    required String serial,
    @Default({}) Map<String, dynamic> additionalData,
    TokenContainer? container,
  }) = _TokenTemplateWithSerial;

  /// [ otpAuthMap ]: The map containing the OTP token data. May contain the secret.
  factory TokenTemplate.withOtps({
    required Map<String, dynamic> otpAuthMap,
    required List<String> otps,
    @Default({}) Map<String, dynamic> additionalData,
    TokenContainer? container,
  }) = _TokenTemplateWithOtps;

  List<String> get keys => otpAuthMap.keys.toList();
  List<dynamic> get values => otpAuthMap.values.toList();

  String? get serial => validateOptional(
        value: otpAuthMap[OTP_AUTH_SERIAL],
        validator: const ObjectValidatorNullable<String>(),
        name: OTP_AUTH_SERIAL,
      );

  String? get type => validateOptional(
        value: otpAuthMap[OTP_AUTH_TYPE],
        validator: const ObjectValidatorNullable<String>(),
        name: OTP_AUTH_TYPE,
      );

  List<String>? get otpValues => this is _TokenTemplateWithOtps ? (this as _TokenTemplateWithOtps).otps : null;

  String? get containerSerial => validateOptional(
        value: otpAuthMap[CONTAINER_SERIAL],
        validator: const ObjectValidatorNullable<String>(),
        name: CONTAINER_SERIAL,
      );

  Map<String, dynamic> get otpAuthMapSafeToSend => Map<String, dynamic>.from(otpAuthMap)..remove(OTP_AUTH_SECRET_BASE32);

  @override
  operator ==(Object other) {
    if (other is! TokenTemplate) return false;
    if (otpAuthMap.length != other.otpAuthMap.length) return false;
    for (var key in otpAuthMap.keys) {
      if (otpAuthMap[key].toString() != other.otpAuthMap[key].toString()) {
        return false;
      }
    }
    return true;
  }

  factory TokenTemplate.fromJson(Map<String, dynamic> json) => _$TokenTemplateFromJson(json);

  Token toToken() {
    final additionalData = Map<String, dynamic>.from(this.additionalData);
    if (container != null) {
      additionalData[Token.CONTAINER_SERIAL] = container!.serial;
    }
    if (additionalData[Token.ORIGIN] != null) {
      additionalData[Token.ORIGIN] = container != null
          ? TokenOriginData(
              appName: '${container!.serverName} (${container!.serial})',
              data: otpAuthMap.toString(),
              source: TokenOriginSourceType.container,
              isPrivacyIdeaToken: true,
            )
          : TokenOriginData.unknown(otpAuthMap);
    }
    return Token.fromOtpAuthMap(otpAuthMap, additionalData: additionalData);
  }

  /// Adds all key/value pairs of [other] to this map.
  ///
  /// If a key of [other] is already in this map, its value is overwritten.
  ///
  /// The operation is equivalent to doing `this[key] = value` for each key
  /// and associated value in other. It iterates over [other], which must
  /// therefore not change during the iteration.
  /// ```dart
  /// final planets = <int, String>{1: 'Mercury', 2: 'Earth'};
  /// planets.addAll({5: 'Jupiter', 6: 'Saturn'});
  /// print(planets); // {1: Mercury, 2: Earth, 5: Jupiter, 6: Saturn}
  /// ```
  TokenTemplate withOtpAuthData(Map<String, dynamic> otpAuthMap) {
    final newOtpAuthMap = Map<String, dynamic>.from(this.otpAuthMap)..addAll(otpAuthMap);
    return copyWith(otpAuthMap: newOtpAuthMap);
  }

  TokenTemplate withAditionalData(Map<String, dynamic> additionalData) {
    final newAdditionalData = Map<String, dynamic>.from(this.additionalData)..addAll(additionalData);
    return copyWith(additionalData: newAdditionalData);
  }

  @override
  int get hashCode => Object.hashAllUnordered([
        ...otpAuthMap.keys.map((key) => '$key:${otpAuthMap[key]}'),
        ...additionalData.keys.map((key) => '$key:${additionalData[key]}'),
      ]);

  bool isSameTokenAs(TokenTemplate? other) {
    if (other == null) return false;
    if (serial != null && serial == other.serial) return true;
    if (otpValues != null && otpValues!.isNotEmpty && other is OTPToken && otpValues == other.otpValues) return true;
    return false;
  }

  // bool hasSameValuesAs(TokenTemplate serverTokenTemplate) {
  //   Logger.debug('serverTokenTemplate.keys: ${serverTokenTemplate.keys}', name: 'TokenTemplate#hasSameValuesAs');
  //   for (var key in serverTokenTemplate.keys) {
  //     if (otpAuthMap[key] != serverTokenTemplate.otpAuthMap[key]) {
  //       Logger.debug('TokenTemplate has different values for key "$key": ${otpAuthMap[key]} != ${serverTokenTemplate.otpAuthMap[key]}',
  //           name: 'TokenTemplate#hasSameValuesAs');
  //       return false;
  //     }
  //   }
  //   Logger.debug(
  //     'AppTokenTemplate serial $serial/otp ($otpValues) has same values as serverTokenTemplate serial ${serverTokenTemplate.serial}/id ${serverTokenTemplate.otpValues}',
  //     name: 'TokenTemplate#hasSameValuesAs',
  //   );
  //   return true;
  // }

  // bool tokenWouldBeUpdated(Token token) {
  //   Logger.debug('Checking if token would be updated', name: 'TokenTemplate#tokenWouldBeUpdated');
  //   final tokenTemplate = token.toTemplate(this);
  //   Logger.debug('TokenTemplate: \n$tokenTemplate\n has same values as \n$this\n ?', name: 'TokenTemplate#tokenWouldBeUpdated');
  //   return tokenTemplate?.hasSameValuesAs(this) == false;
  // }
}
