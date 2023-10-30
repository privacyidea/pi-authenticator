// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'introductions_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IntroductionsState _$IntroductionsStateFromJson(Map<String, dynamic> json) =>
    IntroductionsState(
      completedIntroductions: (json['completedIntroductions'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$IntroductionEnumMap, e))
              .toSet() ??
          const {},
    );

Map<String, dynamic> _$IntroductionsStateToJson(IntroductionsState instance) =>
    <String, dynamic>{
      'completedIntroductions': instance.completedIntroductions
          .map((e) => _$IntroductionEnumMap[e]!)
          .toList(),
    };

const _$IntroductionEnumMap = {
  Introduction.easyAuthentication: 'easyAuthentication',
  Introduction.maximaleSecurity: 'maximaleSecurity',
  Introduction.visitOnGithub: 'visitOnGithub',
  Introduction.scanQrCode: 'scanQrCode',
  Introduction.addManually: 'addManually',
  Introduction.tokenSwipe: 'tokenSwipe',
  Introduction.editToken: 'editToken',
  Introduction.lockToken: 'lockToken',
  Introduction.groupTokens: 'groupTokens',
  Introduction.pollForChanges: 'pollForChanges',
  Introduction.hidePushToken: 'hidePushToken',
};
