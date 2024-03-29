//
//  Generated code. Do not modify.
//  source: GoogleAuthenticatorImport.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class GoogleAuthenticatorImport_Algorithm extends $pb.ProtobufEnum {
  static const GoogleAuthenticatorImport_Algorithm ALGORITHM_UNSPECIFIED = GoogleAuthenticatorImport_Algorithm._(0, _omitEnumNames ? '' : 'ALGORITHM_UNSPECIFIED');
  static const GoogleAuthenticatorImport_Algorithm ALGORITHM_SHA1 = GoogleAuthenticatorImport_Algorithm._(1, _omitEnumNames ? '' : 'ALGORITHM_SHA1');
  static const GoogleAuthenticatorImport_Algorithm ALGORITHM_SHA256 = GoogleAuthenticatorImport_Algorithm._(2, _omitEnumNames ? '' : 'ALGORITHM_SHA256');
  static const GoogleAuthenticatorImport_Algorithm ALGORITHM_SHA512 = GoogleAuthenticatorImport_Algorithm._(3, _omitEnumNames ? '' : 'ALGORITHM_SHA512');
  static const GoogleAuthenticatorImport_Algorithm ALGORITHM_MD5 = GoogleAuthenticatorImport_Algorithm._(4, _omitEnumNames ? '' : 'ALGORITHM_MD5');

  static const $core.List<GoogleAuthenticatorImport_Algorithm> values = <GoogleAuthenticatorImport_Algorithm> [
    ALGORITHM_UNSPECIFIED,
    ALGORITHM_SHA1,
    ALGORITHM_SHA256,
    ALGORITHM_SHA512,
    ALGORITHM_MD5,
  ];

  static final $core.Map<$core.int, GoogleAuthenticatorImport_Algorithm> _byValue = $pb.ProtobufEnum.initByValue(values);
  static GoogleAuthenticatorImport_Algorithm? valueOf($core.int value) => _byValue[value];

  const GoogleAuthenticatorImport_Algorithm._($core.int v, $core.String n) : super(v, n);
}

class GoogleAuthenticatorImport_DigitCount extends $pb.ProtobufEnum {
  static const GoogleAuthenticatorImport_DigitCount DIGIT_COUNT_UNSPECIFIED = GoogleAuthenticatorImport_DigitCount._(0, _omitEnumNames ? '' : 'DIGIT_COUNT_UNSPECIFIED');
  static const GoogleAuthenticatorImport_DigitCount DIGIT_COUNT_SIX = GoogleAuthenticatorImport_DigitCount._(1, _omitEnumNames ? '' : 'DIGIT_COUNT_SIX');
  static const GoogleAuthenticatorImport_DigitCount DIGIT_COUNT_EIGHT = GoogleAuthenticatorImport_DigitCount._(2, _omitEnumNames ? '' : 'DIGIT_COUNT_EIGHT');

  static const $core.List<GoogleAuthenticatorImport_DigitCount> values = <GoogleAuthenticatorImport_DigitCount> [
    DIGIT_COUNT_UNSPECIFIED,
    DIGIT_COUNT_SIX,
    DIGIT_COUNT_EIGHT,
  ];

  static final $core.Map<$core.int, GoogleAuthenticatorImport_DigitCount> _byValue = $pb.ProtobufEnum.initByValue(values);
  static GoogleAuthenticatorImport_DigitCount? valueOf($core.int value) => _byValue[value];

  const GoogleAuthenticatorImport_DigitCount._($core.int v, $core.String n) : super(v, n);
}

class GoogleAuthenticatorImport_OtpType extends $pb.ProtobufEnum {
  static const GoogleAuthenticatorImport_OtpType OTP_TYPE_UNSPECIFIED = GoogleAuthenticatorImport_OtpType._(0, _omitEnumNames ? '' : 'OTP_TYPE_UNSPECIFIED');
  static const GoogleAuthenticatorImport_OtpType OTP_TYPE_HOTP = GoogleAuthenticatorImport_OtpType._(1, _omitEnumNames ? '' : 'OTP_TYPE_HOTP');
  static const GoogleAuthenticatorImport_OtpType OTP_TYPE_TOTP = GoogleAuthenticatorImport_OtpType._(2, _omitEnumNames ? '' : 'OTP_TYPE_TOTP');

  static const $core.List<GoogleAuthenticatorImport_OtpType> values = <GoogleAuthenticatorImport_OtpType> [
    OTP_TYPE_UNSPECIFIED,
    OTP_TYPE_HOTP,
    OTP_TYPE_TOTP,
  ];

  static final $core.Map<$core.int, GoogleAuthenticatorImport_OtpType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static GoogleAuthenticatorImport_OtpType? valueOf($core.int value) => _byValue[value];

  const GoogleAuthenticatorImport_OtpType._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
