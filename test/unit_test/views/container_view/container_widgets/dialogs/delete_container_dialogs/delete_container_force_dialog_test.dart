import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/token_container_state.dart';
import 'package:privacyidea_authenticator/model/token_container.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/token_container_notifier.dart';
import 'package:privacyidea_authenticator/views/container_view/container_widgets/dialogs/delete_container_dialogs.dart/delete_container_force_dialog.dart';

import '../../../../../../tests_app_wrapper.dart';
import '../../../../../../tests_app_wrapper.mocks.dart';

class FakeTokenContainerNotifier extends TokenContainerNotifier {
  final TokenContainerState initialState;
  final Future<bool> Function(TokenContainer) onDelete;

  FakeTokenContainerNotifier(this.initialState, this.onDelete);

  @override
  Future<TokenContainerState> build({
    Object? repo,
    Object? containerApi,
    Object? eccUtils,
  }) async => initialState;

  @override
  Future<bool> deleteContainer(TokenContainer container) async {
    return await onDelete(container);
  }
}

void main() {
  provideDummy<TokenContainerState>(TokenContainerState(containerList: []));

  testWidgets('should show correct serial in dialog title', (tester) async {
    final mockContainer = MockTokenContainerFinalized();
    when(mockContainer.serial).thenReturn('UNIQUE-SERIAL-999');

    final fakeNotifier = FakeTokenContainerNotifier(
      TokenContainerState(containerList: [mockContainer]),
      (_) async => true,
    );

    await tester.pumpWidget(
      TestsAppWrapper(
        overrides: [tokenContainerProvider.overrideWith(() => fakeNotifier)],
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

    expect(find.textContaining('UNIQUE-SERIAL-999'), findsOneWidget);
  });

  testWidgets('should return false and pop when delete fails', (tester) async {
    final mockContainer = MockTokenContainerFinalized();
    when(mockContainer.serial).thenReturn('ABC-123');
    bool? dialogResult;

    final fakeNotifier = FakeTokenContainerNotifier(
      TokenContainerState(containerList: [mockContainer]),
      (_) async => false,
    );

    await tester.pumpWidget(
      TestsAppWrapper(
        overrides: [tokenContainerProvider.overrideWith(() => fakeNotifier)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  dialogResult = await ForceDeleteContainerDialog.showDialog(
                    mockContainer,
                  );
                },
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

    expect(dialogResult, isFalse);
    expect(find.byType(ForceDeleteContainerDialog), findsNothing);
  });

  testWidgets('should pop dialog after deleting the container', (tester) async {
    final mockContainer = MockTokenContainerFinalized();
    when(mockContainer.serial).thenReturn('ABC-123');

    var state = TokenContainerState(containerList: [mockContainer]);
    var deleteCalled = false;

    final fakeNotifier = FakeTokenContainerNotifier(state, (container) async {
      deleteCalled = true;
      state = state.copyWith(
        containerList: state.containerList
            .where((c) => c.serial != 'ABC-123')
            .toList(),
      );
      return true;
    });

    await tester.pumpWidget(
      TestsAppWrapper(
        overrides: [tokenContainerProvider.overrideWith(() => fakeNotifier)],
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

    expect(deleteCalled, isTrue);
    expect(state.containerList, isEmpty);
    expect(find.textContaining('ABC-123'), findsNothing);
  });

  testWidgets('should pop dialog when pressing cancel', (tester) async {
    final mockContainer = MockTokenContainerFinalized();
    when(mockContainer.serial).thenReturn('ABC-123');

    var deleteCalled = false;
    final fakeNotifier = FakeTokenContainerNotifier(
      TokenContainerState(containerList: [mockContainer]),
      (_) async {
        deleteCalled = true;
        return true;
      },
    );

    await tester.pumpWidget(
      TestsAppWrapper(
        overrides: [tokenContainerProvider.overrideWith(() => fakeNotifier)],
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

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(deleteCalled, isFalse);
    expect(find.byType(ForceDeleteContainerDialog), findsNothing);
  });
}
