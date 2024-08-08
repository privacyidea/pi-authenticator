// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProgressState {
  int get max => throw _privateConstructorUsedError;
  int get value => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(int max, int value) $default, {
    required TResult Function(int max, int value) uninitialized,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(int max, int value)? $default, {
    TResult? Function(int max, int value)? uninitialized,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(int max, int value)? $default, {
    TResult Function(int max, int value)? uninitialized,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ProgressState value) $default, {
    required TResult Function(ProgressStateUninitialized value) uninitialized,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ProgressState value)? $default, {
    TResult? Function(ProgressStateUninitialized value)? uninitialized,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ProgressState value)? $default, {
    TResult Function(ProgressStateUninitialized value)? uninitialized,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProgressStateCopyWith<ProgressState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressStateCopyWith<$Res> {
  factory $ProgressStateCopyWith(
          ProgressState value, $Res Function(ProgressState) then) =
      _$ProgressStateCopyWithImpl<$Res, ProgressState>;
  @useResult
  $Res call({int max, int value});
}

/// @nodoc
class _$ProgressStateCopyWithImpl<$Res, $Val extends ProgressState>
    implements $ProgressStateCopyWith<$Res> {
  _$ProgressStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? max = null,
    Object? value = null,
  }) {
    return _then(_value.copyWith(
      max: null == max
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as int,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgressStateUninitializedImplCopyWith<$Res>
    implements $ProgressStateCopyWith<$Res> {
  factory _$$ProgressStateUninitializedImplCopyWith(
          _$ProgressStateUninitializedImpl value,
          $Res Function(_$ProgressStateUninitializedImpl) then) =
      __$$ProgressStateUninitializedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int max, int value});
}

/// @nodoc
class __$$ProgressStateUninitializedImplCopyWithImpl<$Res>
    extends _$ProgressStateCopyWithImpl<$Res, _$ProgressStateUninitializedImpl>
    implements _$$ProgressStateUninitializedImplCopyWith<$Res> {
  __$$ProgressStateUninitializedImplCopyWithImpl(
      _$ProgressStateUninitializedImpl _value,
      $Res Function(_$ProgressStateUninitializedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? max = null,
    Object? value = null,
  }) {
    return _then(_$ProgressStateUninitializedImpl(
      max: null == max
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as int,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ProgressStateUninitializedImpl extends ProgressStateUninitialized {
  const _$ProgressStateUninitializedImpl({this.max = 0, this.value = 0})
      : super._();

  @override
  @JsonKey()
  final int max;
  @override
  @JsonKey()
  final int value;

  @override
  String toString() {
    return 'ProgressState.uninitialized(max: $max, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressStateUninitializedImpl &&
            (identical(other.max, max) || other.max == max) &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, max, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressStateUninitializedImplCopyWith<_$ProgressStateUninitializedImpl>
      get copyWith => __$$ProgressStateUninitializedImplCopyWithImpl<
          _$ProgressStateUninitializedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(int max, int value) $default, {
    required TResult Function(int max, int value) uninitialized,
  }) {
    return uninitialized(max, value);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(int max, int value)? $default, {
    TResult? Function(int max, int value)? uninitialized,
  }) {
    return uninitialized?.call(max, value);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(int max, int value)? $default, {
    TResult Function(int max, int value)? uninitialized,
    required TResult orElse(),
  }) {
    if (uninitialized != null) {
      return uninitialized(max, value);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ProgressState value) $default, {
    required TResult Function(ProgressStateUninitialized value) uninitialized,
  }) {
    return uninitialized(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ProgressState value)? $default, {
    TResult? Function(ProgressStateUninitialized value)? uninitialized,
  }) {
    return uninitialized?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ProgressState value)? $default, {
    TResult Function(ProgressStateUninitialized value)? uninitialized,
    required TResult orElse(),
  }) {
    if (uninitialized != null) {
      return uninitialized(this);
    }
    return orElse();
  }
}

abstract class ProgressStateUninitialized extends ProgressState {
  const factory ProgressStateUninitialized({final int max, final int value}) =
      _$ProgressStateUninitializedImpl;
  const ProgressStateUninitialized._() : super._();

  @override
  int get max;
  @override
  int get value;
  @override
  @JsonKey(ignore: true)
  _$$ProgressStateUninitializedImplCopyWith<_$ProgressStateUninitializedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ProgressStateImplCopyWith<$Res>
    implements $ProgressStateCopyWith<$Res> {
  factory _$$ProgressStateImplCopyWith(
          _$ProgressStateImpl value, $Res Function(_$ProgressStateImpl) then) =
      __$$ProgressStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int max, int value});
}

/// @nodoc
class __$$ProgressStateImplCopyWithImpl<$Res>
    extends _$ProgressStateCopyWithImpl<$Res, _$ProgressStateImpl>
    implements _$$ProgressStateImplCopyWith<$Res> {
  __$$ProgressStateImplCopyWithImpl(
      _$ProgressStateImpl _value, $Res Function(_$ProgressStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? max = null,
    Object? value = null,
  }) {
    return _then(_$ProgressStateImpl(
      max: null == max
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as int,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ProgressStateImpl extends _ProgressState {
  const _$ProgressStateImpl({required this.max, required this.value})
      : assert(max >= 0, 'max must be greater than or equal to 0'),
        assert(value >= max, 'value must be less than or equal to max'),
        super._();

  @override
  final int max;
  @override
  final int value;

  @override
  String toString() {
    return 'ProgressState(max: $max, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressStateImpl &&
            (identical(other.max, max) || other.max == max) &&
            (identical(other.value, value) || other.value == value));
  }

  @override
  int get hashCode => Object.hash(runtimeType, max, value);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressStateImplCopyWith<_$ProgressStateImpl> get copyWith =>
      __$$ProgressStateImplCopyWithImpl<_$ProgressStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(int max, int value) $default, {
    required TResult Function(int max, int value) uninitialized,
  }) {
    return $default(max, value);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(int max, int value)? $default, {
    TResult? Function(int max, int value)? uninitialized,
  }) {
    return $default?.call(max, value);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(int max, int value)? $default, {
    TResult Function(int max, int value)? uninitialized,
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(max, value);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ProgressState value) $default, {
    required TResult Function(ProgressStateUninitialized value) uninitialized,
  }) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ProgressState value)? $default, {
    TResult? Function(ProgressStateUninitialized value)? uninitialized,
  }) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ProgressState value)? $default, {
    TResult Function(ProgressStateUninitialized value)? uninitialized,
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _ProgressState extends ProgressState {
  const factory _ProgressState(
      {required final int max, required final int value}) = _$ProgressStateImpl;
  const _ProgressState._() : super._();

  @override
  int get max;
  @override
  int get value;
  @override
  @JsonKey(ignore: true)
  _$$ProgressStateImplCopyWith<_$ProgressStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
