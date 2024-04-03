enum AppFeature {
  patchNotes,
}

extension AppFeatureX on AppFeature {
  String get name => switch (this) {
        AppFeature.patchNotes => 'patchNotes',
      };

  static AppFeature fromName(String featureString) => switch (featureString) {
        'patchNotes' => AppFeature.patchNotes,
        _ => throw ArgumentError('Invalid feature string: $featureString'),
      };
}
