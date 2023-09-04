import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/settings_repository.dart';
import 'package:privacyidea_authenticator/interfaces/repo/token_folder_repository.dart';

@GenerateNiceMocks([MockSpec<TokenRepository>(), MockSpec<SettingsRepository>(), MockSpec<TokenFolderRepository>()])
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
