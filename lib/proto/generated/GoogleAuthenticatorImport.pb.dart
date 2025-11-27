// This is a generated file - do not edit.
//
// Generated from GoogleAuthenticatorImport.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'GoogleAuthenticatorImport.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'GoogleAuthenticatorImport.pbenum.dart';

class GoogleAuthenticatorImport_OtpParameters extends $pb.GeneratedMessage {
  factory GoogleAuthenticatorImport_OtpParameters({
    $core.List<$core.int>? secret,
    $core.String? name,
    $core.String? issuer,
    GoogleAuthenticatorImport_Algorithm? algorithm,
    GoogleAuthenticatorImport_DigitCount? digits,
    GoogleAuthenticatorImport_OtpType? type,
    $fixnum.Int64? counter,
  }) {
    final result = create();
    if (secret != null) result.secret = secret;
    if (name != null) result.name = name;
    if (issuer != null) result.issuer = issuer;
    if (algorithm != null) result.algorithm = algorithm;
    if (digits != null) result.digits = digits;
    if (type != null) result.type = type;
    if (counter != null) result.counter = counter;
    return result;
  }

  GoogleAuthenticatorImport_OtpParameters._();

  factory GoogleAuthenticatorImport_OtpParameters.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GoogleAuthenticatorImport_OtpParameters.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoogleAuthenticatorImport.OtpParameters',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'KeePassOTP'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'secret', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'issuer')
    ..aE<GoogleAuthenticatorImport_Algorithm>(
        4, _omitFieldNames ? '' : 'algorithm',
        enumValues: GoogleAuthenticatorImport_Algorithm.values)
    ..aE<GoogleAuthenticatorImport_DigitCount>(
        5, _omitFieldNames ? '' : 'digits',
        enumValues: GoogleAuthenticatorImport_DigitCount.values)
    ..aE<GoogleAuthenticatorImport_OtpType>(6, _omitFieldNames ? '' : 'type',
        enumValues: GoogleAuthenticatorImport_OtpType.values)
    ..aInt64(7, _omitFieldNames ? '' : 'counter')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoogleAuthenticatorImport_OtpParameters clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoogleAuthenticatorImport_OtpParameters copyWith(
          void Function(GoogleAuthenticatorImport_OtpParameters) updates) =>
      super.copyWith((message) =>
              updates(message as GoogleAuthenticatorImport_OtpParameters))
          as GoogleAuthenticatorImport_OtpParameters;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GoogleAuthenticatorImport_OtpParameters create() =>
      GoogleAuthenticatorImport_OtpParameters._();
  @$core.override
  GoogleAuthenticatorImport_OtpParameters createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GoogleAuthenticatorImport_OtpParameters getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<
          GoogleAuthenticatorImport_OtpParameters>(create);
  static GoogleAuthenticatorImport_OtpParameters? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get secret => $_getN(0);
  @$pb.TagNumber(1)
  set secret($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSecret() => $_has(0);
  @$pb.TagNumber(1)
  void clearSecret() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get issuer => $_getSZ(2);
  @$pb.TagNumber(3)
  set issuer($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIssuer() => $_has(2);
  @$pb.TagNumber(3)
  void clearIssuer() => $_clearField(3);

  @$pb.TagNumber(4)
  GoogleAuthenticatorImport_Algorithm get algorithm => $_getN(3);
  @$pb.TagNumber(4)
  set algorithm(GoogleAuthenticatorImport_Algorithm value) =>
      $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasAlgorithm() => $_has(3);
  @$pb.TagNumber(4)
  void clearAlgorithm() => $_clearField(4);

  @$pb.TagNumber(5)
  GoogleAuthenticatorImport_DigitCount get digits => $_getN(4);
  @$pb.TagNumber(5)
  set digits(GoogleAuthenticatorImport_DigitCount value) =>
      $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasDigits() => $_has(4);
  @$pb.TagNumber(5)
  void clearDigits() => $_clearField(5);

  @$pb.TagNumber(6)
  GoogleAuthenticatorImport_OtpType get type => $_getN(5);
  @$pb.TagNumber(6)
  set type(GoogleAuthenticatorImport_OtpType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasType() => $_has(5);
  @$pb.TagNumber(6)
  void clearType() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get counter => $_getI64(6);
  @$pb.TagNumber(7)
  set counter($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCounter() => $_has(6);
  @$pb.TagNumber(7)
  void clearCounter() => $_clearField(7);
}

class GoogleAuthenticatorImport extends $pb.GeneratedMessage {
  factory GoogleAuthenticatorImport({
    $core.Iterable<GoogleAuthenticatorImport_OtpParameters>? otpParameters,
    $core.int? version,
    $core.int? batchSize,
    $core.int? batchIndex,
    $core.int? batchId,
  }) {
    final result = create();
    if (otpParameters != null) result.otpParameters.addAll(otpParameters);
    if (version != null) result.version = version;
    if (batchSize != null) result.batchSize = batchSize;
    if (batchIndex != null) result.batchIndex = batchIndex;
    if (batchId != null) result.batchId = batchId;
    return result;
  }

  GoogleAuthenticatorImport._();

  factory GoogleAuthenticatorImport.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GoogleAuthenticatorImport.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GoogleAuthenticatorImport',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'KeePassOTP'),
      createEmptyInstance: create)
    ..pPM<GoogleAuthenticatorImport_OtpParameters>(
        1, _omitFieldNames ? '' : 'otpParameters',
        subBuilder: GoogleAuthenticatorImport_OtpParameters.create)
    ..aI(2, _omitFieldNames ? '' : 'version')
    ..aI(3, _omitFieldNames ? '' : 'batchSize')
    ..aI(4, _omitFieldNames ? '' : 'batchIndex')
    ..aI(5, _omitFieldNames ? '' : 'batchId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoogleAuthenticatorImport clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GoogleAuthenticatorImport copyWith(
          void Function(GoogleAuthenticatorImport) updates) =>
      super.copyWith((message) => updates(message as GoogleAuthenticatorImport))
          as GoogleAuthenticatorImport;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GoogleAuthenticatorImport create() => GoogleAuthenticatorImport._();
  @$core.override
  GoogleAuthenticatorImport createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GoogleAuthenticatorImport getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GoogleAuthenticatorImport>(create);
  static GoogleAuthenticatorImport? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GoogleAuthenticatorImport_OtpParameters> get otpParameters =>
      $_getList(0);

  @$pb.TagNumber(2)
  $core.int get version => $_getIZ(1);
  @$pb.TagNumber(2)
  set version($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get batchSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set batchSize($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBatchSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearBatchSize() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get batchIndex => $_getIZ(3);
  @$pb.TagNumber(4)
  set batchIndex($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBatchIndex() => $_has(3);
  @$pb.TagNumber(4)
  void clearBatchIndex() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get batchId => $_getIZ(4);
  @$pb.TagNumber(5)
  set batchId($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBatchId() => $_has(4);
  @$pb.TagNumber(5)
  void clearBatchId() => $_clearField(5);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
