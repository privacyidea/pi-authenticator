// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pi_server_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PiServerResponse<T extends PiServerResultValue,D extends PiServerResultDetail> {

 int get statusCode; int get id; String get jsonrpc; double get time; String get version; String get versionNumber; String get signature; D? get detail;



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PiServerResponse<T, D>&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.id, id) || other.id == id)&&(identical(other.jsonrpc, jsonrpc) || other.jsonrpc == jsonrpc)&&(identical(other.time, time) || other.time == time)&&(identical(other.version, version) || other.version == version)&&(identical(other.versionNumber, versionNumber) || other.versionNumber == versionNumber)&&(identical(other.signature, signature) || other.signature == signature)&&const DeepCollectionEquality().equals(other.detail, detail));
}


@override
int get hashCode => Object.hash(runtimeType,statusCode,id,jsonrpc,time,version,versionNumber,signature,const DeepCollectionEquality().hash(detail));

@override
String toString() {
  return 'PiServerResponse<$T, $D>(statusCode: $statusCode, id: $id, jsonrpc: $jsonrpc, time: $time, version: $version, versionNumber: $versionNumber, signature: $signature, detail: $detail)';
}


}




/// Adds pattern-matching-related methods to [PiServerResponse].
extension PiServerResponsePatterns<T extends PiServerResultValue,D extends PiServerResultDetail> on PiServerResponse<T, D> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PiSuccessResponse<T, D> value)?  success,TResult Function( PiErrorResponse<T, D> value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PiSuccessResponse() when success != null:
return success(_that);case PiErrorResponse() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PiSuccessResponse<T, D> value)  success,required TResult Function( PiErrorResponse<T, D> value)  error,}){
final _that = this;
switch (_that) {
case PiSuccessResponse():
return success(_that);case PiErrorResponse():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PiSuccessResponse<T, D> value)?  success,TResult? Function( PiErrorResponse<T, D> value)?  error,}){
final _that = this;
switch (_that) {
case PiSuccessResponse() when success != null:
return success(_that);case PiErrorResponse() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int statusCode,  int id,  String jsonrpc,  T resultValue,  double time,  String version,  String versionNumber,  String signature,  D? detail)?  success,TResult Function( int statusCode,  int id,  String jsonrpc,  D? detail,  PiServerResultError piServerResultError,  double time,  String version,  String versionNumber,  String signature)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PiSuccessResponse() when success != null:
return success(_that.statusCode,_that.id,_that.jsonrpc,_that.resultValue,_that.time,_that.version,_that.versionNumber,_that.signature,_that.detail);case PiErrorResponse() when error != null:
return error(_that.statusCode,_that.id,_that.jsonrpc,_that.detail,_that.piServerResultError,_that.time,_that.version,_that.versionNumber,_that.signature);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int statusCode,  int id,  String jsonrpc,  T resultValue,  double time,  String version,  String versionNumber,  String signature,  D? detail)  success,required TResult Function( int statusCode,  int id,  String jsonrpc,  D? detail,  PiServerResultError piServerResultError,  double time,  String version,  String versionNumber,  String signature)  error,}) {final _that = this;
switch (_that) {
case PiSuccessResponse():
return success(_that.statusCode,_that.id,_that.jsonrpc,_that.resultValue,_that.time,_that.version,_that.versionNumber,_that.signature,_that.detail);case PiErrorResponse():
return error(_that.statusCode,_that.id,_that.jsonrpc,_that.detail,_that.piServerResultError,_that.time,_that.version,_that.versionNumber,_that.signature);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int statusCode,  int id,  String jsonrpc,  T resultValue,  double time,  String version,  String versionNumber,  String signature,  D? detail)?  success,TResult? Function( int statusCode,  int id,  String jsonrpc,  D? detail,  PiServerResultError piServerResultError,  double time,  String version,  String versionNumber,  String signature)?  error,}) {final _that = this;
switch (_that) {
case PiSuccessResponse() when success != null:
return success(_that.statusCode,_that.id,_that.jsonrpc,_that.resultValue,_that.time,_that.version,_that.versionNumber,_that.signature,_that.detail);case PiErrorResponse() when error != null:
return error(_that.statusCode,_that.id,_that.jsonrpc,_that.detail,_that.piServerResultError,_that.time,_that.version,_that.versionNumber,_that.signature);case _:
  return null;

}
}

}

/// @nodoc


class PiSuccessResponse<T extends PiServerResultValue,D extends PiServerResultDetail> extends PiServerResponse<T, D> {
   PiSuccessResponse({required this.statusCode, required this.id, required this.jsonrpc, required this.resultValue, required this.time, required this.version, required this.versionNumber, required this.signature, this.detail = null}): super._();
  

@override final  int statusCode;
@override final  int id;
@override final  String jsonrpc;
 final  T resultValue;
@override final  double time;
@override final  String version;
@override final  String versionNumber;
@override final  String signature;
@override@JsonKey() final  D? detail;




@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PiSuccessResponse<T, D>&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.id, id) || other.id == id)&&(identical(other.jsonrpc, jsonrpc) || other.jsonrpc == jsonrpc)&&const DeepCollectionEquality().equals(other.resultValue, resultValue)&&(identical(other.time, time) || other.time == time)&&(identical(other.version, version) || other.version == version)&&(identical(other.versionNumber, versionNumber) || other.versionNumber == versionNumber)&&(identical(other.signature, signature) || other.signature == signature)&&const DeepCollectionEquality().equals(other.detail, detail));
}


@override
int get hashCode => Object.hash(runtimeType,statusCode,id,jsonrpc,const DeepCollectionEquality().hash(resultValue),time,version,versionNumber,signature,const DeepCollectionEquality().hash(detail));

@override
String toString() {
  return 'PiServerResponse<$T, $D>.success(statusCode: $statusCode, id: $id, jsonrpc: $jsonrpc, resultValue: $resultValue, time: $time, version: $version, versionNumber: $versionNumber, signature: $signature, detail: $detail)';
}


}




/// @nodoc


class PiErrorResponse<T extends PiServerResultValue,D extends PiServerResultDetail> extends PiServerResponse<T, D> {
   PiErrorResponse({required this.statusCode, required this.id, required this.jsonrpc, this.detail = null, required this.piServerResultError, required this.time, required this.version, required this.versionNumber, required this.signature}): super._();
  

@override final  int statusCode;
@override final  int id;
@override final  String jsonrpc;
@override@JsonKey() final  D? detail;
/// This is a throwable error
 final  PiServerResultError piServerResultError;
@override final  double time;
@override final  String version;
@override final  String versionNumber;
@override final  String signature;




@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PiErrorResponse<T, D>&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&(identical(other.id, id) || other.id == id)&&(identical(other.jsonrpc, jsonrpc) || other.jsonrpc == jsonrpc)&&const DeepCollectionEquality().equals(other.detail, detail)&&(identical(other.piServerResultError, piServerResultError) || other.piServerResultError == piServerResultError)&&(identical(other.time, time) || other.time == time)&&(identical(other.version, version) || other.version == version)&&(identical(other.versionNumber, versionNumber) || other.versionNumber == versionNumber)&&(identical(other.signature, signature) || other.signature == signature));
}


@override
int get hashCode => Object.hash(runtimeType,statusCode,id,jsonrpc,const DeepCollectionEquality().hash(detail),piServerResultError,time,version,versionNumber,signature);

@override
String toString() {
  return 'PiServerResponse<$T, $D>.error(statusCode: $statusCode, id: $id, jsonrpc: $jsonrpc, detail: $detail, piServerResultError: $piServerResultError, time: $time, version: $version, versionNumber: $versionNumber, signature: $signature)';
}


}




// dart format on
