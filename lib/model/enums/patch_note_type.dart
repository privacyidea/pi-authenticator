import '../../l10n/app_localizations.dart';

enum PatchNoteType {
  newFeature,
  improvement,
  bugFix,
}

extension PatchNoteTypeExtension on PatchNoteType {
  String getName(AppLocalizations localizations) => switch (this) {
        PatchNoteType.newFeature => localizations.patchNotesNewFeatures,
        PatchNoteType.improvement => localizations.patchNotesImprovements,
        PatchNoteType.bugFix => localizations.patchNotesBugFixes,
      };
}
