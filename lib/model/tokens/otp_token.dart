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

import '../../utils/logger.dart';
import '../enums/algorithms.dart';
import '../token_container.dart';
import '../token_import/token_origin_data.dart';
import '../token_template.dart';
import 'token.dart';

abstract class OTPToken extends Token {
  /// [String] (optional) default = 'SHA1'
  static const String ALGORITHM = 'algorithm';

  /// [String] (optional) default = '6'
  static const String DIGITS = 'digits';

  /// [String] (required)
  static const String SECRET_BASE32 = 'secret';

  // additional data for the token

  /// If there is no serial, two otp values are stored in the otpAuthMap under this key as [List<String>] to identify the token.
  /// The first value is the current otp value, the second value is the next otp value.
  static const String OTP_VALUES = 'otp';

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
    super.isOffline,
  });

  // @override
  // No changeable value in OTPToken
  // bool sameValuesAs(Token other) => super.sameValuesAs(other);

  @override
  bool? isSameTokenAs(Token other) {
    if (other is! OTPToken) return false;
    if (super.isSameTokenAs(other) != null) return super.isSameTokenAs(other)!;
    if (secret != other.secret) return false;
    if (algorithm != other.algorithm) return false;
    if (digits != other.digits) return false;
    return null;
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
    bool? isOffline,
  });

  @override
  String toString() {
    return 'OTP${super.toString()}algorithm: $algorithm, digits: $digits, pin: $pin, ';
  }

  /// This is used to create a map that typically was created from a uri.
  /// ```dart
  ///  ------------------------- [Token] -------------------------------
  /// | Token.SERIAL: serial, (optional)                                |
  /// | Token.LABEL: label,                                             |
  /// | Token.ISSUER: issuer,                                           |
  /// | Token.CONTAINER_SERIAL: containerSerial, (optional)             |
  /// | Token.CHECKED_CONTAINERS: checkedContainer,                     |
  /// | Token.TOKEN_ID: id,                                             |
  /// | Token.TOKENTYPE_JSON: type,                                               |
  /// | Token.IMAGE: tokenImage, (optional)                             |
  /// | Token.SORTABLE_INDEX: sortIndex, (optional)                     |
  /// | Token.FOLDER_ID: folderId, (optional)                           |
  /// | Token.TOKEN_ORIGIN: origin, (optional)                          |
  /// | Token.PIN: pin,                                                 |
  /// | Token.TOKEN_HIDDEN: isHidden,                                   |
  ///  -----------------------------------------------------------------
  ///  ------------------------- [OTPToken] ----------------------------
  /// | ALGORITHM: algorithm,                                           |
  /// | DIGITS: digits,                                                 |
  /// | SECRET_BASE32: secret,                                          |
  /// | OTP_VALUES: [otpValue, nextValue], (if serial is null)          |
  ///  -----------------------------------------------------------------
  /// ```
  @override
  Map<String, dynamic> toOtpAuthMap() {
    Logger.debug('$OTP_VALUES ${jsonEncode([otpValue, nextValue])}');
    return super.toOtpAuthMap()
      ..addAll({
        ALGORITHM: algorithm.name,
        DIGITS: digits.toString(),
        SECRET_BASE32: secret,
        if (serial == null) OTP_VALUES: [otpValue, nextValue],
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
