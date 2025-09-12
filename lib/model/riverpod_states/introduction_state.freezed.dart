// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'introduction_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IntroductionState {

 Set<Introduction> get completedIntroductions;
/// Create a copy of IntroductionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IntroductionStateCopyWith<IntroductionState> get copyWith => _$IntroductionStateCopyWithImpl<IntroductionState>(this as IntroductionState, _$identity);

  /// Serializes this IntroductionState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IntroductionState&&const DeepCollectionEquality().equals(other.completedIntroductions, completedIntroductions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(completedIntroductions));

@override
String toString() {
  return 'IntroductionState(completedIntroductions: $completedIntroductions)';
}


}

/// @nodoc
abstract mixin class $IntroductionStateCopyWith<$Res>  {
  factory $IntroductionStateCopyWith(IntroductionState value, $Res Function(IntroductionState) _then) = _$IntroductionStateCopyWithImpl;
@useResult
$Res call({
 Set<Introduction> completedIntroductions
});




}
/// @nodoc
class _$IntroductionStateCopyWithImpl<$Res>
    implements $IntroductionStateCopyWith<$Res> {
  _$IntroductionStateCopyWithImpl(this._self, this._then);

  final IntroductionState _self;
  final $Res Function(IntroductionState) _then;

/// Create a copy of IntroductionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? completedIntroductions = null,}) {
  return _then(_self.copyWith(
completedIntroductions: null == completedIntroductions ? _self.completedIntroductions : completedIntroductions // ignore: cast_nullable_to_non_nullable
as Set<Introduction>,
  ));
}

}


/// Adds pattern-matching-related methods to [IntroductionState].
extension IntroductionStatePatterns on IntroductionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IntroductionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IntroductionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IntroductionState value)  $default,){
final _that = this;
switch (_that) {
case _IntroductionState():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IntroductionState value)?  $default,){
final _that = this;
switch (_that) {
case _IntroductionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Set<Introduction> completedIntroductions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IntroductionState() when $default != null:
return $default(_that.completedIntroductions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Set<Introduction> completedIntroductions)  $default,) {final _that = this;
switch (_that) {
case _IntroductionState():
return $default(_that.completedIntroductions);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Set<Introduction> completedIntroductions)?  $default,) {final _that = this;
switch (_that) {
case _IntroductionState() when $default != null:
return $default(_that.completedIntroductions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IntroductionState extends IntroductionState {
  const _IntroductionState({final  Set<Introduction> completedIntroductions = const {}}): _completedIntroductions = completedIntroductions,super._();
  factory _IntroductionState.fromJson(Map<String, dynamic> json) => _$IntroductionStateFromJson(json);

 final  Set<Introduction> _completedIntroductions;
@override@JsonKey() Set<Introduction> get completedIntroductions {
  if (_completedIntroductions is EqualUnmodifiableSetView) return _completedIntroductions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_completedIntroductions);
}


/// Create a copy of IntroductionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IntroductionStateCopyWith<_IntroductionState> get copyWith => __$IntroductionStateCopyWithImpl<_IntroductionState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IntroductionStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IntroductionState&&const DeepCollectionEquality().equals(other._completedIntroductions, _completedIntroductions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_completedIntroductions));

@override
String toString() {
  return 'IntroductionState(completedIntroductions: $completedIntroductions)';
}


}

/// @nodoc
abstract mixin class _$IntroductionStateCopyWith<$Res> implements $IntroductionStateCopyWith<$Res> {
  factory _$IntroductionStateCopyWith(_IntroductionState value, $Res Function(_IntroductionState) _then) = __$IntroductionStateCopyWithImpl;
@override @useResult
$Res call({
 Set<Introduction> completedIntroductions
});




}
/// @nodoc
class __$IntroductionStateCopyWithImpl<$Res>
    implements _$IntroductionStateCopyWith<$Res> {
  __$IntroductionStateCopyWithImpl(this._self, this._then);

  final _IntroductionState _self;
  final $Res Function(_IntroductionState) _then;

/// Create a copy of IntroductionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? completedIntroductions = null,}) {
  return _then(_IntroductionState(
completedIntroductions: null == completedIntroductions ? _self._completedIntroductions : completedIntroductions // ignore: cast_nullable_to_non_nullable
as Set<Introduction>,
  ));
}


}

// dart format on
