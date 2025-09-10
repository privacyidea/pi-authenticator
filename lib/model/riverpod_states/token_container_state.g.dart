// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_container_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TokenContainerState _$TokenContainerStateFromJson(Map<String, dynamic> json) =>
    _TokenContainerState(
      containerList: (json['containerList'] as List<dynamic>)
          .map((e) => TokenContainer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TokenContainerStateToJson(
  _TokenContainerState instance,
) => <String, dynamic>{'containerList': instance.containerList};
