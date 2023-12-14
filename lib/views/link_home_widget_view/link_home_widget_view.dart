import 'package:app_minimizer/app_minimizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/globals.dart';
import '../../utils/home_widget_utils.dart';
import '../../utils/riverpod_providers.dart';
import '../../utils/utils.dart';

class LinkHomeWidgetView extends ConsumerWidget {
  final String homeWidgetId;
  static bool _buttonTapped = false;

  const LinkHomeWidgetView({super.key, required this.homeWidgetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LinkHomeWidgetView._buttonTapped = false;
    final otpTokens = ref.watch(tokenProvider).otpTokens;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Home Widget'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final otpToken = otpTokens[index];
          final otpString = otpToken.isLocked ? ''.padRight(otpToken.otpValue.length, veilingCharacter) : otpToken.otpValue;
          return ListTile(
            title: Text(otpToken.label),
            subtitle: Text(splitPeriodically(otpString, otpString.length ~/ 2)),
            onTap: () async {
              if (_buttonTapped) return;
              _buttonTapped = true;
              await HomeWidgetUtils().link(homeWidgetId, otpToken.id);
              await FlutterAppMinimizer.minimize();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          );
        },
        itemCount: otpTokens.length,
      ),
    );
  }
}
