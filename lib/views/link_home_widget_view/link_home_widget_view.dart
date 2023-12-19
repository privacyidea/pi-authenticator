import 'package:app_minimizer/app_minimizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/app_customizer.dart';
import '../../utils/home_widget_utils.dart';
import '../../utils/riverpod_providers.dart';
import '../../utils/utils.dart';

class LinkHomeWidgetView extends ConsumerWidget {
  final String homeWidgetId;

  const LinkHomeWidgetView({super.key, required this.homeWidgetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpTokens = ref.watch(tokenProvider).otpTokens;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Home Widget'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final otpToken = otpTokens[index];
          final veilingCharacter = Theme.of(context).extension<ExtendedTextTheme>()?.veilingCharacter ?? '●';
          final otpString = otpToken.isLocked ? veilingCharacter * otpToken.otpValue.length : otpToken.otpValue;
          return ListTile(
            title: Text(otpToken.label),
            subtitle: Text(splitPeriodically(otpString, otpString.length ~/ 2)),
            onTap: () async {
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
