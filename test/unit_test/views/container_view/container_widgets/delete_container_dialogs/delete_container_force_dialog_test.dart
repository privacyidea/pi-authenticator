import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'package:privacyidea_authenticator/views/container_view/container_widgets/dialogs/delete_container_dialogs.dart/delete_container_force_dialog.dart';

import '../../../../../tests_app_wrapper.dart';
import '../../../../../tests_app_wrapper.mocks.dart';

void main() {
  testWidgets('should call delete via TestsAppWrapper', (tester) async {
    final mockNotifier = MockTokenContainerNotifier();
    final mockContainer = MockTokenContainerFinalized();
    when(mockContainer.serial).thenReturn('ABC-123');
    when(mockNotifier.deleteContainer(any)).thenAnswer((_) async => true);

    await tester.pumpWidget(
      TestsAppWrapper(
        overrides: [tokenContainerProvider.overrideWith(() => mockNotifier)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    ForceDeleteContainerDialog.showDialog(mockContainer),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    verify(mockNotifier.deleteContainer(mockContainer)).called(1);
  });
}
