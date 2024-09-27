// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pi_server_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PiServerResponse<T extends PiServerResultValue> {
  dynamic get detail => throw _privateConstructorUsedError;
  int get id => throw _privateConstructorUsedError;
  String get jsonrpc => throw _privateConstructorUsedError;
  double get time => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;
  String get signature => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(dynamic detail, int id, String jsonrpc,
            T resultValue, double time, String version, String signature)
        success,
    required TResult Function(
            dynamic detail,
            int id,
            String jsonrpc,
            PiServerResultError resultError,
            double time,
            String version,
            String signature)
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(dynamic detail, int id, String jsonrpc, T resultValue,
            double time, String version, String signature)?
        success,
    TResult? Function(
            dynamic detail,
            int id,
            String jsonrpc,
            PiServerResultError resultError,
            double time,
            String version,
            String signature)?
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(dynamic detail, int id, String jsonrpc, T resultValue,
            double time, String version, String signature)?
        success,
    TResult Function(
            dynamic detail,
            int id,
            String jsonrpc,
            PiServerResultError resultError,
            double time,
            String version,
            String signature)?
        error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PiServerResponseSuccess<T> value) success,
    required TResult Function(PiServerResponseError<T> value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PiServerResponseSuccess<T> value)? success,
    TResult? Function(PiServerResponseError<T> value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PiServerResponseSuccess<T> value)? success,
    TResult Function(PiServerResponseError<T> value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of PiServerResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PiServerResponseCopyWith<T, PiServerResponse<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PiServerResponseCopyWith<T extends PiServerResultValue, $Res> {
  factory $PiServerResponseCopyWith(
          PiServerResponse<T> value, $Res Function(PiServerResponse<T>) then) =
      _$PiServerResponseCopyWithImpl<T, $Res, PiServerResponse<T>>;
  @useResult
  $Res call(
      {dynamic detail,
      int id,
      String jsonrpc,
      double time,
      String version,
      String signature});
}

/// @nodoc
class _$PiServerResponseCopyWithImpl<T extends PiServerResultValue, $Res,
        $Val extends PiServerResponse<T>>
    implements $PiServerResponseCopyWith<T, $Res> {
  _$PiServerResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PiServerResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detail = freezed,
    Object? id = null,
    Object? jsonrpc = null,
    Object? time = null,
    Object? version = null,
    Object? signature = null,
  }) {
    return _then(_value.copyWith(
      detail: freezed == detail
          ? _value.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as dynamic,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      jsonrpc: null == jsonrpc
          ? _value.jsonrpc
          : jsonrpc // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as double,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      signature: null == signature
          ? _value.signature
          : signature // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PiServerResponseSuccessImplCopyWith<
    T extends PiServerResultValue,
    $Res> implements $PiServerResponseCopyWith<T, $Res> {
  factory _$$PiServerResponseSuccessImplCopyWith(
          _$PiServerResponseSuccessImpl<T> value,
          $Res Function(_$PiServerResponseSuccessImpl<T>) then) =
      __$$PiServerResponseSuccessImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call(
      {dynamic detail,
      int id,
      String jsonrpc,
      T resultValue,
      double time,
      String version,
      String signature});
}

/// @nodoc
class __$$PiServerResponseSuccessImplCopyWithImpl<T extends PiServerResultValue,
        $Res>
    extends _$PiServerResponseCopyWithImpl<T, $Res,
        _$PiServerResponseSuccessImpl<T>>
    implements _$$PiServerResponseSuccessImplCopyWith<T, $Res> {
  __$$PiServerResponseSuccessImplCopyWithImpl(
      _$PiServerResponseSuccessImpl<T> _value,
      $Res Function(_$PiServerResponseSuccessImpl<T>) _then)
      : super(_value, _then);

  /// Create a copy of PiServerResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detail = freezed,
    Object? id = null,
    Object? jsonrpc = null,
    Object? resultValue = null,
    Object? time = null,
    Object? version = null,
    Object? signature = null,
  }) {
    return _then(_$PiServerResponseSuccessImpl<T>(
      detail: freezed == detail
          ? _value.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as dynamic,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      jsonrpc: null == jsonrpc
          ? _value.jsonrpc
          : jsonrpc // ignore: cast_nullable_to_non_nullable
              as String,
      resultValue: null == resultValue
          ? _value.resultValue
          : resultValue // ignore: cast_nullable_to_non_nullable
              as T,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as double,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      signature: null == signature
          ? _value.signature
          : signature // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$PiServerResponseSuccessImpl<T extends PiServerResultValue>
    extends PiServerResponseSuccess<T> {
  _$PiServerResponseSuccessImpl(
      {required this.detail,
      required this.id,
      required this.jsonrpc,
      required this.resultValue,
      required this.time,
      required this.version,
      required this.signature})
      : super._();

  @override
  final dynamic detail;
  @override
  final int id;
  @override
  final String jsonrpc;
  @override
  final T resultValue;
  @override
  final double time;
  @override
  final String version;
  @override
  final String signature;

  @override
  String toString() {
    return 'PiServerResponse<$T>.success(detail: $detail, id: $id, jsonrpc: $jsonrpc, resultValue: $resultValue, time: $time, version: $version, signature: $signature)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PiServerResponseSuccessImpl<T> &&
            const DeepCollectionEquality().equals(other.detail, detail) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.jsonrpc, jsonrpc) || other.jsonrpc == jsonrpc) &&
            const DeepCollectionEquality()
                .equals(other.resultValue, resultValue) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.signature, signature) ||
                other.signature == signature));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(detail),
      id,
      jsonrpc,
      const DeepCollectionEquality().hash(resultValue),
      time,
      version,
      signature);

  /// Create a copy of PiServerResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PiServerResponseSuccessImplCopyWith<T, _$PiServerResponseSuccessImpl<T>>
      get copyWith => __$$PiServerResponseSuccessImplCopyWithImpl<T,
          _$PiServerResponseSuccessImpl<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(dynamic detail, int id, String jsonrpc,
            T resultValue, double time, String version, String signature)
        success,
    required TResult Function(
            dynamic detail,
            int id,
            String jsonrpc,
            PiServerResultError resultError,
            double time,
            String version,
            String signature)
        error,
  }) {
    return success(detail, id, jsonrpc, resultValue, time, version, signature);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(dynamic detail, int id, String jsonrpc, T resultValue,
            double time, String version, String signature)?
        success,
    TResult? Function(
            dynamic detail,
            int id,
            String jsonrpc,
            PiServerResultError resultError,
            double time,
            String version,
            String signature)?
        error,
  }) {
    return success?.call(
        detail, id, jsonrpc, resultValue, time, version, signature);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(dynamic detail, int id, String jsonrpc, T resultValue,
            double time, String version, String signature)?
        success,
    TResult Function(
            dynamic detail,
            int id,
            String jsonrpc,
            PiServerResultError resultError,
            double time,
            String version,
            String signature)?
        error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(
          detail, id, jsonrpc, resultValue, time, version, signature);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PiServerResponseSuccess<T> value) success,
    required TResult Function(PiServerResponseError<T> value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PiServerResponseSuccess<T> value)? success,
    TResult? Function(PiServerResponseError<T> value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PiServerResponseSuccess<T> value)? success,
    TResult Function(PiServerResponseError<T> value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class PiServerResponseSuccess<T extends PiServerResultValue>
    extends PiServerResponse<T> {
  factory PiServerResponseSuccess(
      {required final dynamic detail,
      required final int id,
      required final String jsonrpc,
      required final T resultValue,
      required final double time,
      required final String version,
      required final String signature}) = _$PiServerResponseSuccessImpl<T>;
  PiServerResponseSuccess._() : super._();

  @override
  dynamic get detail;
  @override
  int get id;
  @override
  String get jsonrpc;
  T get resultValue;
  @override
  double get time;
  @override
  String get version;
  @override
  String get signature;

  /// Create a copy of PiServerResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PiServerResponseSuccessImplCopyWith<T, _$PiServerResponseSuccessImpl<T>>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PiServerResponseErrorImplCopyWith<
    T extends PiServerResultValue,
    $Res> implements $PiServerResponseCopyWith<T, $Res> {
  factory _$$PiServerResponseErrorImplCopyWith(
          _$PiServerResponseErrorImpl<T> value,
          $Res Function(_$PiServerResponseErrorImpl<T>) then) =
      __$$PiServerResponseErrorImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call(
      {dynamic detail,
      int id,
      String jsonrpc,
      PiServerResultError resultError,
      double time,
      String version,
      String signature});
}

/// @nodoc
class __$$PiServerResponseErrorImplCopyWithImpl<T extends PiServerResultValue,
        $Res>
    extends _$PiServerResponseCopyWithImpl<T, $Res,
        _$PiServerResponseErrorImpl<T>>
    implements _$$PiServerResponseErrorImplCopyWith<T, $Res> {
  __$$PiServerResponseErrorImplCopyWithImpl(
      _$PiServerResponseErrorImpl<T> _value,
      $Res Function(_$PiServerResponseErrorImpl<T>) _then)
      : super(_value, _then);

  /// Create a copy of PiServerResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detail = freezed,
    Object? id = null,
    Object? jsonrpc = null,
    Object? resultError = null,
    Object? time = null,
    Object? version = null,
    Object? signature = null,
  }) {
    return _then(_$PiServerResponseErrorImpl<T>(
      detail: freezed == detail
          ? _value.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as dynamic,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      jsonrpc: null == jsonrpc
          ? _value.jsonrpc
          : jsonrpc // ignore: cast_nullable_to_non_nullable
              as String,
      resultError: null == resultError
          ? _value.resultError
          : resultError // ignore: cast_nullable_to_non_nullable
              as PiServerResultError,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as double,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      signature: null == signature
          ? _value.signature
          : signature // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$PiServerResponseErrorImpl<T extends PiServerResultValue>
    extends PiServerResponseError<T> {
  _$PiServerResponseErrorImpl(
      {required this.detail,
      required this.id,
      required this.jsonrpc,
      required this.resultError,
      required this.time,
      required this.version,
      required this.signature})
      : super._();

  @override
  final dynamic detail;
  @override
  final int id;
  @override
  final String jsonrpc;
  @override
  final PiServerResultError resultError;
  @override
  final double time;
  @override
  final String version;
  @override
  final String signature;

  @override
  String toString() {
    return 'PiServerResponse<$T>.error(detail: $detail, id: $id, jsonrpc: $jsonrpc, resultError: $resultError, time: $time, version: $version, signature: $signature)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PiServerResponseErrorImpl<T> &&
            const DeepCollectionEquality().equals(other.detail, detail) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.jsonrpc, jsonrpc) || other.jsonrpc == jsonrpc) &&
            (identical(other.resultError, resultError) ||
                other.resultError == resultError) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.signature, signature) ||
                other.signature == signature));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(detail),
      id,
      jsonrpc,
      resultError,
      time,
      version,
      signature);

  /// Create a copy of PiServerResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PiServerResponseErrorImplCopyWith<T, _$PiServerResponseErrorImpl<T>>
      get copyWith => __$$PiServerResponseErrorImplCopyWithImpl<T,
          _$PiServerResponseErrorImpl<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(dynamic detail, int id, String jsonrpc,
            T resultValue, double time, String version, String signature)
        success,
    required TResult Function(
            dynamic detail,
            int id,
            String jsonrpc,
            PiServerResultError resultError,
            double time,
            String version,
            String signature)
        error,
  }) {
    return error(detail, id, jsonrpc, resultError, time, version, signature);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(dynamic detail, int id, String jsonrpc, T resultValue,
            double time, String version, String signature)?
        success,
    TResult? Function(
            dynamic detail,
            int id,
            String jsonrpc,
            PiServerResultError resultError,
            double time,
            String version,
            String signature)?
        error,
  }) {
    return error?.call(
        detail, id, jsonrpc, resultError, time, version, signature);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(dynamic detail, int id, String jsonrpc, T resultValue,
            double time, String version, String signature)?
        success,
    TResult Function(
            dynamic detail,
            int id,
            String jsonrpc,
            PiServerResultError resultError,
            double time,
            String version,
            String signature)?
        error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(detail, id, jsonrpc, resultError, time, version, signature);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PiServerResponseSuccess<T> value) success,
    required TResult Function(PiServerResponseError<T> value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PiServerResponseSuccess<T> value)? success,
    TResult? Function(PiServerResponseError<T> value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PiServerResponseSuccess<T> value)? success,
    TResult Function(PiServerResponseError<T> value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class PiServerResponseError<T extends PiServerResultValue>
    extends PiServerResponse<T> {
  factory PiServerResponseError(
      {required final dynamic detail,
      required final int id,
      required final String jsonrpc,
      required final PiServerResultError resultError,
      required final double time,
      required final String version,
      required final String signature}) = _$PiServerResponseErrorImpl<T>;
  PiServerResponseError._() : super._();

  @override
  dynamic get detail;
  @override
  int get id;
  @override
  String get jsonrpc;
  PiServerResultError get resultError;
  @override
  double get time;
  @override
  String get version;
  @override
  String get signature;

  /// Create a copy of PiServerResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PiServerResponseErrorImplCopyWith<T, _$PiServerResponseErrorImpl<T>>
      get copyWith => throw _privateConstructorUsedError;
}