import '../../../l10n/app_localizations.dart';
import '../../enums/patch_note_type.dart';

extension PatchNoteTypeX on PatchNoteType {
  String localizedName(AppLocalizations localizations) => switch (this) {
        PatchNoteType.newFeature => localizations.patchNotesNewFeatures,
        PatchNoteType.improvement => localizations.patchNotesImprovements,
        PatchNoteType.bugFix => localizations.patchNotesBugFixes,
      };
}
