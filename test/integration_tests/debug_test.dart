import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../tests_app_wrapper.dart';

void main() {
  testWidgets('Debug - SharedPreferences in FakeAsync', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = SharedPreferences.getInstance();
    print('SharedPreferences future type: ${prefs.runtimeType}');

    await tester.pump();
    final result = await prefs;
    print('SharedPreferences loaded: ${result != null}');
  });

  testWidgets('Debug - EasyDynamicThemeWidget child rendering', (tester) async {
    await setupMocks();
    await tester.pumpWidget(
      MaterialApp(
        home: EasyDynamicThemeWidget(
          child: Builder(builder: (context) {
            print('Builder inside EasyDynamicThemeWidget called!');
            return const Text('hello');
          }),
        ),
      ),
    );
    print('=== After pumpWidget ===');
    print('Text hello found: ${find.text("hello").evaluate().length}');
    
    await tester.pump();
    print('=== After 1 pump ===');
    print('Text hello found: ${find.text("hello").evaluate().length}');
    
    await tester.pump(const Duration(seconds: 1));
    print('=== After 1s pump ===');
    print('Text hello found: ${find.text("hello").evaluate().length}');
  });
}
