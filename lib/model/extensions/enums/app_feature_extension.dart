import '../../enums/app_feature.dart';

extension AppFeatureX on AppFeature {
  bool isDisabled(Set<AppFeature> disabledFeatures) => disabledFeatures.contains(this);
  bool isEnabled(Set<AppFeature> disabledFeatures) => !isDisabled(disabledFeatures);
}
