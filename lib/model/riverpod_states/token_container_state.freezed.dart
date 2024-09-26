// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_container_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TokenContainerState _$TokenContainerStateFromJson(Map<String, dynamic> json) {
  return _CredentialsState.fromJson(json);
}

/// @nodoc
mixin _$TokenContainerState {
  List<TokenContainer> get containerList => throw _privateConstructorUsedError;

  /// Serializes this TokenContainerState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenContainerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenContainerStateCopyWith<TokenContainerState> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenContainerStateCopyWith<$Res> {
  factory $TokenContainerStateCopyWith(TokenContainerState value, $Res Function(TokenContainerState) then) =
      _$TokenContainerStateCopyWithImpl<$Res, TokenContainerState>;
  @useResult
  $Res call({List<TokenContainer> container});
}

/// @nodoc
class _$TokenContainerStateCopyWithImpl<$Res, $Val extends TokenContainerState> implements $TokenContainerStateCopyWith<$Res> {
  _$TokenContainerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenContainerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? container = null,
  }) {
    return _then(_value.copyWith(
      container: null == container
          ? _value.containerList
          : container // ignore: cast_nullable_to_non_nullable
              as List<TokenContainer>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CredentialsStateImplCopyWith<$Res> implements $TokenContainerStateCopyWith<$Res> {
  factory _$$CredentialsStateImplCopyWith(_$CredentialsStateImpl value, $Res Function(_$CredentialsStateImpl) then) =
      __$$CredentialsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<TokenContainer> container});
}

/// @nodoc
class __$$CredentialsStateImplCopyWithImpl<$Res> extends _$TokenContainerStateCopyWithImpl<$Res, _$CredentialsStateImpl>
    implements _$$CredentialsStateImplCopyWith<$Res> {
  __$$CredentialsStateImplCopyWithImpl(_$CredentialsStateImpl _value, $Res Function(_$CredentialsStateImpl) _then) : super(_value, _then);

  /// Create a copy of TokenContainerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? container = null,
  }) {
    return _then(_$CredentialsStateImpl(
      container: null == container
          ? _value._container
          : container // ignore: cast_nullable_to_non_nullable
              as List<TokenContainer>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CredentialsStateImpl extends _CredentialsState {
  const _$CredentialsStateImpl({required final List<TokenContainer> container})
      : _container = container,
        super._();

  factory _$CredentialsStateImpl.fromJson(Map<String, dynamic> json) => _$$CredentialsStateImplFromJson(json);

  final List<TokenContainer> _container;
  @override
  List<TokenContainer> get containerList {
    if (_container is EqualUnmodifiableListView) return _container;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_container);
  }

  @override
  String toString() {
    return 'TokenContainerState(container: $containerList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CredentialsStateImpl && const DeepCollectionEquality().equals(other._container, _container));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, const DeepCollectionEquality().hash(_container));

  /// Create a copy of TokenContainerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CredentialsStateImplCopyWith<_$CredentialsStateImpl> get copyWith => __$$CredentialsStateImplCopyWithImpl<_$CredentialsStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CredentialsStateImplToJson(
      this,
    );
  }
}

abstract class _CredentialsState extends TokenContainerState {
  const factory _CredentialsState({required final List<TokenContainer> container}) = _$CredentialsStateImpl;
  const _CredentialsState._() : super._();

  factory _CredentialsState.fromJson(Map<String, dynamic> json) = _$CredentialsStateImpl.fromJson;

  @override
  List<TokenContainer> get containerList;

  /// Create a copy of TokenContainerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CredentialsStateImplCopyWith<_$CredentialsStateImpl> get copyWith => throw _privateConstructorUsedError;
}
