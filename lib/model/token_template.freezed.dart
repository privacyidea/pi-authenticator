// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TokenTemplate _$TokenTemplateFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'withSerial':
      return _TokenTemplateWithSerial.fromJson(json);
    case 'withOtps':
      return _TokenTemplateWithOtps.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'TokenTemplate',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$TokenTemplate {
  Map<String, dynamic> get otpAuthMap => throw _privateConstructorUsedError;
  Map<String, dynamic> get additionalData => throw _privateConstructorUsedError;
  ContainerCredential? get container => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Map<String, dynamic> otpAuthMap, String serial,
            Map<String, dynamic> additionalData, ContainerCredential? container)
        withSerial,
    required TResult Function(
            Map<String, dynamic> otpAuthMap,
            List<String> otps,
            List<String> checkedContainers,
            Map<String, dynamic> additionalData,
            ContainerCredential? container)
        withOtps,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            Map<String, dynamic> otpAuthMap,
            String serial,
            Map<String, dynamic> additionalData,
            ContainerCredential? container)?
        withSerial,
    TResult? Function(
            Map<String, dynamic> otpAuthMap,
            List<String> otps,
            List<String> checkedContainers,
            Map<String, dynamic> additionalData,
            ContainerCredential? container)?
        withOtps,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            Map<String, dynamic> otpAuthMap,
            String serial,
            Map<String, dynamic> additionalData,
            ContainerCredential? container)?
        withSerial,
    TResult Function(
            Map<String, dynamic> otpAuthMap,
            List<String> otps,
            List<String> checkedContainers,
            Map<String, dynamic> additionalData,
            ContainerCredential? container)?
        withOtps,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_TokenTemplateWithSerial value) withSerial,
    required TResult Function(_TokenTemplateWithOtps value) withOtps,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_TokenTemplateWithSerial value)? withSerial,
    TResult? Function(_TokenTemplateWithOtps value)? withOtps,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_TokenTemplateWithSerial value)? withSerial,
    TResult Function(_TokenTemplateWithOtps value)? withOtps,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Serializes this TokenTemplate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenTemplateCopyWith<TokenTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenTemplateCopyWith<$Res> {
  factory $TokenTemplateCopyWith(
          TokenTemplate value, $Res Function(TokenTemplate) then) =
      _$TokenTemplateCopyWithImpl<$Res, TokenTemplate>;
  @useResult
  $Res call(
      {Map<String, dynamic> otpAuthMap,
      Map<String, dynamic> additionalData,
      ContainerCredential? container});

  $ContainerCredentialCopyWith<$Res>? get container;
}

/// @nodoc
class _$TokenTemplateCopyWithImpl<$Res, $Val extends TokenTemplate>
    implements $TokenTemplateCopyWith<$Res> {
  _$TokenTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? otpAuthMap = null,
    Object? additionalData = null,
    Object? container = freezed,
  }) {
    return _then(_value.copyWith(
      otpAuthMap: null == otpAuthMap
          ? _value.otpAuthMap
          : otpAuthMap // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      additionalData: null == additionalData
          ? _value.additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      container: freezed == container
          ? _value.container
          : container // ignore: cast_nullable_to_non_nullable
              as ContainerCredential?,
    ) as $Val);
  }

  /// Create a copy of TokenTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ContainerCredentialCopyWith<$Res>? get container {
    if (_value.container == null) {
      return null;
    }

    return $ContainerCredentialCopyWith<$Res>(_value.container!, (value) {
      return _then(_value.copyWith(container: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TokenTemplateWithSerialImplCopyWith<$Res>
    implements $TokenTemplateCopyWith<$Res> {
  factory _$$TokenTemplateWithSerialImplCopyWith(
          _$TokenTemplateWithSerialImpl value,
          $Res Function(_$TokenTemplateWithSerialImpl) then) =
      __$$TokenTemplateWithSerialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, dynamic> otpAuthMap,
      String serial,
      Map<String, dynamic> additionalData,
      ContainerCredential? container});

  @override
  $ContainerCredentialCopyWith<$Res>? get container;
}

/// @nodoc
class __$$TokenTemplateWithSerialImplCopyWithImpl<$Res>
    extends _$TokenTemplateCopyWithImpl<$Res, _$TokenTemplateWithSerialImpl>
    implements _$$TokenTemplateWithSerialImplCopyWith<$Res> {
  __$$TokenTemplateWithSerialImplCopyWithImpl(
      _$TokenTemplateWithSerialImpl _value,
      $Res Function(_$TokenTemplateWithSerialImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? otpAuthMap = null,
    Object? serial = null,
    Object? additionalData = null,
    Object? container = freezed,
  }) {
    return _then(_$TokenTemplateWithSerialImpl(
      otpAuthMap: null == otpAuthMap
          ? _value._otpAuthMap
          : otpAuthMap // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      serial: null == serial
          ? _value.serial
          : serial // ignore: cast_nullable_to_non_nullable
              as String,
      additionalData: null == additionalData
          ? _value._additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      container: freezed == container
          ? _value.container
          : container // ignore: cast_nullable_to_non_nullable
              as ContainerCredential?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenTemplateWithSerialImpl extends _TokenTemplateWithSerial
    with DiagnosticableTreeMixin {
  _$TokenTemplateWithSerialImpl(
      {required final Map<String, dynamic> otpAuthMap,
      required this.serial,
      final Map<String, dynamic> additionalData = const {},
      this.container,
      final String? $type})
      : _otpAuthMap = otpAuthMap,
        _additionalData = additionalData,
        $type = $type ?? 'withSerial',
        super._();

  factory _$TokenTemplateWithSerialImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenTemplateWithSerialImplFromJson(json);

  final Map<String, dynamic> _otpAuthMap;
  @override
  Map<String, dynamic> get otpAuthMap {
    if (_otpAuthMap is EqualUnmodifiableMapView) return _otpAuthMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_otpAuthMap);
  }

  @override
  final String serial;
  final Map<String, dynamic> _additionalData;
  @override
  @JsonKey()
  Map<String, dynamic> get additionalData {
    if (_additionalData is EqualUnmodifiableMapView) return _additionalData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_additionalData);
  }

  @override
  final ContainerCredential? container;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TokenTemplate.withSerial(otpAuthMap: $otpAuthMap, serial: $serial, additionalData: $additionalData, container: $container)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TokenTemplate.withSerial'))
      ..add(DiagnosticsProperty('otpAuthMap', otpAuthMap))
      ..add(DiagnosticsProperty('serial', serial))
      ..add(DiagnosticsProperty('additionalData', additionalData))
      ..add(DiagnosticsProperty('container', container));
  }

  /// Create a copy of TokenTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenTemplateWithSerialImplCopyWith<_$TokenTemplateWithSerialImpl>
      get copyWith => __$$TokenTemplateWithSerialImplCopyWithImpl<
          _$TokenTemplateWithSerialImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Map<String, dynamic> otpAuthMap, String serial,
            Map<String, dynamic> additionalData, ContainerCredential? container)
        withSerial,
    required TResult Function(
            Map<String, dynamic> otpAuthMap,
            List<String> otps,
            List<String> checkedContainers,
            Map<String, dynamic> additionalData,
            ContainerCredential? container)
        withOtps,
  }) {
    return withSerial(otpAuthMap, serial, additionalData, container);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            Map<String, dynamic> otpAuthMap,
            String serial,
            Map<String, dynamic> additionalData,
            ContainerCredential? container)?
        withSerial,
    TResult? Function(
            Map<String, dynamic> otpAuthMap,
            List<String> otps,
            List<String> checkedContainers,
            Map<String, dynamic> additionalData,
            ContainerCredential? container)?
        withOtps,
  }) {
    return withSerial?.call(otpAuthMap, serial, additionalData, container);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            Map<String, dynamic> otpAuthMap,
            String serial,
            Map<String, dynamic> additionalData,
            ContainerCredential? container)?
        withSerial,
    TResult Function(
            Map<String, dynamic> otpAuthMap,
            List<String> otps,
            List<String> checkedContainers,
            Map<String, dynamic> additionalData,
            ContainerCredential? container)?
        withOtps,
    required TResult orElse(),
  }) {
    if (withSerial != null) {
      return withSerial(otpAuthMap, serial, additionalData, container);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_TokenTemplateWithSerial value) withSerial,
    required TResult Function(_TokenTemplateWithOtps value) withOtps,
  }) {
    return withSerial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_TokenTemplateWithSerial value)? withSerial,
    TResult? Function(_TokenTemplateWithOtps value)? withOtps,
  }) {
    return withSerial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_TokenTemplateWithSerial value)? withSerial,
    TResult Function(_TokenTemplateWithOtps value)? withOtps,
    required TResult orElse(),
  }) {
    if (withSerial != null) {
      return withSerial(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenTemplateWithSerialImplToJson(
      this,
    );
  }
}

abstract class _TokenTemplateWithSerial extends TokenTemplate {
  factory _TokenTemplateWithSerial(
      {required final Map<String, dynamic> otpAuthMap,
      required final String serial,
      final Map<String, dynamic> additionalData,
      final ContainerCredential? container}) = _$TokenTemplateWithSerialImpl;
  _TokenTemplateWithSerial._() : super._();

  factory _TokenTemplateWithSerial.fromJson(Map<String, dynamic> json) =
      _$TokenTemplateWithSerialImpl.fromJson;

  @override
  Map<String, dynamic> get otpAuthMap;
  String get serial;
  @override
  Map<String, dynamic> get additionalData;
  @override
  ContainerCredential? get container;

  /// Create a copy of TokenTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenTemplateWithSerialImplCopyWith<_$TokenTemplateWithSerialImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TokenTemplateWithOtpsImplCopyWith<$Res>
    implements $TokenTemplateCopyWith<$Res> {
  factory _$$TokenTemplateWithOtpsImplCopyWith(
          _$TokenTemplateWithOtpsImpl value,
          $Res Function(_$TokenTemplateWithOtpsImpl) then) =
      __$$TokenTemplateWithOtpsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Map<String, dynamic> otpAuthMap,
      List<String> otps,
      List<String> checkedContainers,
      Map<String, dynamic> additionalData,
      ContainerCredential? container});

  @override
  $ContainerCredentialCopyWith<$Res>? get container;
}

/// @nodoc
class __$$TokenTemplateWithOtpsImplCopyWithImpl<$Res>
    extends _$TokenTemplateCopyWithImpl<$Res, _$TokenTemplateWithOtpsImpl>
    implements _$$TokenTemplateWithOtpsImplCopyWith<$Res> {
  __$$TokenTemplateWithOtpsImplCopyWithImpl(_$TokenTemplateWithOtpsImpl _value,
      $Res Function(_$TokenTemplateWithOtpsImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? otpAuthMap = null,
    Object? otps = null,
    Object? checkedContainers = null,
    Object? additionalData = null,
    Object? container = freezed,
  }) {
    return _then(_$TokenTemplateWithOtpsImpl(
      otpAuthMap: null == otpAuthMap
          ? _value._otpAuthMap
          : otpAuthMap // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      otps: null == otps
          ? _value._otps
          : otps // ignore: cast_nullable_to_non_nullable
              as List<String>,
      checkedContainers: null == checkedContainers
          ? _value._checkedContainers
          : checkedContainers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      additionalData: null == additionalData
          ? _value._additionalData
          : additionalData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      container: freezed == container
          ? _value.container
          : container // ignore: cast_nullable_to_non_nullable
              as ContainerCredential?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenTemplateWithOtpsImpl extends _TokenTemplateWithOtps
    with DiagnosticableTreeMixin {
  _$TokenTemplateWithOtpsImpl(
      {required final Map<String, dynamic> otpAuthMap,
      required final List<String> otps,
      required final List<String> checkedContainers,
      final Map<String, dynamic> additionalData = const {},
      this.container,
      final String? $type})
      : _otpAuthMap = otpAuthMap,
        _otps = otps,
        _checkedContainers = checkedContainers,
        _additionalData = additionalData,
        $type = $type ?? 'withOtps',
        super._();

  factory _$TokenTemplateWithOtpsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenTemplateWithOtpsImplFromJson(json);

  final Map<String, dynamic> _otpAuthMap;
  @override
  Map<String, dynamic> get otpAuthMap {
    if (_otpAuthMap is EqualUnmodifiableMapView) return _otpAuthMap;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_otpAuthMap);
  }

  final List<String> _otps;
  @override
  List<String> get otps {
    if (_otps is EqualUnmodifiableListView) return _otps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_otps);
  }

  final List<String> _checkedContainers;
  @override
  List<String> get checkedContainers {
    if (_checkedContainers is EqualUnmodifiableListView)
      return _checkedContainers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_checkedContainers);
  }

  final Map<String, dynamic> _additionalData;
  @override
  @JsonKey()
  Map<String, dynamic> get additionalData {
    if (_additionalData is EqualUnmodifiableMapView) return _additionalData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_additionalData);
  }

  @override
  final ContainerCredential? container;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TokenTemplate.withOtps(otpAuthMap: $otpAuthMap, otps: $otps, checkedContainers: $checkedContainers, additionalData: $additionalData, container: $container)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TokenTemplate.withOtps'))
      ..add(DiagnosticsProperty('otpAuthMap', otpAuthMap))
      ..add(DiagnosticsProperty('otps', otps))
      ..add(DiagnosticsProperty('checkedContainers', checkedContainers))
      ..add(DiagnosticsProperty('additionalData', additionalData))
      ..add(DiagnosticsProperty('container', container));
  }

  /// Create a copy of TokenTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenTemplateWithOtpsImplCopyWith<_$TokenTemplateWithOtpsImpl>
      get copyWith => __$$TokenTemplateWithOtpsImplCopyWithImpl<
          _$TokenTemplateWithOtpsImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Map<String, dynamic> otpAuthMap, String serial,
            Map<String, dynamic> additionalData, ContainerCredential? container)
        withSerial,
    required TResult Function(
            Map<String, dynamic> otpAuthMap,
            List<String> otps,
            List<String> checkedContainers,
            Map<String, dynamic> additionalData,
            ContainerCredential? container)
        withOtps,
  }) {
    return withOtps(
        otpAuthMap, otps, checkedContainers, additionalData, container);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            Map<String, dynamic> otpAuthMap,
            String serial,
            Map<String, dynamic> additionalData,
            ContainerCredential? container)?
        withSerial,
    TResult? Function(
            Map<String, dynamic> otpAuthMap,
            List<String> otps,
            List<String> checkedContainers,
            Map<String, dynamic> additionalData,
            ContainerCredential? container)?
        withOtps,
  }) {
    return withOtps?.call(
        otpAuthMap, otps, checkedContainers, additionalData, container);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            Map<String, dynamic> otpAuthMap,
            String serial,
            Map<String, dynamic> additionalData,
            ContainerCredential? container)?
        withSerial,
    TResult Function(
            Map<String, dynamic> otpAuthMap,
            List<String> otps,
            List<String> checkedContainers,
            Map<String, dynamic> additionalData,
            ContainerCredential? container)?
        withOtps,
    required TResult orElse(),
  }) {
    if (withOtps != null) {
      return withOtps(
          otpAuthMap, otps, checkedContainers, additionalData, container);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_TokenTemplateWithSerial value) withSerial,
    required TResult Function(_TokenTemplateWithOtps value) withOtps,
  }) {
    return withOtps(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_TokenTemplateWithSerial value)? withSerial,
    TResult? Function(_TokenTemplateWithOtps value)? withOtps,
  }) {
    return withOtps?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_TokenTemplateWithSerial value)? withSerial,
    TResult Function(_TokenTemplateWithOtps value)? withOtps,
    required TResult orElse(),
  }) {
    if (withOtps != null) {
      return withOtps(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenTemplateWithOtpsImplToJson(
      this,
    );
  }
}

abstract class _TokenTemplateWithOtps extends TokenTemplate {
  factory _TokenTemplateWithOtps(
      {required final Map<String, dynamic> otpAuthMap,
      required final List<String> otps,
      required final List<String> checkedContainers,
      final Map<String, dynamic> additionalData,
      final ContainerCredential? container}) = _$TokenTemplateWithOtpsImpl;
  _TokenTemplateWithOtps._() : super._();

  factory _TokenTemplateWithOtps.fromJson(Map<String, dynamic> json) =
      _$TokenTemplateWithOtpsImpl.fromJson;

  @override
  Map<String, dynamic> get otpAuthMap;
  List<String> get otps;
  List<String> get checkedContainers;
  @override
  Map<String, dynamic> get additionalData;
  @override
  ContainerCredential? get container;

  /// Create a copy of TokenTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenTemplateWithOtpsImplCopyWith<_$TokenTemplateWithOtpsImpl>
      get copyWith => throw _privateConstructorUsedError;
}
