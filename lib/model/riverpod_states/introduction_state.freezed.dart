// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'introduction_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IntroductionState _$IntroductionStateFromJson(Map<String, dynamic> json) {
  return _IntroductionState.fromJson(json);
}

/// @nodoc
mixin _$IntroductionState {
  Set<Introduction> get completedIntroductions =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IntroductionStateCopyWith<IntroductionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IntroductionStateCopyWith<$Res> {
  factory $IntroductionStateCopyWith(
          IntroductionState value, $Res Function(IntroductionState) then) =
      _$IntroductionStateCopyWithImpl<$Res, IntroductionState>;
  @useResult
  $Res call({Set<Introduction> completedIntroductions});
}

/// @nodoc
class _$IntroductionStateCopyWithImpl<$Res, $Val extends IntroductionState>
    implements $IntroductionStateCopyWith<$Res> {
  _$IntroductionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completedIntroductions = null,
  }) {
    return _then(_value.copyWith(
      completedIntroductions: null == completedIntroductions
          ? _value.completedIntroductions
          : completedIntroductions // ignore: cast_nullable_to_non_nullable
              as Set<Introduction>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IntroductionStateImplCopyWith<$Res>
    implements $IntroductionStateCopyWith<$Res> {
  factory _$$IntroductionStateImplCopyWith(_$IntroductionStateImpl value,
          $Res Function(_$IntroductionStateImpl) then) =
      __$$IntroductionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Set<Introduction> completedIntroductions});
}

/// @nodoc
class __$$IntroductionStateImplCopyWithImpl<$Res>
    extends _$IntroductionStateCopyWithImpl<$Res, _$IntroductionStateImpl>
    implements _$$IntroductionStateImplCopyWith<$Res> {
  __$$IntroductionStateImplCopyWithImpl(_$IntroductionStateImpl _value,
      $Res Function(_$IntroductionStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? completedIntroductions = null,
  }) {
    return _then(_$IntroductionStateImpl(
      completedIntroductions: null == completedIntroductions
          ? _value._completedIntroductions
          : completedIntroductions // ignore: cast_nullable_to_non_nullable
              as Set<Introduction>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IntroductionStateImpl extends _IntroductionState {
  const _$IntroductionStateImpl(
      {final Set<Introduction> completedIntroductions = const {}})
      : _completedIntroductions = completedIntroductions,
        super._();

  factory _$IntroductionStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$IntroductionStateImplFromJson(json);

  final Set<Introduction> _completedIntroductions;
  @override
  @JsonKey()
  Set<Introduction> get completedIntroductions {
    if (_completedIntroductions is EqualUnmodifiableSetView)
      return _completedIntroductions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_completedIntroductions);
  }

  @override
  String toString() {
    return 'IntroductionState(completedIntroductions: $completedIntroductions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IntroductionStateImpl &&
            const DeepCollectionEquality().equals(
                other._completedIntroductions, _completedIntroductions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_completedIntroductions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IntroductionStateImplCopyWith<_$IntroductionStateImpl> get copyWith =>
      __$$IntroductionStateImplCopyWithImpl<_$IntroductionStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IntroductionStateImplToJson(
      this,
    );
  }
}

abstract class _IntroductionState extends IntroductionState {
  const factory _IntroductionState(
          {final Set<Introduction> completedIntroductions}) =
      _$IntroductionStateImpl;
  const _IntroductionState._() : super._();

  factory _IntroductionState.fromJson(Map<String, dynamic> json) =
      _$IntroductionStateImpl.fromJson;

  @override
  Set<Introduction> get completedIntroductions;
  @override
  @JsonKey(ignore: true)
  _$$IntroductionStateImplCopyWith<_$IntroductionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
