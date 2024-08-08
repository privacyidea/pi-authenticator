// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credentials_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CredentialsState _$CredentialsStateFromJson(Map<String, dynamic> json) {
  return _CredentialsState.fromJson(json);
}

/// @nodoc
mixin _$CredentialsState {
  List<ContainerCredential> get credentials =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CredentialsStateCopyWith<CredentialsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CredentialsStateCopyWith<$Res> {
  factory $CredentialsStateCopyWith(
          CredentialsState value, $Res Function(CredentialsState) then) =
      _$CredentialsStateCopyWithImpl<$Res, CredentialsState>;
  @useResult
  $Res call({List<ContainerCredential> credentials});
}

/// @nodoc
class _$CredentialsStateCopyWithImpl<$Res, $Val extends CredentialsState>
    implements $CredentialsStateCopyWith<$Res> {
  _$CredentialsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? credentials = null,
  }) {
    return _then(_value.copyWith(
      credentials: null == credentials
          ? _value.credentials
          : credentials // ignore: cast_nullable_to_non_nullable
              as List<ContainerCredential>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CredentialsStateImplCopyWith<$Res>
    implements $CredentialsStateCopyWith<$Res> {
  factory _$$CredentialsStateImplCopyWith(_$CredentialsStateImpl value,
          $Res Function(_$CredentialsStateImpl) then) =
      __$$CredentialsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<ContainerCredential> credentials});
}

/// @nodoc
class __$$CredentialsStateImplCopyWithImpl<$Res>
    extends _$CredentialsStateCopyWithImpl<$Res, _$CredentialsStateImpl>
    implements _$$CredentialsStateImplCopyWith<$Res> {
  __$$CredentialsStateImplCopyWithImpl(_$CredentialsStateImpl _value,
      $Res Function(_$CredentialsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? credentials = null,
  }) {
    return _then(_$CredentialsStateImpl(
      credentials: null == credentials
          ? _value._credentials
          : credentials // ignore: cast_nullable_to_non_nullable
              as List<ContainerCredential>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CredentialsStateImpl extends _CredentialsState {
  const _$CredentialsStateImpl(
      {required final List<ContainerCredential> credentials})
      : _credentials = credentials,
        super._();

  factory _$CredentialsStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$CredentialsStateImplFromJson(json);

  final List<ContainerCredential> _credentials;
  @override
  List<ContainerCredential> get credentials {
    if (_credentials is EqualUnmodifiableListView) return _credentials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_credentials);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CredentialsStateImpl &&
            const DeepCollectionEquality()
                .equals(other._credentials, _credentials));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_credentials));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CredentialsStateImplCopyWith<_$CredentialsStateImpl> get copyWith =>
      __$$CredentialsStateImplCopyWithImpl<_$CredentialsStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CredentialsStateImplToJson(
      this,
    );
  }
}

abstract class _CredentialsState extends CredentialsState {
  const factory _CredentialsState(
          {required final List<ContainerCredential> credentials}) =
      _$CredentialsStateImpl;
  const _CredentialsState._() : super._();

  factory _CredentialsState.fromJson(Map<String, dynamic> json) =
      _$CredentialsStateImpl.fromJson;

  @override
  List<ContainerCredential> get credentials;
  @override
  @JsonKey(ignore: true)
  _$$CredentialsStateImplCopyWith<_$CredentialsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
