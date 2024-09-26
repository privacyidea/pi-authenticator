// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_container_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TokenContainerStateImpl _$$TokenContainerStateImplFromJson(
        Map<String, dynamic> json) =>
    _$TokenContainerStateImpl(
      containerList: (json['containerList'] as List<dynamic>)
          .map((e) => TokenContainer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$TokenContainerStateImplToJson(
        _$TokenContainerStateImpl instance) =>
    <String, dynamic>{
      'containerList': instance.containerList,
    };
