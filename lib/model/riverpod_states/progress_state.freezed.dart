// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProgressState {

 int get max; int get value;
/// Create a copy of ProgressState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgressStateCopyWith<ProgressState> get copyWith => _$ProgressStateCopyWithImpl<ProgressState>(this as ProgressState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgressState&&(identical(other.max, max) || other.max == max)&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,max,value);

@override
String toString() {
  return 'ProgressState(max: $max, value: $value)';
}


}

/// @nodoc
abstract mixin class $ProgressStateCopyWith<$Res>  {
  factory $ProgressStateCopyWith(ProgressState value, $Res Function(ProgressState) _then) = _$ProgressStateCopyWithImpl;
@useResult
$Res call({
 int max, int value
});




}
/// @nodoc
class _$ProgressStateCopyWithImpl<$Res>
    implements $ProgressStateCopyWith<$Res> {
  _$ProgressStateCopyWithImpl(this._self, this._then);

  final ProgressState _self;
  final $Res Function(ProgressState) _then;

/// Create a copy of ProgressState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? max = null,Object? value = null,}) {
  return _then(_self.copyWith(
max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProgressState].
extension ProgressStatePatterns on ProgressState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProgressState value)?  $default,{TResult Function( ProgressStateUninitialized value)?  uninitialized,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProgressStateUninitialized() when uninitialized != null:
return uninitialized(_that);case _ProgressState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProgressState value)  $default,{required TResult Function( ProgressStateUninitialized value)  uninitialized,}){
final _that = this;
switch (_that) {
case ProgressStateUninitialized():
return uninitialized(_that);case _ProgressState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProgressState value)?  $default,{TResult? Function( ProgressStateUninitialized value)?  uninitialized,}){
final _that = this;
switch (_that) {
case ProgressStateUninitialized() when uninitialized != null:
return uninitialized(_that);case _ProgressState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int max,  int value)?  $default,{TResult Function( int max,  int value)?  uninitialized,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProgressStateUninitialized() when uninitialized != null:
return uninitialized(_that.max,_that.value);case _ProgressState() when $default != null:
return $default(_that.max,_that.value);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int max,  int value)  $default,{required TResult Function( int max,  int value)  uninitialized,}) {final _that = this;
switch (_that) {
case ProgressStateUninitialized():
return uninitialized(_that.max,_that.value);case _ProgressState():
return $default(_that.max,_that.value);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int max,  int value)?  $default,{TResult? Function( int max,  int value)?  uninitialized,}) {final _that = this;
switch (_that) {
case ProgressStateUninitialized() when uninitialized != null:
return uninitialized(_that.max,_that.value);case _ProgressState() when $default != null:
return $default(_that.max,_that.value);case _:
  return null;

}
}

}

/// @nodoc


class ProgressStateUninitialized extends ProgressState {
  const ProgressStateUninitialized({this.max = 0, this.value = 0}): super._();
  

@override@JsonKey() final  int max;
@override@JsonKey() final  int value;

/// Create a copy of ProgressState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProgressStateUninitializedCopyWith<ProgressStateUninitialized> get copyWith => _$ProgressStateUninitializedCopyWithImpl<ProgressStateUninitialized>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProgressStateUninitialized&&(identical(other.max, max) || other.max == max)&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,max,value);

@override
String toString() {
  return 'ProgressState.uninitialized(max: $max, value: $value)';
}


}

/// @nodoc
abstract mixin class $ProgressStateUninitializedCopyWith<$Res> implements $ProgressStateCopyWith<$Res> {
  factory $ProgressStateUninitializedCopyWith(ProgressStateUninitialized value, $Res Function(ProgressStateUninitialized) _then) = _$ProgressStateUninitializedCopyWithImpl;
@override @useResult
$Res call({
 int max, int value
});




}
/// @nodoc
class _$ProgressStateUninitializedCopyWithImpl<$Res>
    implements $ProgressStateUninitializedCopyWith<$Res> {
  _$ProgressStateUninitializedCopyWithImpl(this._self, this._then);

  final ProgressStateUninitialized _self;
  final $Res Function(ProgressStateUninitialized) _then;

/// Create a copy of ProgressState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? max = null,Object? value = null,}) {
  return _then(ProgressStateUninitialized(
max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _ProgressState extends ProgressState {
  const _ProgressState({required this.max, required this.value}): assert(max >= 0, 'max must be greater than or equal to 0'),assert(value <= max, 'value must be less than or equal to max'),super._();
  

@override final  int max;
@override final  int value;

/// Create a copy of ProgressState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProgressStateCopyWith<_ProgressState> get copyWith => __$ProgressStateCopyWithImpl<_ProgressState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProgressState&&(identical(other.max, max) || other.max == max)&&(identical(other.value, value) || other.value == value));
}


@override
int get hashCode => Object.hash(runtimeType,max,value);

@override
String toString() {
  return 'ProgressState(max: $max, value: $value)';
}


}

/// @nodoc
abstract mixin class _$ProgressStateCopyWith<$Res> implements $ProgressStateCopyWith<$Res> {
  factory _$ProgressStateCopyWith(_ProgressState value, $Res Function(_ProgressState) _then) = __$ProgressStateCopyWithImpl;
@override @useResult
$Res call({
 int max, int value
});




}
/// @nodoc
class __$ProgressStateCopyWithImpl<$Res>
    implements _$ProgressStateCopyWith<$Res> {
  __$ProgressStateCopyWithImpl(this._self, this._then);

  final _ProgressState _self;
  final $Res Function(_ProgressState) _then;

/// Create a copy of ProgressState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? max = null,Object? value = null,}) {
  return _then(_ProgressState(
max: null == max ? _self.max : max // ignore: cast_nullable_to_non_nullable
as int,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
