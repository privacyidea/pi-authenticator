import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';

import '../../model/states/app_state.dart';
import '../../utils/app_customizer.dart';
import '../../utils/riverpod_providers.dart';
import '../add_token_manually_view/add_token_manually_view.dart';
import '../onboarding_view/onboarding_view.dart';
import '../qr_scanner_view/scanner_view.dart';
import '../settings_view/settings_view.dart';
import 'main_view_widgets/app_bar_item.dart';
import 'main_view_widgets/custom_paint_app_bar.dart';
import 'main_view_widgets/main_view_tokens_list.dart';
import 'main_view_widgets/no_token_screen.dart';

class MainView extends ConsumerStatefulWidget {
  static const routeName = '/';

  final String _title;

  const MainView({Key? key, required String title})
      : _title = title,
        super(key: key);

  @override
  ConsumerState<MainView> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> with LifecycleMixin {
  @override
  void onResume() {
    globalRef?.read(appStateProvider.notifier).setAppState(AppState.resume);
  }

  @override
  void onPause() {
    globalRef?.read(appStateProvider.notifier).setAppState(AppState.pause);
  }

  @override
  Widget build(BuildContext context) {
    final tokenList = ref.watch(tokenProvider).tokens;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget._title,
          overflow: TextOverflow.ellipsis,
          // maxLines: 2 only works like this.
          maxLines: 2, // Title can be shown on small screens too.
        ),
        leading: Image.asset(ApplicationCustomizer.appIcon),
      ),
      extendBodyBehindAppBar: false,
      body: Stack(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          tokenList.isEmpty ? const NoTokenScreen() : MainViewTokensList(tokenList),
          const MainViewNavigationButtions(),
        ],
      ),
    );
  }
}

class MainViewNavigationButtions extends StatelessWidget {
  const MainViewNavigationButtions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      bottom: 0,
      left: 0,
      child: SizedBox(
        width: size.width,
        height: 80,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(size.width, 80),
              painter: CustomPaintAppBar(buildContext: context),
            ),
            Center(
              heightFactor: 0.6,
              child: FloatingActionButton(
                onPressed: () async {
                  /// Open the QR-code scanner and call `_handleOtpAuth`, with the scanned code as the argument.
                  final qrCode = await Navigator.push<String?>(context, MaterialPageRoute(builder: (context) => QRScannerView()));
                  if (qrCode != null) globalRef?.read(tokenProvider.notifier).addTokenFromOtpAuth(otpAuth: qrCode, context: context);
                },
                tooltip: AppLocalizations.of(context)!.scanQrCode,
                child: const Icon(Icons.qr_code_scanner_outlined),
              ),
            ),
            SizedBox(
              width: size.width,
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppBarItem(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LicensePage(
                            applicationName: ApplicationCustomizer.appName,
                            applicationIcon: Image.asset(ApplicationCustomizer.appIcon),
                            applicationLegalese: ApplicationCustomizer.websiteLink,
                            applicationVersion: globalRef?.read(platformInfoProvider).appVersion,
                          ),
                        ),
                      );
                    },
                    icon: Icons.info_outline,
                  ),
                  AppBarItem(
                    onPressed: () {
                      Navigator.pushNamed(context, AddTokenManuallyView.routeName);
                    },
                    icon: Icons.add_moderator,
                  ),
                  Container(
                    width: size.width * 0.20,
                  ),
                  AppBarItem(
                      onPressed: () {
                        Navigator.pushNamed(context, SettingsView.routeName);
                      },
                      icon: Icons.settings),
                  AppBarItem(
                    onPressed: () {
                      Navigator.pushNamed(context, OnboardingView.routeName);
                    },
                    icon: Icons.help_outline,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
