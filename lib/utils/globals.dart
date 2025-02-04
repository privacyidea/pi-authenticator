/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>
  Copyright (c) 2017-2024 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../model/enums/patch_note_type.dart';
import '../model/version.dart';

Map<Version, Map<PatchNoteType, List<String>>> getLocalizedPatchNotes(AppLocalizations localizations) => {
      const Version(4, 5, 0): {
        PatchNoteType.newFeature: [
          localizations.patchNotesV4_5_0NewFeatures1,
        ],
        PatchNoteType.bugFix: [
          localizations.patchNotesV4_5_0BugFix1,
        ],
      },
      const Version(4, 4, 2): {
        PatchNoteType.newFeature: [
          localizations.patchNotesV4_4_2NewFeatures1,
          localizations.patchNotesV4_4_2NewFeatures2,
        ],
        PatchNoteType.improvement: [
          localizations.patchNotesV4_4_2Improvement1,
        ]
      },
      const Version(4, 4, 0): {
        PatchNoteType.newFeature: [
          localizations.patchNotesV4_4_0NewFeatures1,
          localizations.patchNotesV4_4_0NewFeatures2,
        ],
        PatchNoteType.improvement: [
          localizations.patchNotesV4_4_0Improvement1,
          localizations.patchNotesV4_4_0Improvement2,
        ]
      },
      const Version(4, 3, 1): {
        PatchNoteType.bugFix: [
          localizations.patchNotesV4_3_1BugFix1,
        ],
        PatchNoteType.improvement: [
          localizations.patchNotesV4_3_1Improvement1,
        ]
      },
      const Version(4, 3, 0): {
        PatchNoteType.newFeature: [
          localizations.patchNotesV4_3_0NewFeatures1,
          localizations.patchNotesV4_3_0NewFeatures2,
          localizations.patchNotesV4_3_0NewFeatures3,
          localizations.patchNotesV4_3_0NewFeatures4,
          localizations.patchNotesV4_3_0NewFeatures5,
          localizations.patchNotesV4_3_0NewFeatures6,
        ],
      },
    };

final globalSnackbarKey = GlobalKey<ScaffoldMessengerState>();
final globalNavigatorKey = GlobalKey<NavigatorState>();
final Future<GlobalKey<NavigatorState>> contextedGlobalNavigatorKey = Future(() async => await _getContextedGlobalNavigatorKey());
BuildContext? get globalContextSync {
  try {
    return globalNavigatorKey.currentContext;
  } catch (e) {
    return null;
  }
}

final Future<BuildContext> globalContext = Future(() async => await _getContextedGlobalNavigatorKey()).then((value) => value.currentContext!);
Future<GlobalKey<NavigatorState>> _getContextedGlobalNavigatorKey() async {
  if (globalNavigatorKey.currentContext != null) {
    return globalNavigatorKey;
  } else {
    return await Future.delayed(const Duration(milliseconds: 500), _getContextedGlobalNavigatorKey);
  }
}

final policyStatementUri = Uri.parse("https://netknights.it/en/privacy-statement/");
final piAuthenticatorGitHubUri = Uri.parse("https://github.com/privacyidea/pi-authenticator");

// The highest version of the pipush Tokentype that this client supports.
const maxPushTokenVersion = 1;

WidgetRef? globalRef;
