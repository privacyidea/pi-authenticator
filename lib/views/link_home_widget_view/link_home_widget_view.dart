import 'package:app_minimizer/app_minimizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/utils/home_widget_utils.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';

class LinkHomeWidgetView extends ConsumerWidget {
  final String homeWidgetId;

  const LinkHomeWidgetView({Key? key, required this.homeWidgetId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpTokens = ref.watch(tokenProvider).otpTokens;
    return Scaffold(
      appBar: AppBar(
        title: Text('Link Home Widget'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final otpToken = otpTokens[index];
          final otpString = otpToken.isLocked ? ''.padRight(otpToken.otpValue.length, '-') : otpToken.otpValue;
          return ListTile(
            title: Text(otpToken.label),
            subtitle: Text(splitPeriodically(otpString, otpString.length ~/ 2)),
            onTap: () async {
              HomeWidgetUtils.link(homeWidgetId, otpToken.id);
              FlutterAppMinimizer.minimize();
              Navigator.pop(context);
            },
          );
        },
        itemCount: otpTokens.length,
      ),
    );
  }
}
