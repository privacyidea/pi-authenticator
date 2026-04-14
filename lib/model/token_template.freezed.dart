// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
TokenTemplate _$TokenTemplateFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'withSerial':
          return _TokenTemplateWithSerial.fromJson(
            json
          );
                case 'withOtps':
          return _TokenTemplateWithOtps.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'TokenTemplate',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$TokenTemplate implements DiagnosticableTreeMixin {

 Map<String, dynamic> get otpAuthMap; Map<String, dynamic> get additionalData; TokenContainer? get container;
/// Create a copy of TokenTemplate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenTemplateCopyWith<TokenTemplate> get copyWith => _$TokenTemplateCopyWithImpl<TokenTemplate>(this as TokenTemplate, _$identity);

  /// Serializes this TokenTemplate to a JSON map.
  Map<String, dynamic> toJson();

@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'TokenTemplate'))
    ..add(DiagnosticsProperty('otpAuthMap', otpAuthMap))..add(DiagnosticsProperty('additionalData', additionalData))..add(DiagnosticsProperty('container', container));
}



@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'TokenTemplate(otpAuthMap: $otpAuthMap, additionalData: $additionalData, container: $container)';
}


}

/// @nodoc
abstract mixin class $TokenTemplateCopyWith<$Res>  {
  factory $TokenTemplateCopyWith(TokenTemplate value, $Res Function(TokenTemplate) _then) = _$TokenTemplateCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> otpAuthMap, Map<String, dynamic> additionalData, TokenContainer? container
});


$TokenContainerCopyWith<$Res>? get container;

}
/// @nodoc
class _$TokenTemplateCopyWithImpl<$Res>
    implements $TokenTemplateCopyWith<$Res> {
  _$TokenTemplateCopyWithImpl(this._self, this._then);

  final TokenTemplate _self;
  final $Res Function(TokenTemplate) _then;

/// Create a copy of TokenTemplate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? otpAuthMap = null,Object? additionalData = null,Object? container = freezed,}) {
  return _then(_self.copyWith(
otpAuthMap: null == otpAuthMap ? _self.otpAuthMap : otpAuthMap // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,additionalData: null == additionalData ? _self.additionalData : additionalData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,container: freezed == container ? _self.container : container // ignore: cast_nullable_to_non_nullable
as TokenContainer?,
  ));
}
/// Create a copy of TokenTemplate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TokenContainerCopyWith<$Res>? get container {
    if (_self.container == null) {
    return null;
  }

  return $TokenContainerCopyWith<$Res>(_self.container!, (value) {
    return _then(_self.copyWith(container: value));
  });
}
}


/// Adds pattern-matching-related methods to [TokenTemplate].
extension TokenTemplatePatterns on TokenTemplate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _TokenTemplateWithSerial value)?  withSerial,TResult Function( _TokenTemplateWithOtps value)?  withOtps,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TokenTemplateWithSerial() when withSerial != null:
return withSerial(_that);case _TokenTemplateWithOtps() when withOtps != null:
return withOtps(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _TokenTemplateWithSerial value)  withSerial,required TResult Function( _TokenTemplateWithOtps value)  withOtps,}){
final _that = this;
switch (_that) {
case _TokenTemplateWithSerial():
return withSerial(_that);case _TokenTemplateWithOtps():
return withOtps(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _TokenTemplateWithSerial value)?  withSerial,TResult? Function( _TokenTemplateWithOtps value)?  withOtps,}){
final _that = this;
switch (_that) {
case _TokenTemplateWithSerial() when withSerial != null:
return withSerial(_that);case _TokenTemplateWithOtps() when withOtps != null:
return withOtps(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Map<String, dynamic> otpAuthMap,  String serial,  Map<String, dynamic> additionalData,  TokenContainer? container)?  withSerial,TResult Function( Map<String, dynamic> otpAuthMap,  List<String> otps,  Map<String, dynamic> additionalData,  TokenContainer? container)?  withOtps,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TokenTemplateWithSerial() when withSerial != null:
return withSerial(_that.otpAuthMap,_that.serial,_that.additionalData,_that.container);case _TokenTemplateWithOtps() when withOtps != null:
return withOtps(_that.otpAuthMap,_that.otps,_that.additionalData,_that.container);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Map<String, dynamic> otpAuthMap,  String serial,  Map<String, dynamic> additionalData,  TokenContainer? container)  withSerial,required TResult Function( Map<String, dynamic> otpAuthMap,  List<String> otps,  Map<String, dynamic> additionalData,  TokenContainer? container)  withOtps,}) {final _that = this;
switch (_that) {
case _TokenTemplateWithSerial():
return withSerial(_that.otpAuthMap,_that.serial,_that.additionalData,_that.container);case _TokenTemplateWithOtps():
return withOtps(_that.otpAuthMap,_that.otps,_that.additionalData,_that.container);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Map<String, dynamic> otpAuthMap,  String serial,  Map<String, dynamic> additionalData,  TokenContainer? container)?  withSerial,TResult? Function( Map<String, dynamic> otpAuthMap,  List<String> otps,  Map<String, dynamic> additionalData,  TokenContainer? container)?  withOtps,}) {final _that = this;
switch (_that) {
case _TokenTemplateWithSerial() when withSerial != null:
return withSerial(_that.otpAuthMap,_that.serial,_that.additionalData,_that.container);case _TokenTemplateWithOtps() when withOtps != null:
return withOtps(_that.otpAuthMap,_that.otps,_that.additionalData,_that.container);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TokenTemplateWithSerial extends TokenTemplate with DiagnosticableTreeMixin {
   _TokenTemplateWithSerial({required final  Map<String, dynamic> otpAuthMap, required this.serial, final  Map<String, dynamic> additionalData = const {}, this.container, final  String? $type}): _otpAuthMap = otpAuthMap,_additionalData = additionalData,$type = $type ?? 'withSerial',super._();
  factory _TokenTemplateWithSerial.fromJson(Map<String, dynamic> json) => _$TokenTemplateWithSerialFromJson(json);

 final  Map<String, dynamic> _otpAuthMap;
@override Map<String, dynamic> get otpAuthMap {
  if (_otpAuthMap is EqualUnmodifiableMapView) return _otpAuthMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_otpAuthMap);
}

 final  String serial;
 final  Map<String, dynamic> _additionalData;
@override@JsonKey() Map<String, dynamic> get additionalData {
  if (_additionalData is EqualUnmodifiableMapView) return _additionalData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_additionalData);
}

@override final  TokenContainer? container;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of TokenTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TokenTemplateWithSerialCopyWith<_TokenTemplateWithSerial> get copyWith => __$TokenTemplateWithSerialCopyWithImpl<_TokenTemplateWithSerial>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenTemplateWithSerialToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'TokenTemplate.withSerial'))
    ..add(DiagnosticsProperty('otpAuthMap', otpAuthMap))..add(DiagnosticsProperty('serial', serial))..add(DiagnosticsProperty('additionalData', additionalData))..add(DiagnosticsProperty('container', container));
}



@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'TokenTemplate.withSerial(otpAuthMap: $otpAuthMap, serial: $serial, additionalData: $additionalData, container: $container)';
}


}

/// @nodoc
abstract mixin class _$TokenTemplateWithSerialCopyWith<$Res> implements $TokenTemplateCopyWith<$Res> {
  factory _$TokenTemplateWithSerialCopyWith(_TokenTemplateWithSerial value, $Res Function(_TokenTemplateWithSerial) _then) = __$TokenTemplateWithSerialCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> otpAuthMap, String serial, Map<String, dynamic> additionalData, TokenContainer? container
});


@override $TokenContainerCopyWith<$Res>? get container;

}
/// @nodoc
class __$TokenTemplateWithSerialCopyWithImpl<$Res>
    implements _$TokenTemplateWithSerialCopyWith<$Res> {
  __$TokenTemplateWithSerialCopyWithImpl(this._self, this._then);

  final _TokenTemplateWithSerial _self;
  final $Res Function(_TokenTemplateWithSerial) _then;

/// Create a copy of TokenTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? otpAuthMap = null,Object? serial = null,Object? additionalData = null,Object? container = freezed,}) {
  return _then(_TokenTemplateWithSerial(
otpAuthMap: null == otpAuthMap ? _self._otpAuthMap : otpAuthMap // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,serial: null == serial ? _self.serial : serial // ignore: cast_nullable_to_non_nullable
as String,additionalData: null == additionalData ? _self._additionalData : additionalData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,container: freezed == container ? _self.container : container // ignore: cast_nullable_to_non_nullable
as TokenContainer?,
  ));
}

/// Create a copy of TokenTemplate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TokenContainerCopyWith<$Res>? get container {
    if (_self.container == null) {
    return null;
  }

  return $TokenContainerCopyWith<$Res>(_self.container!, (value) {
    return _then(_self.copyWith(container: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class _TokenTemplateWithOtps extends TokenTemplate with DiagnosticableTreeMixin {
   _TokenTemplateWithOtps({required final  Map<String, dynamic> otpAuthMap, required final  List<String> otps, final  Map<String, dynamic> additionalData = const {}, this.container, final  String? $type}): _otpAuthMap = otpAuthMap,_otps = otps,_additionalData = additionalData,$type = $type ?? 'withOtps',super._();
  factory _TokenTemplateWithOtps.fromJson(Map<String, dynamic> json) => _$TokenTemplateWithOtpsFromJson(json);

 final  Map<String, dynamic> _otpAuthMap;
@override Map<String, dynamic> get otpAuthMap {
  if (_otpAuthMap is EqualUnmodifiableMapView) return _otpAuthMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_otpAuthMap);
}

 final  List<String> _otps;
 List<String> get otps {
  if (_otps is EqualUnmodifiableListView) return _otps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_otps);
}

 final  Map<String, dynamic> _additionalData;
@override@JsonKey() Map<String, dynamic> get additionalData {
  if (_additionalData is EqualUnmodifiableMapView) return _additionalData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_additionalData);
}

@override final  TokenContainer? container;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of TokenTemplate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TokenTemplateWithOtpsCopyWith<_TokenTemplateWithOtps> get copyWith => __$TokenTemplateWithOtpsCopyWithImpl<_TokenTemplateWithOtps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenTemplateWithOtpsToJson(this, );
}
@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'TokenTemplate.withOtps'))
    ..add(DiagnosticsProperty('otpAuthMap', otpAuthMap))..add(DiagnosticsProperty('otps', otps))..add(DiagnosticsProperty('additionalData', additionalData))..add(DiagnosticsProperty('container', container));
}



@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'TokenTemplate.withOtps(otpAuthMap: $otpAuthMap, otps: $otps, additionalData: $additionalData, container: $container)';
}


}

/// @nodoc
abstract mixin class _$TokenTemplateWithOtpsCopyWith<$Res> implements $TokenTemplateCopyWith<$Res> {
  factory _$TokenTemplateWithOtpsCopyWith(_TokenTemplateWithOtps value, $Res Function(_TokenTemplateWithOtps) _then) = __$TokenTemplateWithOtpsCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> otpAuthMap, List<String> otps, Map<String, dynamic> additionalData, TokenContainer? container
});


@override $TokenContainerCopyWith<$Res>? get container;

}
/// @nodoc
class __$TokenTemplateWithOtpsCopyWithImpl<$Res>
    implements _$TokenTemplateWithOtpsCopyWith<$Res> {
  __$TokenTemplateWithOtpsCopyWithImpl(this._self, this._then);

  final _TokenTemplateWithOtps _self;
  final $Res Function(_TokenTemplateWithOtps) _then;

/// Create a copy of TokenTemplate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? otpAuthMap = null,Object? otps = null,Object? additionalData = null,Object? container = freezed,}) {
  return _then(_TokenTemplateWithOtps(
otpAuthMap: null == otpAuthMap ? _self._otpAuthMap : otpAuthMap // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,otps: null == otps ? _self._otps : otps // ignore: cast_nullable_to_non_nullable
as List<String>,additionalData: null == additionalData ? _self._additionalData : additionalData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,container: freezed == container ? _self.container : container // ignore: cast_nullable_to_non_nullable
as TokenContainer?,
  ));
}

/// Create a copy of TokenTemplate
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TokenContainerCopyWith<$Res>? get container {
    if (_self.container == null) {
    return null;
  }

  return $TokenContainerCopyWith<$Res>(_self.container!, (value) {
    return _then(_self.copyWith(container: value));
  });
}
}

// dart format on
