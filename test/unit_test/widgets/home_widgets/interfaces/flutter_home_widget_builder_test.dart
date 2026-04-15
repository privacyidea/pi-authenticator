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
import 'package:mockito/mockito.dart';
import 'package:privacyidea_authenticator/utils/home_widget_utils.dart';
import 'package:privacyidea_authenticator/widgets/home_widgets/interfaces/flutter_home_widget_base.dart';
import 'package:privacyidea_authenticator/widgets/home_widgets/interfaces/flutter_home_widget_builder.dart';

import '../../../../tests_app_wrapper.mocks.dart';

class _FakeHomeWidget extends FlutterHomeWidgetBase {
  const _FakeHomeWidget({
    super.key,
    required super.logicalSize,
    required super.theme,
    required super.utils,
    super.aditionalSuffix,
  });

  @override
  Widget build(BuildContext context) => Container();
}

class _TestBuilder extends FlutterHomeWidgetBuilder<_FakeHomeWidget> {
  _TestBuilder({
    required super.lightTheme,
    required super.darkTheme,
    required super.logicalSize,
    required super.homeWidgetKey,
    required super.utils,
  }) : super(
         formWidget: (key, theme, size, suffix) => _FakeHomeWidget(
           key: key,
           logicalSize: size,
           theme: theme,
           utils: utils,
           aditionalSuffix: suffix ?? '',
         ),
       );
}

void main() {
  group('FlutterHomeWidgetBuilder Tests', () {
    late MockHomeWidgetUtils mockUtils;
    late _TestBuilder builder;
    final lightTheme = ThemeData.light();
    final darkTheme = ThemeData.dark();
    const size = Size(100, 100);
    const baseKey = 'my_widget';

    setUp(() {
      mockUtils = MockHomeWidgetUtils();
      builder = _TestBuilder(
        lightTheme: lightTheme,
        darkTheme: darkTheme,
        logicalSize: size,
        homeWidgetKey: baseKey,
        utils: mockUtils,
      );

      when(
        mockUtils.renderFlutterWidget(
          any,
          key: anyNamed('key'),
          logicalSize: anyNamed('logicalSize'),
        ),
      ).thenAnswer((_) async => null);
    });

    test('getWidget returns correct theme and suffix', () {
      final darkWidget = builder.getWidget(
        isDark: true,
        aditionalSuffix: '_ext',
      );
      expect(darkWidget.theme, darkTheme);
      expect(darkWidget.aditionalSuffix, '_ext');

      final lightWidget = builder.getWidget(isDark: false);
      expect(lightWidget.theme, lightTheme);
      expect(lightWidget.aditionalSuffix, '');
    });

    test('renderFlutterWidgets calls utils twice with correct keys', () async {
      await builder.renderFlutterWidgets(additionalSuffix: '_v1');

      verify(
        mockUtils.renderFlutterWidget(
          argThat(predicate((_FakeHomeWidget w) => w.theme == darkTheme)),
          key: '${baseKey}_v1${HomeWidgetUtils.keySuffixDark}',
          logicalSize: size,
        ),
      ).called(1);

      verify(
        mockUtils.renderFlutterWidget(
          argThat(predicate((_FakeHomeWidget w) => w.theme == lightTheme)),
          key: '${baseKey}_v1${HomeWidgetUtils.keySuffixLight}',
          logicalSize: size,
        ),
      ).called(1);
    });

    test(
      'renderFlutterWidgets works correctly with empty additionalSuffix',
      () async {
        await builder.renderFlutterWidgets();

        verify(
          mockUtils.renderFlutterWidget(
            any,
            key: '$baseKey${HomeWidgetUtils.keySuffixDark}',
            logicalSize: size,
          ),
        ).called(1);
        verify(
          mockUtils.renderFlutterWidget(
            any,
            key: '$baseKey${HomeWidgetUtils.keySuffixLight}',
            logicalSize: size,
          ),
        ).called(1);
      },
    );

    test(
      'renderFlutterWidgets propagates errors from HomeWidgetUtils',
      () async {
        when(
          mockUtils.renderFlutterWidget(
            any,
            key: anyNamed('key'),
            logicalSize: anyNamed('logicalSize'),
          ),
        ).thenThrow(Exception('Native Render Error'));

        expect(() => builder.renderFlutterWidgets(), throwsException);
      },
    );

    test('getWidget isDark toggle strictly returns correct theme', () {
      final light = builder.getWidget(isDark: false);
      final dark = builder.getWidget(isDark: true);

      expect(light.theme, lightTheme);
      expect(dark.theme, darkTheme);
      expect(light.theme, isNot(dark.theme));
    });

    test('logicalSize is correctly passed to renderFlutterWidget', () async {
      const customSize = Size(500, 200);
      final customBuilder = _TestBuilder(
        lightTheme: lightTheme,
        darkTheme: darkTheme,
        logicalSize: customSize,
        homeWidgetKey: 'size_test',
        utils: mockUtils,
      );

      await customBuilder.renderFlutterWidgets();

      verify(
        mockUtils.renderFlutterWidget(
          any,
          key: anyNamed('key'),
          logicalSize: customSize,
        ),
      ).called(2);
    });
  });
}
