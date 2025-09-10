// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'container_policies.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContainerPolicies {

 bool get rolloverAllowed; bool get initialTokenAssignment; bool get disabledTokenDeletion; bool get disabledUnregister;
/// Create a copy of ContainerPolicies
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContainerPoliciesCopyWith<ContainerPolicies> get copyWith => _$ContainerPoliciesCopyWithImpl<ContainerPolicies>(this as ContainerPolicies, _$identity);

  /// Serializes this ContainerPolicies to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContainerPolicies&&(identical(other.rolloverAllowed, rolloverAllowed) || other.rolloverAllowed == rolloverAllowed)&&(identical(other.initialTokenAssignment, initialTokenAssignment) || other.initialTokenAssignment == initialTokenAssignment)&&(identical(other.disabledTokenDeletion, disabledTokenDeletion) || other.disabledTokenDeletion == disabledTokenDeletion)&&(identical(other.disabledUnregister, disabledUnregister) || other.disabledUnregister == disabledUnregister));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rolloverAllowed,initialTokenAssignment,disabledTokenDeletion,disabledUnregister);



}

/// @nodoc
abstract mixin class $ContainerPoliciesCopyWith<$Res>  {
  factory $ContainerPoliciesCopyWith(ContainerPolicies value, $Res Function(ContainerPolicies) _then) = _$ContainerPoliciesCopyWithImpl;
@useResult
$Res call({
 bool rolloverAllowed, bool initialTokenAssignment, bool disabledTokenDeletion, bool disabledUnregister
});




}
/// @nodoc
class _$ContainerPoliciesCopyWithImpl<$Res>
    implements $ContainerPoliciesCopyWith<$Res> {
  _$ContainerPoliciesCopyWithImpl(this._self, this._then);

  final ContainerPolicies _self;
  final $Res Function(ContainerPolicies) _then;

/// Create a copy of ContainerPolicies
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rolloverAllowed = null,Object? initialTokenAssignment = null,Object? disabledTokenDeletion = null,Object? disabledUnregister = null,}) {
  return _then(_self.copyWith(
rolloverAllowed: null == rolloverAllowed ? _self.rolloverAllowed : rolloverAllowed // ignore: cast_nullable_to_non_nullable
as bool,initialTokenAssignment: null == initialTokenAssignment ? _self.initialTokenAssignment : initialTokenAssignment // ignore: cast_nullable_to_non_nullable
as bool,disabledTokenDeletion: null == disabledTokenDeletion ? _self.disabledTokenDeletion : disabledTokenDeletion // ignore: cast_nullable_to_non_nullable
as bool,disabledUnregister: null == disabledUnregister ? _self.disabledUnregister : disabledUnregister // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ContainerPolicies].
extension ContainerPoliciesPatterns on ContainerPolicies {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContainerPolicies value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContainerPolicies() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContainerPolicies value)  $default,){
final _that = this;
switch (_that) {
case _ContainerPolicies():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContainerPolicies value)?  $default,){
final _that = this;
switch (_that) {
case _ContainerPolicies() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool rolloverAllowed,  bool initialTokenAssignment,  bool disabledTokenDeletion,  bool disabledUnregister)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContainerPolicies() when $default != null:
return $default(_that.rolloverAllowed,_that.initialTokenAssignment,_that.disabledTokenDeletion,_that.disabledUnregister);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool rolloverAllowed,  bool initialTokenAssignment,  bool disabledTokenDeletion,  bool disabledUnregister)  $default,) {final _that = this;
switch (_that) {
case _ContainerPolicies():
return $default(_that.rolloverAllowed,_that.initialTokenAssignment,_that.disabledTokenDeletion,_that.disabledUnregister);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool rolloverAllowed,  bool initialTokenAssignment,  bool disabledTokenDeletion,  bool disabledUnregister)?  $default,) {final _that = this;
switch (_that) {
case _ContainerPolicies() when $default != null:
return $default(_that.rolloverAllowed,_that.initialTokenAssignment,_that.disabledTokenDeletion,_that.disabledUnregister);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContainerPolicies extends ContainerPolicies {
  const _ContainerPolicies({required this.rolloverAllowed, required this.initialTokenAssignment, required this.disabledTokenDeletion, required this.disabledUnregister}): super._();
  factory _ContainerPolicies.fromJson(Map<String, dynamic> json) => _$ContainerPoliciesFromJson(json);

@override final  bool rolloverAllowed;
@override final  bool initialTokenAssignment;
@override final  bool disabledTokenDeletion;
@override final  bool disabledUnregister;

/// Create a copy of ContainerPolicies
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContainerPoliciesCopyWith<_ContainerPolicies> get copyWith => __$ContainerPoliciesCopyWithImpl<_ContainerPolicies>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContainerPoliciesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContainerPolicies&&(identical(other.rolloverAllowed, rolloverAllowed) || other.rolloverAllowed == rolloverAllowed)&&(identical(other.initialTokenAssignment, initialTokenAssignment) || other.initialTokenAssignment == initialTokenAssignment)&&(identical(other.disabledTokenDeletion, disabledTokenDeletion) || other.disabledTokenDeletion == disabledTokenDeletion)&&(identical(other.disabledUnregister, disabledUnregister) || other.disabledUnregister == disabledUnregister));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rolloverAllowed,initialTokenAssignment,disabledTokenDeletion,disabledUnregister);



}

/// @nodoc
abstract mixin class _$ContainerPoliciesCopyWith<$Res> implements $ContainerPoliciesCopyWith<$Res> {
  factory _$ContainerPoliciesCopyWith(_ContainerPolicies value, $Res Function(_ContainerPolicies) _then) = __$ContainerPoliciesCopyWithImpl;
@override @useResult
$Res call({
 bool rolloverAllowed, bool initialTokenAssignment, bool disabledTokenDeletion, bool disabledUnregister
});




}
/// @nodoc
class __$ContainerPoliciesCopyWithImpl<$Res>
    implements _$ContainerPoliciesCopyWith<$Res> {
  __$ContainerPoliciesCopyWithImpl(this._self, this._then);

  final _ContainerPolicies _self;
  final $Res Function(_ContainerPolicies) _then;

/// Create a copy of ContainerPolicies
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rolloverAllowed = null,Object? initialTokenAssignment = null,Object? disabledTokenDeletion = null,Object? disabledUnregister = null,}) {
  return _then(_ContainerPolicies(
rolloverAllowed: null == rolloverAllowed ? _self.rolloverAllowed : rolloverAllowed // ignore: cast_nullable_to_non_nullable
as bool,initialTokenAssignment: null == initialTokenAssignment ? _self.initialTokenAssignment : initialTokenAssignment // ignore: cast_nullable_to_non_nullable
as bool,disabledTokenDeletion: null == disabledTokenDeletion ? _self.disabledTokenDeletion : disabledTokenDeletion // ignore: cast_nullable_to_non_nullable
as bool,disabledUnregister: null == disabledUnregister ? _self.disabledUnregister : disabledUnregister // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
