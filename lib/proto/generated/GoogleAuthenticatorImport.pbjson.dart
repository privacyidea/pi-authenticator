// This is a generated file - do not edit.
//
// Generated from GoogleAuthenticatorImport.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use googleAuthenticatorImportDescriptor instead')
const GoogleAuthenticatorImport$json = {
  '1': 'GoogleAuthenticatorImport',
  '2': [
    {
      '1': 'otp_parameters',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.KeePassOTP.GoogleAuthenticatorImport.OtpParameters',
      '10': 'otpParameters'
    },
    {'1': 'version', '3': 2, '4': 1, '5': 5, '10': 'version'},
    {'1': 'batch_size', '3': 3, '4': 1, '5': 5, '10': 'batchSize'},
    {'1': 'batch_index', '3': 4, '4': 1, '5': 5, '10': 'batchIndex'},
    {'1': 'batch_id', '3': 5, '4': 1, '5': 5, '10': 'batchId'},
  ],
  '3': [GoogleAuthenticatorImport_OtpParameters$json],
  '4': [
    GoogleAuthenticatorImport_Algorithm$json,
    GoogleAuthenticatorImport_DigitCount$json,
    GoogleAuthenticatorImport_OtpType$json
  ],
};

@$core.Deprecated('Use googleAuthenticatorImportDescriptor instead')
const GoogleAuthenticatorImport_OtpParameters$json = {
  '1': 'OtpParameters',
  '2': [
    {'1': 'secret', '3': 1, '4': 1, '5': 12, '10': 'secret'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'issuer', '3': 3, '4': 1, '5': 9, '10': 'issuer'},
    {
      '1': 'algorithm',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.KeePassOTP.GoogleAuthenticatorImport.Algorithm',
      '10': 'algorithm'
    },
    {
      '1': 'digits',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.KeePassOTP.GoogleAuthenticatorImport.DigitCount',
      '10': 'digits'
    },
    {
      '1': 'type',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.KeePassOTP.GoogleAuthenticatorImport.OtpType',
      '10': 'type'
    },
    {'1': 'counter', '3': 7, '4': 1, '5': 3, '10': 'counter'},
  ],
};

@$core.Deprecated('Use googleAuthenticatorImportDescriptor instead')
const GoogleAuthenticatorImport_Algorithm$json = {
  '1': 'Algorithm',
  '2': [
    {'1': 'ALGORITHM_UNSPECIFIED', '2': 0},
    {'1': 'ALGORITHM_SHA1', '2': 1},
    {'1': 'ALGORITHM_SHA256', '2': 2},
    {'1': 'ALGORITHM_SHA512', '2': 3},
    {'1': 'ALGORITHM_MD5', '2': 4},
  ],
};

@$core.Deprecated('Use googleAuthenticatorImportDescriptor instead')
const GoogleAuthenticatorImport_DigitCount$json = {
  '1': 'DigitCount',
  '2': [
    {'1': 'DIGIT_COUNT_UNSPECIFIED', '2': 0},
    {'1': 'DIGIT_COUNT_SIX', '2': 1},
    {'1': 'DIGIT_COUNT_EIGHT', '2': 2},
  ],
};

@$core.Deprecated('Use googleAuthenticatorImportDescriptor instead')
const GoogleAuthenticatorImport_OtpType$json = {
  '1': 'OtpType',
  '2': [
    {'1': 'OTP_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'OTP_TYPE_HOTP', '2': 1},
    {'1': 'OTP_TYPE_TOTP', '2': 2},
  ],
};

/// Descriptor for `GoogleAuthenticatorImport`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List googleAuthenticatorImportDescriptor = $convert.base64Decode(
    'ChlHb29nbGVBdXRoZW50aWNhdG9ySW1wb3J0EloKDm90cF9wYXJhbWV0ZXJzGAEgAygLMjMuS2'
    'VlUGFzc09UUC5Hb29nbGVBdXRoZW50aWNhdG9ySW1wb3J0Lk90cFBhcmFtZXRlcnNSDW90cFBh'
    'cmFtZXRlcnMSGAoHdmVyc2lvbhgCIAEoBVIHdmVyc2lvbhIdCgpiYXRjaF9zaXplGAMgASgFUg'
    'liYXRjaFNpemUSHwoLYmF0Y2hfaW5kZXgYBCABKAVSCmJhdGNoSW5kZXgSGQoIYmF0Y2hfaWQY'
    'BSABKAVSB2JhdGNoSWQayQIKDU90cFBhcmFtZXRlcnMSFgoGc2VjcmV0GAEgASgMUgZzZWNyZX'
    'QSEgoEbmFtZRgCIAEoCVIEbmFtZRIWCgZpc3N1ZXIYAyABKAlSBmlzc3VlchJNCglhbGdvcml0'
    'aG0YBCABKA4yLy5LZWVQYXNzT1RQLkdvb2dsZUF1dGhlbnRpY2F0b3JJbXBvcnQuQWxnb3JpdG'
    'htUglhbGdvcml0aG0SSAoGZGlnaXRzGAUgASgOMjAuS2VlUGFzc09UUC5Hb29nbGVBdXRoZW50'
    'aWNhdG9ySW1wb3J0LkRpZ2l0Q291bnRSBmRpZ2l0cxJBCgR0eXBlGAYgASgOMi0uS2VlUGFzc0'
    '9UUC5Hb29nbGVBdXRoZW50aWNhdG9ySW1wb3J0Lk90cFR5cGVSBHR5cGUSGAoHY291bnRlchgH'
    'IAEoA1IHY291bnRlciJ5CglBbGdvcml0aG0SGQoVQUxHT1JJVEhNX1VOU1BFQ0lGSUVEEAASEg'
    'oOQUxHT1JJVEhNX1NIQTEQARIUChBBTEdPUklUSE1fU0hBMjU2EAISFAoQQUxHT1JJVEhNX1NI'
    'QTUxMhADEhEKDUFMR09SSVRITV9NRDUQBCJVCgpEaWdpdENvdW50EhsKF0RJR0lUX0NPVU5UX1'
    'VOU1BFQ0lGSUVEEAASEwoPRElHSVRfQ09VTlRfU0lYEAESFQoRRElHSVRfQ09VTlRfRUlHSFQQ'
    'AiJJCgdPdHBUeXBlEhgKFE9UUF9UWVBFX1VOU1BFQ0lGSUVEEAASEQoNT1RQX1RZUEVfSE9UUB'
    'ABEhEKDU9UUF9UWVBFX1RPVFAQAg==');
