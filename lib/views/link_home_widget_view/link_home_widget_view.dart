import 'package:app_minimizer/app_minimizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/app_customizer.dart';
import '../../utils/home_widget_utils.dart';
import '../../utils/riverpod_providers.dart';
import '../../utils/utils.dart';
import '../view_interface.dart';

class LinkHomeWidgetView extends ConsumerStatefulView {
  @override
  RouteSettings get routeSettings => const RouteSettings(name: routeName);

  static const routeName = '/link_home_widget';

  final String homeWidgetId;

  const LinkHomeWidgetView({super.key, required this.homeWidgetId});

  @override
  ConsumerState<LinkHomeWidgetView> createState() => _LinkHomeWidgetViewState();
}

class _LinkHomeWidgetViewState extends ConsumerState<LinkHomeWidgetView> {
  bool alreadyTapped = false;
  @override
  Widget build(BuildContext context) {
    final veilingCharacter = Theme.of(context).extension<ExtendedTextTheme>()?.veilingCharacter ?? '●';
    final otpTokens = ref.watch(tokenProvider).otpTokens;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Home Widget'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final otpToken = otpTokens[index];
          final folderIsLocked = ref.watch(tokenFolderProvider).getFolderById(otpToken.folderId)?.isLocked ?? false;
          final otpString = otpToken.isLocked || folderIsLocked ? veilingCharacter * otpToken.otpValue.length : otpToken.otpValue;
          return ListTile(
            title: Text(otpToken.label),
            subtitle: Text(insertCharAt(otpString, ' ', (otpString.length / 2).ceil())),
            onTap: alreadyTapped
                ? () {}
                : () async {
                    if (alreadyTapped) return;
                    setState(() => alreadyTapped = true);
                    await HomeWidgetUtils().link(widget.homeWidgetId, otpToken.id);
                    await FlutterAppMinimizer.minimize();
                    await Future.delayed(const Duration(milliseconds: 500));
                    if (context.mounted) Navigator.pop(context);
                  },
          );
        },
        itemCount: otpTokens.length,
      ),
    );
  }
}
