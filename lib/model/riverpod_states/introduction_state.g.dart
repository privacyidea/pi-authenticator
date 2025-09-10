// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'introduction_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IntroductionState _$IntroductionStateFromJson(Map<String, dynamic> json) =>
    _IntroductionState(
      completedIntroductions:
          (json['completedIntroductions'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$IntroductionEnumMap, e))
              .toSet() ??
          const {},
    );

Map<String, dynamic> _$IntroductionStateToJson(_IntroductionState instance) =>
    <String, dynamic>{
      'completedIntroductions': instance.completedIntroductions
          .map((e) => _$IntroductionEnumMap[e]!)
          .toList(),
    };

const _$IntroductionEnumMap = {
  Introduction.introductionScreen: 'introductionScreen',
  Introduction.scanQrCode: 'scanQrCode',
  Introduction.addManually: 'addManually',
  Introduction.tokenSwipe: 'tokenSwipe',
  Introduction.editToken: 'editToken',
  Introduction.lockToken: 'lockToken',
  Introduction.dragToken: 'dragToken',
  Introduction.addFolder: 'addFolder',
  Introduction.pollForChallenges: 'pollForChallenges',
  Introduction.hidePushTokens: 'hidePushTokens',
  Introduction.exportTokens: 'exportTokens',
};
