/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/model/enums/introduction.dart';
import 'package:privacyidea_authenticator/model/riverpod_states/introduction_state.dart';
import 'package:privacyidea_authenticator/utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';

import '../../tests_app_wrapper.mocks.dart';

void main() {
  _testIntroductionNotifier();
}

void _testIntroductionNotifier() {
  setUpAll(() {
    provideDummy<IntroductionState>(
      IntroductionState(completedIntroductions: {}),
    );
  });

  group('IntroductionNotifier', () {
    MockIntroductionRepository setupMock(IntroductionState Function() getter, void Function(IntroductionState) setter) {
      final mock = MockIntroductionRepository();
      when(mock.loadCompletedIntroductions()).thenAnswer((_) async => getter());
      when(mock.saveCompletedIntroductions(any)).thenAnswer((inv) async {
        setter(inv.positionalArguments[0] as IntroductionState);
        return true;
      });
      return mock;
    }

    test('build loads state from repository', () async {
      final initial = IntroductionState(
        completedIntroductions: {Introduction.scanQrCode},
      );
      final mock = setupMock(() => initial, (_) {});
      final provider = introductionProviderOf(repo: mock);
      final container = ProviderContainer();

      final state = await container.read(provider.future);
      expect(state.completedIntroductions, contains(Introduction.scanQrCode));
      verify(mock.loadCompletedIntroductions()).called(1);
    });

    test('complete adds introduction to completed set', () async {
      var repoState = IntroductionState(completedIntroductions: {});
      final mock = MockIntroductionRepository();
      when(mock.loadCompletedIntroductions()).thenAnswer((_) async => repoState);
      when(mock.saveCompletedIntroductions(any)).thenAnswer((inv) async {
        repoState = inv.positionalArguments[0] as IntroductionState;
        return true;
      });

      final notifier = IntroductionNotifier(repoOverride: mock);
      final provider = introductionProviderOf(repo: mock);
      final container = ProviderContainer(
        overrides: [provider.overrideWith(() => notifier)],
      );

      await container.read(provider.future);
      await container.read(provider.notifier).complete(Introduction.scanQrCode);

      final state = await container.read(provider.future);
      expect(state.completedIntroductions, contains(Introduction.scanQrCode));
      verify(mock.saveCompletedIntroductions(any)).called(1);
    });

    test('uncomplete removes introduction from completed set', () async {
      var repoState = IntroductionState(
        completedIntroductions: {Introduction.scanQrCode, Introduction.addManually},
      );
      final mock = MockIntroductionRepository();
      when(mock.loadCompletedIntroductions()).thenAnswer((_) async => repoState);
      when(mock.saveCompletedIntroductions(any)).thenAnswer((inv) async {
        repoState = inv.positionalArguments[0] as IntroductionState;
        return true;
      });

      final notifier = IntroductionNotifier(repoOverride: mock);
      final provider = introductionProviderOf(repo: mock);
      final container = ProviderContainer(
        overrides: [provider.overrideWith(() => notifier)],
      );

      await container.read(provider.future);
      await container
          .read(provider.notifier)
          .uncomplete(Introduction.scanQrCode);

      final state = await container.read(provider.future);
      expect(state.completedIntroductions, isNot(contains(Introduction.scanQrCode)));
      expect(state.completedIntroductions, contains(Introduction.addManually));
    });

    test('completeAll marks all introductions as done', () async {
      var repoState = IntroductionState(completedIntroductions: {});
      final mock = MockIntroductionRepository();
      when(mock.loadCompletedIntroductions()).thenAnswer((_) async => repoState);
      when(mock.saveCompletedIntroductions(any)).thenAnswer((inv) async {
        repoState = inv.positionalArguments[0] as IntroductionState;
        return true;
      });

      final notifier = IntroductionNotifier(repoOverride: mock);
      final provider = introductionProviderOf(repo: mock);
      final container = ProviderContainer(
        overrides: [provider.overrideWith(() => notifier)],
      );

      await container.read(provider.future);
      await container.read(provider.notifier).completeAll();

      final state = await container.read(provider.future);
      expect(
        state.completedIntroductions,
        containsAll(Introduction.values),
      );
    });

    test('completeMultiple adds multiple introductions at once', () async {
      var repoState = IntroductionState(completedIntroductions: {});
      final mock = MockIntroductionRepository();
      when(mock.loadCompletedIntroductions()).thenAnswer((_) async => repoState);
      when(mock.saveCompletedIntroductions(any)).thenAnswer((inv) async {
        repoState = inv.positionalArguments[0] as IntroductionState;
        return true;
      });

      final notifier = IntroductionNotifier(repoOverride: mock);
      final provider = introductionProviderOf(repo: mock);
      final container = ProviderContainer(
        overrides: [provider.overrideWith(() => notifier)],
      );

      await container.read(provider.future);
      await container.read(provider.notifier).completeMultiple([
        Introduction.scanQrCode,
        Introduction.addManually,
      ]);

      final state = await container.read(provider.future);
      expect(state.completedIntroductions, contains(Introduction.scanQrCode));
      expect(state.completedIntroductions, contains(Introduction.addManually));
      verify(mock.saveCompletedIntroductions(any)).called(1);
    });

    test('uncompleteMultiple removes multiple introductions at once', () async {
      var repoState = IntroductionState(
        completedIntroductions: Introduction.values.toSet(),
      );
      final mock = MockIntroductionRepository();
      when(mock.loadCompletedIntroductions()).thenAnswer((_) async => repoState);
      when(mock.saveCompletedIntroductions(any)).thenAnswer((inv) async {
        repoState = inv.positionalArguments[0] as IntroductionState;
        return true;
      });

      final notifier = IntroductionNotifier(repoOverride: mock);
      final provider = introductionProviderOf(repo: mock);
      final container = ProviderContainer(
        overrides: [provider.overrideWith(() => notifier)],
      );

      await container.read(provider.future);
      await container.read(provider.notifier).uncompleteMultiple([
        Introduction.scanQrCode,
        Introduction.addManually,
      ]);

      final state = await container.read(provider.future);
      expect(state.completedIntroductions, isNot(contains(Introduction.scanQrCode)));
      expect(state.completedIntroductions, isNot(contains(Introduction.addManually)));
      expect(state.completedIntroductions, contains(Introduction.tokenSwipe));
    });
  });
}
