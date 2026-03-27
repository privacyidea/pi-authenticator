/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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
import '../../utils/object_validator/object_validators.dart';
import '../enums/algorithms.dart';
import '../enums/force_biometric_option.dart';
import '../token_container.dart';
import '../token_import/token_origin_data.dart';
import '../token_template.dart';
import 'token.dart';

abstract class OTPToken extends Token {
  // --- Constants ---
  static const String ALGORITHM = 'algorithm';
  static const String DIGITS = 'digits';
  static const String SECRET_BASE32 = 'secret';
  static const String OTP_VALUES = 'otp';

  // --- Static Accessors & Validators ---
  static final Map<String, BaseValidator> otpAuthValidators = {
    ...Token.otpAuthValidators,
    ALGORITHM: Validators.algorithms.withDefault(Algorithms.SHA1),
    DIGITS: Validators.otpDigitsSafe,
    SECRET_BASE32: Validators.base32String,
  };

  static final Map<String, BaseValidator> additionalDataValidators = {
    ...Token.additionalDataValidators,
  };

  // --- Static Validation Methods ---
  static Map<String, Object?> validateOtpAuthMap(
    Map<String, dynamic> otpAuthMap,
  ) {
    return validateMap(
      map: otpAuthMap,
      validators: otpAuthValidators,
      name: 'OTPToken#otpAuthMap',
    );
  }

  static Map<String, Object?> validateAdditionalData(
    Map<String, dynamic> additionalData,
  ) {
    return validateMap(
      map: additionalData,
      validators: additionalDataValidators,
      name: 'OTPToken#additionalData',
    );
  }

  // --- Instance Properties ---
  final Algorithms algorithm;
  final int digits;
  final String secret;

  String get otpValue;
  String get nextValue;

  Duration get showDuration {
    const Duration duration = Duration(seconds: 30);
    Logger.info('$runtimeType showDuration: ${duration.inSeconds} seconds');
    return duration;
  }

  // --- Constructor ---
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
    super.forceBiometricOption,
  });

  // --- Methods ---

  /// Checks if this token is the same as another token, based on their properties.
  /// Returns `true` if they are the same, `false` if they are different, and `null` if it cannot be determined.
  /// The base implementation checks the common properties of all tokens, and the OTPToken implementation checks the OTP-specific properties.
  /// Subclasses can override this method to add more specific checks, but should call `super.isSameTokenAs(other)` to maintain the base checks.
  @override
  bool? isSameTokenAs(Token other) {
    if (other is! OTPToken) return false;
    final isSame = super.isSameTokenAs(other);
    if (isSame != null) return isSame;
    if (secret != other.secret) return false;
    if (algorithm != other.algorithm) return false;
    if (digits != other.digits) return false;
    return null;
  }

  @override
  OTPToken copyWith({
    String? Function()? serial,
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
    ForceBiometricOption? forceBiometricOption,
  });

  @override
  String toString() {
    return 'OTP${super.toString()}algorithm: $algorithm, digits: $digits, pin: $pin, ';
  }

  // --- Serialization Helpers ---
  @override
  Map<String, dynamic> toOtpAuthMap() {
    Logger.debug('$OTP_VALUES ${jsonEncode([otpValue, nextValue])}');
    return super.toOtpAuthMap()..addAll({
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
