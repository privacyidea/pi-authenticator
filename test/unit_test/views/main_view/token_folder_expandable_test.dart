import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/model/enums/algorithms.dart';
import 'package:privacyidea_authenticator/model/token_folder.dart';
import 'package:privacyidea_authenticator/model/tokens/hotp_token.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/state_providers/dragging_sortable_provider.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/folder_widgets/token_folder_expandable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../tests_app_wrapper.dart';

final _token = HOTPToken(
  id: 'inFolder',
  algorithm: Algorithms.SHA1,
  digits: 6,
  secret: 'secret',
  folderId: 1,
);

/// The only token counts as dragged, so the panel's body is an empty box: the
/// expand logic is under test, not the token tiles.
Widget _panel(TokenFolder folder) => TestsAppWrapper(
  overrides: [draggingSortableProvider.overrideWith((ref) => _token)],
  child: SingleChildScrollView(
    child: TokenFolderExpandable(
      key: const ValueKey('folder_1'),
      folder: folder,
      folderTokens: [_token],
    ),
  ),
);

bool _panelIsExpanded(WidgetTester tester) =>
    tester.widget<ExpandablePanel>(find.byType(ExpandablePanel)).controller!.expanded;

void main() {
  // A tap saves the folder through the real folder repository.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('TokenFolderExpandable', () {
    testWidgets('collapses when the stored folder is collapsed', (tester) async {
      // What happens on resume: hiding the app collapsed the locked folder in
      // state and storage while its panel stayed mounted.
      const folder = TokenFolder(label: 'f', folderId: 1, isLocked: true);
      await tester.pumpWidget(_panel(folder.copyWith(isExpanded: true)));
      await tester.pump();
      expect(_panelIsExpanded(tester), isTrue);

      await tester.pumpWidget(_panel(folder.copyWith(isExpanded: false)));
      await tester.pump();

      expect(_panelIsExpanded(tester), isFalse);
    });

    testWidgets('keeps a tap that is not saved yet across a rebuild', (
      tester,
    ) async {
      const folder = TokenFolder(label: 'f', folderId: 1);
      await tester.pumpWidget(_panel(folder));
      await tester.pump();

      // The user opens the folder; its save follows a frame later, so the
      // parent can rebuild the panel with the old folder in between.
      tester
              .widget<ExpandablePanel>(find.byType(ExpandablePanel))
              .controller!
              .expanded =
          true;
      await tester.pumpWidget(_panel(folder.copyWith(label: 'f')));

      expect(_panelIsExpanded(tester), isTrue);
    });

    testWidgets('keeps the second of two quick taps when the first save arrives', (
      tester,
    ) async {
      const folder = TokenFolder(label: 'f', folderId: 1);
      await tester.pumpWidget(_panel(folder));
      await tester.pump();

      // The user opens and closes the folder before the opening is stored.
      final controller = tester
          .widget<ExpandablePanel>(find.byType(ExpandablePanel))
          .controller!;
      controller.expanded = true;
      controller.expanded = false;
      await tester.pumpWidget(_panel(folder.copyWith(isExpanded: true)));

      expect(_panelIsExpanded(tester), isFalse);
    });

    testWidgets('expands when the stored folder is expanded', (tester) async {
      // What a home widget link to a token in a locked folder does.
      const folder = TokenFolder(label: 'f', folderId: 1, isLocked: true);
      await tester.pumpWidget(_panel(folder));
      await tester.pump();
      expect(_panelIsExpanded(tester), isFalse);

      await tester.pumpWidget(_panel(folder.copyWith(isExpanded: true)));
      await tester.pump();

      expect(_panelIsExpanded(tester), isTrue);
    });
  });
}
