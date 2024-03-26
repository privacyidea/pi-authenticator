import 'algorithms.dart';

enum AppFeature {
  patchNotes,
}

extension AppFeatureX on AppFeature {
  String get name => switch (this) {
        AppFeature.patchNotes => 'patchNotes',
      };

  static AppFeature fromName(String featureString) => switch (featureString) {
        'patchNotes' => AppFeature.patchNotes,
        _ => throw LocalizedArgumentError<String>(
            localizedMessage: (localizations, feature, type) => localizations.invalidArgument(feature, type),
            unlocalizedMessage: 'Invalid AppFeature name: $featureString',
            invalidValue: featureString,
            name: 'AppFeature'),
      };
}
