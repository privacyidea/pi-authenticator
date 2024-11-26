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
  return _TokenContainerState.fromJson(json);
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
  $Res call({List<TokenContainer> containerList});
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
    Object? containerList = null,
  }) {
    return _then(_value.copyWith(
      containerList: null == containerList
          ? _value.containerList
          : containerList // ignore: cast_nullable_to_non_nullable
              as List<TokenContainer>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TokenContainerStateImplCopyWith<$Res> implements $TokenContainerStateCopyWith<$Res> {
  factory _$$TokenContainerStateImplCopyWith(_$TokenContainerStateImpl value, $Res Function(_$TokenContainerStateImpl) then) =
      __$$TokenContainerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<TokenContainer> containerList});
}

/// @nodoc
class __$$TokenContainerStateImplCopyWithImpl<$Res> extends _$TokenContainerStateCopyWithImpl<$Res, _$TokenContainerStateImpl>
    implements _$$TokenContainerStateImplCopyWith<$Res> {
  __$$TokenContainerStateImplCopyWithImpl(_$TokenContainerStateImpl _value, $Res Function(_$TokenContainerStateImpl) _then) : super(_value, _then);

  /// Create a copy of TokenContainerState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? containerList = null,
  }) {
    return _then(_$TokenContainerStateImpl(
      containerList: null == containerList
          ? _value._containerList
          : containerList // ignore: cast_nullable_to_non_nullable
              as List<TokenContainer>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenContainerStateImpl extends _TokenContainerState {
  const _$TokenContainerStateImpl({required final List<TokenContainer> containerList})
      : _containerList = containerList,
        super._();

  factory _$TokenContainerStateImpl.fromJson(Map<String, dynamic> json) => _$$TokenContainerStateImplFromJson(json);

  final List<TokenContainer> _containerList;
  @override
  List<TokenContainer> get containerList {
    if (_containerList is EqualUnmodifiableListView) return _containerList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_containerList);
  }

  @override
  String toString() {
    return 'TokenContainerState(containerList: $containerList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$TokenContainerStateImpl && const DeepCollectionEquality().equals(other._containerList, _containerList));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, const DeepCollectionEquality().hash(_containerList));

  /// Create a copy of TokenContainerState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenContainerStateImplCopyWith<_$TokenContainerStateImpl> get copyWith =>
      __$$TokenContainerStateImplCopyWithImpl<_$TokenContainerStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenContainerStateImplToJson(
      this,
    );
  }
}

abstract class _TokenContainerState extends TokenContainerState {
  const factory _TokenContainerState({required final List<TokenContainer> containerList}) = _$TokenContainerStateImpl;
  const _TokenContainerState._() : super._();

  factory _TokenContainerState.fromJson(Map<String, dynamic> json) = _$TokenContainerStateImpl.fromJson;

  @override
  List<TokenContainer> get containerList;

  /// Create a copy of TokenContainerState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenContainerStateImplCopyWith<_$TokenContainerStateImpl> get copyWith => throw _privateConstructorUsedError;
}
