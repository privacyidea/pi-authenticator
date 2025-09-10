// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_container_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TokenContainerState {

 List<TokenContainer> get containerList;
/// Create a copy of TokenContainerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenContainerStateCopyWith<TokenContainerState> get copyWith => _$TokenContainerStateCopyWithImpl<TokenContainerState>(this as TokenContainerState, _$identity);

  /// Serializes this TokenContainerState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenContainerState&&const DeepCollectionEquality().equals(other.containerList, containerList));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(containerList));

@override
String toString() {
  return 'TokenContainerState(containerList: $containerList)';
}


}

/// @nodoc
abstract mixin class $TokenContainerStateCopyWith<$Res>  {
  factory $TokenContainerStateCopyWith(TokenContainerState value, $Res Function(TokenContainerState) _then) = _$TokenContainerStateCopyWithImpl;
@useResult
$Res call({
 List<TokenContainer> containerList
});




}
/// @nodoc
class _$TokenContainerStateCopyWithImpl<$Res>
    implements $TokenContainerStateCopyWith<$Res> {
  _$TokenContainerStateCopyWithImpl(this._self, this._then);

  final TokenContainerState _self;
  final $Res Function(TokenContainerState) _then;

/// Create a copy of TokenContainerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? containerList = null,}) {
  return _then(_self.copyWith(
containerList: null == containerList ? _self.containerList : containerList // ignore: cast_nullable_to_non_nullable
as List<TokenContainer>,
  ));
}

}


/// Adds pattern-matching-related methods to [TokenContainerState].
extension TokenContainerStatePatterns on TokenContainerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TokenContainerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TokenContainerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TokenContainerState value)  $default,){
final _that = this;
switch (_that) {
case _TokenContainerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TokenContainerState value)?  $default,){
final _that = this;
switch (_that) {
case _TokenContainerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TokenContainer> containerList)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TokenContainerState() when $default != null:
return $default(_that.containerList);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TokenContainer> containerList)  $default,) {final _that = this;
switch (_that) {
case _TokenContainerState():
return $default(_that.containerList);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TokenContainer> containerList)?  $default,) {final _that = this;
switch (_that) {
case _TokenContainerState() when $default != null:
return $default(_that.containerList);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TokenContainerState extends TokenContainerState {
  const _TokenContainerState({required final  List<TokenContainer> containerList}): _containerList = containerList,super._();
  factory _TokenContainerState.fromJson(Map<String, dynamic> json) => _$TokenContainerStateFromJson(json);

 final  List<TokenContainer> _containerList;
@override List<TokenContainer> get containerList {
  if (_containerList is EqualUnmodifiableListView) return _containerList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_containerList);
}


/// Create a copy of TokenContainerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TokenContainerStateCopyWith<_TokenContainerState> get copyWith => __$TokenContainerStateCopyWithImpl<_TokenContainerState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenContainerStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TokenContainerState&&const DeepCollectionEquality().equals(other._containerList, _containerList));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_containerList));

@override
String toString() {
  return 'TokenContainerState(containerList: $containerList)';
}


}

/// @nodoc
abstract mixin class _$TokenContainerStateCopyWith<$Res> implements $TokenContainerStateCopyWith<$Res> {
  factory _$TokenContainerStateCopyWith(_TokenContainerState value, $Res Function(_TokenContainerState) _then) = __$TokenContainerStateCopyWithImpl;
@override @useResult
$Res call({
 List<TokenContainer> containerList
});




}
/// @nodoc
class __$TokenContainerStateCopyWithImpl<$Res>
    implements _$TokenContainerStateCopyWith<$Res> {
  __$TokenContainerStateCopyWithImpl(this._self, this._then);

  final _TokenContainerState _self;
  final $Res Function(_TokenContainerState) _then;

/// Create a copy of TokenContainerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? containerList = null,}) {
  return _then(_TokenContainerState(
containerList: null == containerList ? _self._containerList : containerList // ignore: cast_nullable_to_non_nullable
as List<TokenContainer>,
  ));
}


}

// dart format on
