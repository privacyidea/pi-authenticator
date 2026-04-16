/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacyidea_authenticator/widgets/pi_text_field.dart';

import '../../tests_app_wrapper.dart';

void main() {
  group('PiTextField Tests', () {
    testWidgets('renders with label text', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(child: PiTextField(labelText: 'Username')),
      );

      expect(find.text('Username'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('renders without label text', (tester) async {
      await tester.pumpWidget(const TestsAppWrapper(child: PiTextField()));

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('calls onChanged when text is entered', (tester) async {
      String? changedValue;
      await tester.pumpWidget(
        TestsAppWrapper(
          child: PiTextField(
            labelText: 'Input',
            onChanged: (value) => changedValue = value,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'hello');
      expect(changedValue, 'hello');
    });

    testWidgets('uses provided controller', (tester) async {
      final controller = TextEditingController(text: 'initial');
      await tester.pumpWidget(
        TestsAppWrapper(child: PiTextField(controller: controller)),
      );

      expect(find.text('initial'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'updated');
      expect(controller.text, 'updated');
    });

    testWidgets('obscures text when obscureText is true', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(child: PiTextField(obscureText: true)),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
    });

    testWidgets('validator shows error message', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: PiTextField(
            labelText: 'Email',
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              return null;
            },
          ),
        ),
      );

      // Enter text then clear to trigger validation
      await tester.enterText(find.byType(TextFormField), 'a');
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump();

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('validator shows no error for valid input', (tester) async {
      await tester.pumpWidget(
        TestsAppWrapper(
          child: PiTextField(
            labelText: 'Email',
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              return null;
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.pump();

      expect(find.text('Required'), findsNothing);
    });

    testWidgets('calls onFieldSubmitted', (tester) async {
      String? submittedValue;
      await tester.pumpWidget(
        TestsAppWrapper(
          child: PiTextField(
            onFieldSubmitted: (value) => submittedValue = value,
            textInputAction: TextInputAction.done,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'submitted');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submittedValue, 'submitted');
    });

    testWidgets('autofocus is false by default', (tester) async {
      await tester.pumpWidget(const TestsAppWrapper(child: PiTextField()));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.autofocus, isFalse);
    });

    testWidgets('autofocus can be set to true', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(child: PiTextField(autofocus: true)),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.autofocus, isTrue);
    });

    testWidgets('uses titleSmall text style from theme', (tester) async {
      await tester.pumpWidget(const TestsAppWrapper(child: PiTextField()));

      final context = tester.element(find.byType(PiTextField));
      final expectedStyle = Theme.of(context).textTheme.titleSmall;

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style, expectedStyle);
    });

    testWidgets('errorMaxLines is set to 2', (tester) async {
      await tester.pumpWidget(
        const TestsAppWrapper(child: PiTextField(labelText: 'Test')),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration!.errorMaxLines, 2);
    });

    testWidgets('autocorrect and enableSuggestions default to false', (
      tester,
    ) async {
      await tester.pumpWidget(const TestsAppWrapper(child: PiTextField()));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.autocorrect, isFalse);
      expect(textField.enableSuggestions, isFalse);
    });
  });
}
