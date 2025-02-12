// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'container_policies.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ContainerPolicies _$ContainerPoliciesFromJson(Map<String, dynamic> json) {
  return _ContainerPolicies.fromJson(json);
}

/// @nodoc
mixin _$ContainerPolicies {
  bool get rolloverAllowed => throw _privateConstructorUsedError;
  bool get initialTokenAssignment => throw _privateConstructorUsedError;
  bool get disabledTokenDeletion => throw _privateConstructorUsedError;
  bool get disabledUnregister => throw _privateConstructorUsedError;

  /// Serializes this ContainerPolicies to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContainerPolicies
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContainerPoliciesCopyWith<ContainerPolicies> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContainerPoliciesCopyWith<$Res> {
  factory $ContainerPoliciesCopyWith(
          ContainerPolicies value, $Res Function(ContainerPolicies) then) =
      _$ContainerPoliciesCopyWithImpl<$Res, ContainerPolicies>;
  @useResult
  $Res call(
      {bool rolloverAllowed,
      bool initialTokenAssignment,
      bool disabledTokenDeletion,
      bool disabledUnregister});
}

/// @nodoc
class _$ContainerPoliciesCopyWithImpl<$Res, $Val extends ContainerPolicies>
    implements $ContainerPoliciesCopyWith<$Res> {
  _$ContainerPoliciesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContainerPolicies
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rolloverAllowed = null,
    Object? initialTokenAssignment = null,
    Object? disabledTokenDeletion = null,
    Object? disabledUnregister = null,
  }) {
    return _then(_value.copyWith(
      rolloverAllowed: null == rolloverAllowed
          ? _value.rolloverAllowed
          : rolloverAllowed // ignore: cast_nullable_to_non_nullable
              as bool,
      initialTokenAssignment: null == initialTokenAssignment
          ? _value.initialTokenAssignment
          : initialTokenAssignment // ignore: cast_nullable_to_non_nullable
              as bool,
      disabledTokenDeletion: null == disabledTokenDeletion
          ? _value.disabledTokenDeletion
          : disabledTokenDeletion // ignore: cast_nullable_to_non_nullable
              as bool,
      disabledUnregister: null == disabledUnregister
          ? _value.disabledUnregister
          : disabledUnregister // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ContainerPoliciesImplCopyWith<$Res>
    implements $ContainerPoliciesCopyWith<$Res> {
  factory _$$ContainerPoliciesImplCopyWith(_$ContainerPoliciesImpl value,
          $Res Function(_$ContainerPoliciesImpl) then) =
      __$$ContainerPoliciesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool rolloverAllowed,
      bool initialTokenAssignment,
      bool disabledTokenDeletion,
      bool disabledUnregister});
}

/// @nodoc
class __$$ContainerPoliciesImplCopyWithImpl<$Res>
    extends _$ContainerPoliciesCopyWithImpl<$Res, _$ContainerPoliciesImpl>
    implements _$$ContainerPoliciesImplCopyWith<$Res> {
  __$$ContainerPoliciesImplCopyWithImpl(_$ContainerPoliciesImpl _value,
      $Res Function(_$ContainerPoliciesImpl) _then)
      : super(_value, _then);

  /// Create a copy of ContainerPolicies
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rolloverAllowed = null,
    Object? initialTokenAssignment = null,
    Object? disabledTokenDeletion = null,
    Object? disabledUnregister = null,
  }) {
    return _then(_$ContainerPoliciesImpl(
      rolloverAllowed: null == rolloverAllowed
          ? _value.rolloverAllowed
          : rolloverAllowed // ignore: cast_nullable_to_non_nullable
              as bool,
      initialTokenAssignment: null == initialTokenAssignment
          ? _value.initialTokenAssignment
          : initialTokenAssignment // ignore: cast_nullable_to_non_nullable
              as bool,
      disabledTokenDeletion: null == disabledTokenDeletion
          ? _value.disabledTokenDeletion
          : disabledTokenDeletion // ignore: cast_nullable_to_non_nullable
              as bool,
      disabledUnregister: null == disabledUnregister
          ? _value.disabledUnregister
          : disabledUnregister // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ContainerPoliciesImpl extends _ContainerPolicies {
  const _$ContainerPoliciesImpl(
      {required this.rolloverAllowed,
      required this.initialTokenAssignment,
      required this.disabledTokenDeletion,
      required this.disabledUnregister})
      : super._();

  factory _$ContainerPoliciesImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContainerPoliciesImplFromJson(json);

  @override
  final bool rolloverAllowed;
  @override
  final bool initialTokenAssignment;
  @override
  final bool disabledTokenDeletion;
  @override
  final bool disabledUnregister;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContainerPoliciesImpl &&
            (identical(other.rolloverAllowed, rolloverAllowed) ||
                other.rolloverAllowed == rolloverAllowed) &&
            (identical(other.initialTokenAssignment, initialTokenAssignment) ||
                other.initialTokenAssignment == initialTokenAssignment) &&
            (identical(other.disabledTokenDeletion, disabledTokenDeletion) ||
                other.disabledTokenDeletion == disabledTokenDeletion) &&
            (identical(other.disabledUnregister, disabledUnregister) ||
                other.disabledUnregister == disabledUnregister));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, rolloverAllowed,
      initialTokenAssignment, disabledTokenDeletion, disabledUnregister);

  /// Create a copy of ContainerPolicies
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContainerPoliciesImplCopyWith<_$ContainerPoliciesImpl> get copyWith =>
      __$$ContainerPoliciesImplCopyWithImpl<_$ContainerPoliciesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ContainerPoliciesImplToJson(
      this,
    );
  }
}

abstract class _ContainerPolicies extends ContainerPolicies {
  const factory _ContainerPolicies(
      {required final bool rolloverAllowed,
      required final bool initialTokenAssignment,
      required final bool disabledTokenDeletion,
      required final bool disabledUnregister}) = _$ContainerPoliciesImpl;
  const _ContainerPolicies._() : super._();

  factory _ContainerPolicies.fromJson(Map<String, dynamic> json) =
      _$ContainerPoliciesImpl.fromJson;

  @override
  bool get rolloverAllowed;
  @override
  bool get initialTokenAssignment;
  @override
  bool get disabledTokenDeletion;
  @override
  bool get disabledUnregister;

  /// Create a copy of ContainerPolicies
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContainerPoliciesImplCopyWith<_$ContainerPoliciesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
