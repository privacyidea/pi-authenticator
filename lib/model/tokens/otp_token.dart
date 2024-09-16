/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'dart:convert';

import '../../utils/identifiers.dart';
import '../../utils/logger.dart';
import '../enums/algorithms.dart';
import '../token_template.dart';
import '../token_import/token_origin_data.dart';
import '../token_container.dart';
import 'token.dart';

abstract class OTPToken extends Token {
  final Algorithms algorithm; // the hashing algorithm that is used to calculate the otp value
  final int digits; // the number of digits the otp value will have
  final String secret; // the secret based on which the otp value is calculated in base32
  String get otpValue; // the current otp value
  String get nextValue; // the next otp value
  Duration get showDuration {
    const Duration duration = Duration(seconds: 30);
    Logger.info('$runtimeType showDuration: ${duration.inSeconds} seconds');
    return duration;
  } // the duration the otp value is shown

  const OTPToken({
    required this.algorithm,
    required this.digits,
    required this.secret,
    required super.id,
    required super.type,
    super.containerSerial,
    super.checkedContainer,
    super.serial,
    super.pin,
    super.tokenImage,
    super.isLocked,
    super.isHidden,
    super.sortIndex,
    super.folderId,
    super.origin,
    super.label = '',
    super.issuer = '',
  });

  // @override
  // No changeable value in OTPToken
  // bool sameValuesAs(Token other) => super.sameValuesAs(other);

  @override
  bool isSameTokenAs(Token other) {
    return super.isSameTokenAs(other) && (other is OTPToken && other.secret == secret) && other.algorithm == algorithm && other.digits == digits;
  }

  @override
  OTPToken copyWith({
    String? serial,
    String? label,
    String? issuer,
    String? Function()? containerSerial,
    List<String>? checkedContainer,
    String? id,
    Algorithms? algorithm,
    int? digits,
    String? secret,
    bool? pin,
    bool? isLocked,
    bool? isHidden,
    String? tokenImage,
    int? sortIndex,
    int? Function()? folderId,
    TokenOriginData? origin,
  });

  @override
  String toString() {
    return 'OTP${super.toString()}algorithm: $algorithm, digits: $digits, pin: $pin, ';
  }

  /// This is used to create a map that typically was created from a uri.
  /// ```dart
  /// -------------------------- [Token] -------------------------------
  /// | OTP_AUTH_SERIAL: serial, (optional)                             |
  /// | OTP_AUTH_LABEL: label,                                          |
  /// | OTP_AUTH_ISSUER: issuer,                                        |
  /// | CONTAINER_SERIAL: containerSerial, (optional)                   |
  /// | CHECKED_CONTAINERS: checkedContainer,                          |
  /// | TOKEN_ID: id,                                                   |
  /// | OTP_AUTH_TYPE: type,                                            |
  /// | OTP_AUTH_IMAGE: tokenImage, (optional)                          |
  /// | SORTABLE_INDEX: sortIndex, (optional)                           |
  /// | FOLDER_ID: folderId, (optional)                                 |
  /// | TOKEN_ORIGIN: origin, (optional)                                |
  /// | OTP_AUTH_PIN: pin,                                              |
  /// | TOKEN_HIDDEN: isHidden,                                         |
  /// -------------------------------------------------------------------
  /// ------------------------- [OTPToken] ------------------------------
  /// | OTP_AUTH_ALGORITHM: algorithm,                                  |
  /// | OTP_AUTH_DIGITS: digits,                                        |
  /// | OTP_AUTH_SECRET_BASE32: secret,                                 |
  /// | OTP_AUTH_OTP_VALUES: [otpValue, nextValue], (if serial is null) |
  /// -------------------------------------------------------------------
  /// ```
  @override
  Map<String, dynamic> toOtpAuthMap() {
    Logger.debug('$OTP_AUTH_OTP_VALUES ${jsonEncode([otpValue, nextValue])}');
    return super.toOtpAuthMap()
      ..addAll({
        OTP_AUTH_ALGORITHM: algorithm.name,
        OTP_AUTH_DIGITS: digits.toString(),
        OTP_AUTH_SECRET_BASE32: secret,
        if (serial == null) OTP_AUTH_OTP_VALUES: [otpValue, nextValue],
      });
  }

  @override
  TokenTemplate toTemplate({TokenContainer? container}) =>
      super.toTemplate(container: container) ??
      TokenTemplate.withOtps(
        otpAuthMap: toOtpAuthMap(),
        otps: [otpValue, nextValue],
        container: container,
        additionalData: additionalData,
      );
}
