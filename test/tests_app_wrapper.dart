import 'dart:math';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:privacyidea_authenticator/interfaces/repo/settings_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_folder_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/utils/firebase_utils.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/network_utils.dart';
import 'package:privacyidea_authenticator/utils/qr_parser.dart';
import 'package:privacyidea_authenticator/utils/rsa_utils.dart';

@GenerateNiceMocks([
  MockSpec<TokenRepository>(),
  MockSpec<SettingsRepository>(),
  MockSpec<TokenFolderRepository>(),
  MockSpec<PrivacyIdeaIOClient>(),
  MockSpec<QrParser>(),
  MockSpec<RsaUtils>(),
  MockSpec<FirebaseUtils>(),
])
class TestsAppWrapper extends StatelessWidget {
  final Widget child;
  final List<Override> overrides;

  const TestsAppWrapper({Key? key, required this.child, this.overrides = const []}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: EasyDynamicThemeWidget(child: child),
    );
  }
}

Future<void> waitFor(Duration duration, WidgetTester tester) async {
  var lastFrameTime = DateTime.now();
  Logger.info('Waiting for ${duration.inMilliseconds} milliseconds');
  while (duration.inMilliseconds > 0) {
    final millisecondsSinceLastFrame = DateTime.now().difference(lastFrameTime).inMilliseconds;
    await tester.pump(Duration(milliseconds: max(1, 33 - millisecondsSinceLastFrame)));
    duration -= DateTime.now().difference(lastFrameTime);
    lastFrameTime = DateTime.now();
  }
}
