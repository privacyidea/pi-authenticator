// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'processor_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProcessorResult<T> {

 ObjectValidator<ResultHandler>? get resultHandlerType;
/// Create a copy of ProcessorResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProcessorResultCopyWith<T, ProcessorResult<T>> get copyWith => _$ProcessorResultCopyWithImpl<T, ProcessorResult<T>>(this as ProcessorResult<T>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProcessorResult<T>&&(identical(other.resultHandlerType, resultHandlerType) || other.resultHandlerType == resultHandlerType));
}


@override
int get hashCode => Object.hash(runtimeType,resultHandlerType);

@override
String toString() {
  return 'ProcessorResult<$T>(resultHandlerType: $resultHandlerType)';
}


}

/// @nodoc
abstract mixin class $ProcessorResultCopyWith<T,$Res>  {
  factory $ProcessorResultCopyWith(ProcessorResult<T> value, $Res Function(ProcessorResult<T>) _then) = _$ProcessorResultCopyWithImpl;
@useResult
$Res call({
 ObjectValidator<ResultHandler>? resultHandlerType
});




}
/// @nodoc
class _$ProcessorResultCopyWithImpl<T,$Res>
    implements $ProcessorResultCopyWith<T, $Res> {
  _$ProcessorResultCopyWithImpl(this._self, this._then);

  final ProcessorResult<T> _self;
  final $Res Function(ProcessorResult<T>) _then;

/// Create a copy of ProcessorResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? resultHandlerType = freezed,}) {
  return _then(_self.copyWith(
resultHandlerType: freezed == resultHandlerType ? _self.resultHandlerType : resultHandlerType // ignore: cast_nullable_to_non_nullable
as ObjectValidator<ResultHandler>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProcessorResult].
extension ProcessorResultPatterns<T> on ProcessorResult<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProcessorResultSuccess<T> value)?  success,TResult Function( ProcessorResultFailed<T> value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProcessorResultSuccess() when success != null:
return success(_that);case ProcessorResultFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProcessorResultSuccess<T> value)  success,required TResult Function( ProcessorResultFailed<T> value)  failed,}){
final _that = this;
switch (_that) {
case ProcessorResultSuccess():
return success(_that);case ProcessorResultFailed():
return failed(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProcessorResultSuccess<T> value)?  success,TResult? Function( ProcessorResultFailed<T> value)?  failed,}){
final _that = this;
switch (_that) {
case ProcessorResultSuccess() when success != null:
return success(_that);case ProcessorResultFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( T resultData,  ObjectValidator<ResultHandler>? resultHandlerType)?  success,TResult Function( String Function(AppLocalizations) message,  dynamic error,  ObjectValidator<ResultHandler>? resultHandlerType)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProcessorResultSuccess() when success != null:
return success(_that.resultData,_that.resultHandlerType);case ProcessorResultFailed() when failed != null:
return failed(_that.message,_that.error,_that.resultHandlerType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( T resultData,  ObjectValidator<ResultHandler>? resultHandlerType)  success,required TResult Function( String Function(AppLocalizations) message,  dynamic error,  ObjectValidator<ResultHandler>? resultHandlerType)  failed,}) {final _that = this;
switch (_that) {
case ProcessorResultSuccess():
return success(_that.resultData,_that.resultHandlerType);case ProcessorResultFailed():
return failed(_that.message,_that.error,_that.resultHandlerType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( T resultData,  ObjectValidator<ResultHandler>? resultHandlerType)?  success,TResult? Function( String Function(AppLocalizations) message,  dynamic error,  ObjectValidator<ResultHandler>? resultHandlerType)?  failed,}) {final _that = this;
switch (_that) {
case ProcessorResultSuccess() when success != null:
return success(_that.resultData,_that.resultHandlerType);case ProcessorResultFailed() when failed != null:
return failed(_that.message,_that.error,_that.resultHandlerType);case _:
  return null;

}
}

}

/// @nodoc


class ProcessorResultSuccess<T> extends ProcessorResult<T> {
  const ProcessorResultSuccess(this.resultData, {this.resultHandlerType}): super._();
  

 final  T resultData;
@override final  ObjectValidator<ResultHandler>? resultHandlerType;

/// Create a copy of ProcessorResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProcessorResultSuccessCopyWith<T, ProcessorResultSuccess<T>> get copyWith => _$ProcessorResultSuccessCopyWithImpl<T, ProcessorResultSuccess<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProcessorResultSuccess<T>&&const DeepCollectionEquality().equals(other.resultData, resultData)&&(identical(other.resultHandlerType, resultHandlerType) || other.resultHandlerType == resultHandlerType));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(resultData),resultHandlerType);

@override
String toString() {
  return 'ProcessorResult<$T>.success(resultData: $resultData, resultHandlerType: $resultHandlerType)';
}


}

/// @nodoc
abstract mixin class $ProcessorResultSuccessCopyWith<T,$Res> implements $ProcessorResultCopyWith<T, $Res> {
  factory $ProcessorResultSuccessCopyWith(ProcessorResultSuccess<T> value, $Res Function(ProcessorResultSuccess<T>) _then) = _$ProcessorResultSuccessCopyWithImpl;
@override @useResult
$Res call({
 T resultData, ObjectValidator<ResultHandler>? resultHandlerType
});




}
/// @nodoc
class _$ProcessorResultSuccessCopyWithImpl<T,$Res>
    implements $ProcessorResultSuccessCopyWith<T, $Res> {
  _$ProcessorResultSuccessCopyWithImpl(this._self, this._then);

  final ProcessorResultSuccess<T> _self;
  final $Res Function(ProcessorResultSuccess<T>) _then;

/// Create a copy of ProcessorResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? resultData = freezed,Object? resultHandlerType = freezed,}) {
  return _then(ProcessorResultSuccess<T>(
freezed == resultData ? _self.resultData : resultData // ignore: cast_nullable_to_non_nullable
as T,resultHandlerType: freezed == resultHandlerType ? _self.resultHandlerType : resultHandlerType // ignore: cast_nullable_to_non_nullable
as ObjectValidator<ResultHandler>?,
  ));
}


}

/// @nodoc


class ProcessorResultFailed<T> extends ProcessorResult<T> {
  const ProcessorResultFailed(this.message, {this.error, this.resultHandlerType}): super._();
  

 final  String Function(AppLocalizations) message;
 final  dynamic error;
@override final  ObjectValidator<ResultHandler>? resultHandlerType;

/// Create a copy of ProcessorResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProcessorResultFailedCopyWith<T, ProcessorResultFailed<T>> get copyWith => _$ProcessorResultFailedCopyWithImpl<T, ProcessorResultFailed<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProcessorResultFailed<T>&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.error, error)&&(identical(other.resultHandlerType, resultHandlerType) || other.resultHandlerType == resultHandlerType));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(error),resultHandlerType);

@override
String toString() {
  return 'ProcessorResult<$T>.failed(message: $message, error: $error, resultHandlerType: $resultHandlerType)';
}


}

/// @nodoc
abstract mixin class $ProcessorResultFailedCopyWith<T,$Res> implements $ProcessorResultCopyWith<T, $Res> {
  factory $ProcessorResultFailedCopyWith(ProcessorResultFailed<T> value, $Res Function(ProcessorResultFailed<T>) _then) = _$ProcessorResultFailedCopyWithImpl;
@override @useResult
$Res call({
 String Function(AppLocalizations) message, dynamic error, ObjectValidator<ResultHandler>? resultHandlerType
});




}
/// @nodoc
class _$ProcessorResultFailedCopyWithImpl<T,$Res>
    implements $ProcessorResultFailedCopyWith<T, $Res> {
  _$ProcessorResultFailedCopyWithImpl(this._self, this._then);

  final ProcessorResultFailed<T> _self;
  final $Res Function(ProcessorResultFailed<T>) _then;

/// Create a copy of ProcessorResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? error = freezed,Object? resultHandlerType = freezed,}) {
  return _then(ProcessorResultFailed<T>(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String Function(AppLocalizations),error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as dynamic,resultHandlerType: freezed == resultHandlerType ? _self.resultHandlerType : resultHandlerType // ignore: cast_nullable_to_non_nullable
as ObjectValidator<ResultHandler>?,
  ));
}


}

// dart format on
