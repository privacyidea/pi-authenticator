// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'processor_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProcessorResult<T> {
  TypeValidatorRequired<ResultHandler>? get resultHandlerType =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T resultData,
            TypeValidatorRequired<ResultHandler>? resultHandlerType)
        success,
    required TResult Function(String message, dynamic error,
            TypeValidatorRequired<ResultHandler>? resultHandlerType)
        failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T resultData,
            TypeValidatorRequired<ResultHandler>? resultHandlerType)?
        success,
    TResult? Function(String message, dynamic error,
            TypeValidatorRequired<ResultHandler>? resultHandlerType)?
        failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T resultData,
            TypeValidatorRequired<ResultHandler>? resultHandlerType)?
        success,
    TResult Function(String message, dynamic error,
            TypeValidatorRequired<ResultHandler>? resultHandlerType)?
        failed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProcessorResultSuccess<T> value) success,
    required TResult Function(ProcessorResultFailed<T> value) failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProcessorResultSuccess<T> value)? success,
    TResult? Function(ProcessorResultFailed<T> value)? failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProcessorResultSuccess<T> value)? success,
    TResult Function(ProcessorResultFailed<T> value)? failed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of ProcessorResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProcessorResultCopyWith<T, ProcessorResult<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProcessorResultCopyWith<T, $Res> {
  factory $ProcessorResultCopyWith(
          ProcessorResult<T> value, $Res Function(ProcessorResult<T>) then) =
      _$ProcessorResultCopyWithImpl<T, $Res, ProcessorResult<T>>;
  @useResult
  $Res call({TypeValidatorRequired<ResultHandler>? resultHandlerType});
}

/// @nodoc
class _$ProcessorResultCopyWithImpl<T, $Res, $Val extends ProcessorResult<T>>
    implements $ProcessorResultCopyWith<T, $Res> {
  _$ProcessorResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProcessorResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? resultHandlerType = freezed,
  }) {
    return _then(_value.copyWith(
      resultHandlerType: freezed == resultHandlerType
          ? _value.resultHandlerType
          : resultHandlerType // ignore: cast_nullable_to_non_nullable
              as TypeValidatorRequired<ResultHandler>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProcessorResultSuccessImplCopyWith<T, $Res>
    implements $ProcessorResultCopyWith<T, $Res> {
  factory _$$ProcessorResultSuccessImplCopyWith(
          _$ProcessorResultSuccessImpl<T> value,
          $Res Function(_$ProcessorResultSuccessImpl<T>) then) =
      __$$ProcessorResultSuccessImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call(
      {T resultData, TypeValidatorRequired<ResultHandler>? resultHandlerType});
}

/// @nodoc
class __$$ProcessorResultSuccessImplCopyWithImpl<T, $Res>
    extends _$ProcessorResultCopyWithImpl<T, $Res,
        _$ProcessorResultSuccessImpl<T>>
    implements _$$ProcessorResultSuccessImplCopyWith<T, $Res> {
  __$$ProcessorResultSuccessImplCopyWithImpl(
      _$ProcessorResultSuccessImpl<T> _value,
      $Res Function(_$ProcessorResultSuccessImpl<T>) _then)
      : super(_value, _then);

  /// Create a copy of ProcessorResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? resultData = freezed,
    Object? resultHandlerType = freezed,
  }) {
    return _then(_$ProcessorResultSuccessImpl<T>(
      freezed == resultData
          ? _value.resultData
          : resultData // ignore: cast_nullable_to_non_nullable
              as T,
      resultHandlerType: freezed == resultHandlerType
          ? _value.resultHandlerType
          : resultHandlerType // ignore: cast_nullable_to_non_nullable
              as TypeValidatorRequired<ResultHandler>?,
    ));
  }
}

/// @nodoc

class _$ProcessorResultSuccessImpl<T> extends ProcessorResultSuccess<T> {
  const _$ProcessorResultSuccessImpl(this.resultData, {this.resultHandlerType})
      : super._();

  @override
  final T resultData;
  @override
  final TypeValidatorRequired<ResultHandler>? resultHandlerType;

  @override
  String toString() {
    return 'ProcessorResult<$T>.success(resultData: $resultData, resultHandlerType: $resultHandlerType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProcessorResultSuccessImpl<T> &&
            const DeepCollectionEquality()
                .equals(other.resultData, resultData) &&
            (identical(other.resultHandlerType, resultHandlerType) ||
                other.resultHandlerType == resultHandlerType));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(resultData), resultHandlerType);

  /// Create a copy of ProcessorResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProcessorResultSuccessImplCopyWith<T, _$ProcessorResultSuccessImpl<T>>
      get copyWith => __$$ProcessorResultSuccessImplCopyWithImpl<T,
          _$ProcessorResultSuccessImpl<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T resultData,
            TypeValidatorRequired<ResultHandler>? resultHandlerType)
        success,
    required TResult Function(String message, dynamic error,
            TypeValidatorRequired<ResultHandler>? resultHandlerType)
        failed,
  }) {
    return success(resultData, resultHandlerType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T resultData,
            TypeValidatorRequired<ResultHandler>? resultHandlerType)?
        success,
    TResult? Function(String message, dynamic error,
            TypeValidatorRequired<ResultHandler>? resultHandlerType)?
        failed,
  }) {
    return success?.call(resultData, resultHandlerType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T resultData,
            TypeValidatorRequired<ResultHandler>? resultHandlerType)?
        success,
    TResult Function(String message, dynamic error,
            TypeValidatorRequired<ResultHandler>? resultHandlerType)?
        failed,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(resultData, resultHandlerType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProcessorResultSuccess<T> value) success,
    required TResult Function(ProcessorResultFailed<T> value) failed,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProcessorResultSuccess<T> value)? success,
    TResult? Function(ProcessorResultFailed<T> value)? failed,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProcessorResultSuccess<T> value)? success,
    TResult Function(ProcessorResultFailed<T> value)? failed,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class ProcessorResultSuccess<T> extends ProcessorResult<T> {
  const factory ProcessorResultSuccess(final T resultData,
          {final TypeValidatorRequired<ResultHandler>? resultHandlerType}) =
      _$ProcessorResultSuccessImpl<T>;
  const ProcessorResultSuccess._() : super._();

  T get resultData;
  @override
  TypeValidatorRequired<ResultHandler>? get resultHandlerType;

  /// Create a copy of ProcessorResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProcessorResultSuccessImplCopyWith<T, _$ProcessorResultSuccessImpl<T>>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ProcessorResultFailedImplCopyWith<T, $Res>
    implements $ProcessorResultCopyWith<T, $Res> {
  factory _$$ProcessorResultFailedImplCopyWith(
          _$ProcessorResultFailedImpl<T> value,
          $Res Function(_$ProcessorResultFailedImpl<T>) then) =
      __$$ProcessorResultFailedImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call(
      {String message,
      dynamic error,
      TypeValidatorRequired<ResultHandler>? resultHandlerType});
}

/// @nodoc
class __$$ProcessorResultFailedImplCopyWithImpl<T, $Res>
    extends _$ProcessorResultCopyWithImpl<T, $Res,
        _$ProcessorResultFailedImpl<T>>
    implements _$$ProcessorResultFailedImplCopyWith<T, $Res> {
  __$$ProcessorResultFailedImplCopyWithImpl(
      _$ProcessorResultFailedImpl<T> _value,
      $Res Function(_$ProcessorResultFailedImpl<T>) _then)
      : super(_value, _then);

  /// Create a copy of ProcessorResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? error = freezed,
    Object? resultHandlerType = freezed,
  }) {
    return _then(_$ProcessorResultFailedImpl<T>(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as dynamic,
      resultHandlerType: freezed == resultHandlerType
          ? _value.resultHandlerType
          : resultHandlerType // ignore: cast_nullable_to_non_nullable
              as TypeValidatorRequired<ResultHandler>?,
    ));
  }
}

/// @nodoc

class _$ProcessorResultFailedImpl<T> extends ProcessorResultFailed<T> {
  const _$ProcessorResultFailedImpl(this.message,
      {this.error, this.resultHandlerType})
      : super._();

  @override
  final String message;
  @override
  final dynamic error;
  @override
  final TypeValidatorRequired<ResultHandler>? resultHandlerType;

  @override
  String toString() {
    return 'ProcessorResult<$T>.failed(message: $message, error: $error, resultHandlerType: $resultHandlerType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProcessorResultFailedImpl<T> &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other.error, error) &&
            (identical(other.resultHandlerType, resultHandlerType) ||
                other.resultHandlerType == resultHandlerType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message,
      const DeepCollectionEquality().hash(error), resultHandlerType);

  /// Create a copy of ProcessorResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProcessorResultFailedImplCopyWith<T, _$ProcessorResultFailedImpl<T>>
      get copyWith => __$$ProcessorResultFailedImplCopyWithImpl<T,
          _$ProcessorResultFailedImpl<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T resultData,
            TypeValidatorRequired<ResultHandler>? resultHandlerType)
        success,
    required TResult Function(String message, dynamic error,
            TypeValidatorRequired<ResultHandler>? resultHandlerType)
        failed,
  }) {
    return failed(message, error, resultHandlerType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T resultData,
            TypeValidatorRequired<ResultHandler>? resultHandlerType)?
        success,
    TResult? Function(String message, dynamic error,
            TypeValidatorRequired<ResultHandler>? resultHandlerType)?
        failed,
  }) {
    return failed?.call(message, error, resultHandlerType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T resultData,
            TypeValidatorRequired<ResultHandler>? resultHandlerType)?
        success,
    TResult Function(String message, dynamic error,
            TypeValidatorRequired<ResultHandler>? resultHandlerType)?
        failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(message, error, resultHandlerType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ProcessorResultSuccess<T> value) success,
    required TResult Function(ProcessorResultFailed<T> value) failed,
  }) {
    return failed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(ProcessorResultSuccess<T> value)? success,
    TResult? Function(ProcessorResultFailed<T> value)? failed,
  }) {
    return failed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ProcessorResultSuccess<T> value)? success,
    TResult Function(ProcessorResultFailed<T> value)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(this);
    }
    return orElse();
  }
}

abstract class ProcessorResultFailed<T> extends ProcessorResult<T> {
  const factory ProcessorResultFailed(final String message,
          {final dynamic error,
          final TypeValidatorRequired<ResultHandler>? resultHandlerType}) =
      _$ProcessorResultFailedImpl<T>;
  const ProcessorResultFailed._() : super._();

  String get message;
  dynamic get error;
  @override
  TypeValidatorRequired<ResultHandler>? get resultHandlerType;

  /// Create a copy of ProcessorResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProcessorResultFailedImplCopyWith<T, _$ProcessorResultFailedImpl<T>>
      get copyWith => throw _privateConstructorUsedError;
}
