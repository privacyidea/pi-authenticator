import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/app_customizer.dart';
import '../../../utils/riverpod_providers.dart';
import '../../add_token_manually_view/add_token_manually_view.dart';
import '../../qr_scanner_view/scanner_view.dart';
import '../../settings_view/settings_view.dart';
import '../add_token_folder_dialog.dart';
import 'app_bar_item.dart';
import 'custom_paint_navigation_bar.dart';

class MainViewNavigationButtions extends StatelessWidget {
  const MainViewNavigationButtions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final navWidth = size.width;
    final navHeight = size.height * 0.10;
    return Positioned(
      bottom: 0,
      left: 0,
      child: SizedBox(
        width: navWidth,
        height: navHeight,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(
                navWidth,
                navHeight,
              ),
              painter: CustomPaintNavigationBar(buildContext: context),
            ),
            Center(
              heightFactor: 0.6,
              child: FloatingActionButton(
                onPressed: () {
                  /// Open the QR-code scanner and call `_handleOtpAuth`, with the scanned code as the argument.
                  Navigator.pushNamed(context, QRScannerView.routeName).then((qrCode) {
                    if (qrCode != null) globalRef?.read(tokenProvider.notifier).addTokenFromOtpAuth(otpAuth: qrCode as String, context: context);
                  });
                },
                tooltip: AppLocalizations.of(context)!.scanQrCode,
                child: const Icon(Icons.qr_code_scanner_outlined),
              ),
            ),
            SizedBox(
              width: navWidth,
              height: navHeight * 0.9,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppBarItem(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LicensePage(
                            applicationName: ApplicationCustomizer.appName,
                            applicationIcon: Image.asset(
                              ApplicationCustomizer.appIcon,
                              height: size.height * 0.3,
                            ),
                            applicationLegalese: ApplicationCustomizer.websiteLink,
                            applicationVersion: '${globalRef?.read(platformInfoProvider).appVersion}+${globalRef?.read(platformInfoProvider).buildNumber}',
                          ),
                        ),
                      );
                    },
                    icon: Icons.info_outline,
                  ),
                  SizedBox(
                    height: navHeight * 0.9,
                    child: AppBarItem(
                      onPressed: () {
                        Navigator.pushNamed(context, AddTokenManuallyView.routeName);
                      },
                      icon: Icons.add_moderator,
                    ),
                  ),
                  SizedBox(width: navWidth * 0.2),
                  SizedBox(
                    height: navHeight * 0.9,
                    child: AppBarItem(
                      onPressed: () {
                        showDialog(context: context, builder: (context) => AddTokenFolderDialog());
                      },
                      icon: Icons.create_new_folder,
                    ),
                  ),
                  AppBarItem(
                      onPressed: () {
                        Navigator.pushNamed(context, SettingsView.routeName);
                      },
                      icon: Icons.settings),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
