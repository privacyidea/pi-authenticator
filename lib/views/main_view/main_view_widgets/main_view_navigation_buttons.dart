import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:privacyidea_authenticator/utils/view_utils.dart';
import 'package:privacyidea_authenticator/views/push_token_view/push_tokens_view.dart';
import '../../../widgets/default_dialog.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/riverpod_providers.dart';
import '../../add_token_manually_view/add_token_manually_view.dart';
import '../../qr_scanner_view/qr_scanner_view.dart';
import '../../settings_view/settings_view.dart';
import 'folder_widgets/add_token_folder_dialog.dart';
import 'app_bar_item.dart';
import 'custom_paint_navigation_bar.dart';

class MainViewNavigationButtions extends ConsumerWidget {
  const MainViewNavigationButtions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final navWidth = constraints.maxWidth;
          final navHeight = constraints.maxHeight * 0.10;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
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
                        onPressed: () async {
                          if (await Permission.camera.isPermanentlyDenied) {
                            showAsyncDialog(
                              builder: (_) => DefaultDialog(
                                title: Text(AppLocalizations.of(context)!.grantCameraPermissionDialogTitle),
                                content: Text(AppLocalizations.of(context)!.grantCameraPermissionDialogPermanentlyDenied),
                              ),
                            );
                            return;
                          }

                          /// Open the QR-code scanner and call `_handleOtpAuth`, with the scanned code as the argument.
                          // ignore: use_build_context_synchronously
                          Navigator.pushNamed(context, QRScannerView.routeName).then((qrCode) {
                            if (qrCode != null) globalRef?.read(tokenProvider.notifier).addTokenFromOtpAuth(otpAuth: qrCode as String);
                          });
                        },
                        tooltip: AppLocalizations.of(context)?.scanQrCode ?? '',
                        child: const Icon(Icons.qr_code_scanner_outlined),
                      ),
                    ),
                    Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: EdgeInsets.only(top: navHeight * 0.2, bottom: navHeight * 0.1),
                                child: ref.watch(settingsProvider).hidePushTokens && ref.watch(tokenProvider).hasPushTokens
                                    ? AppBarItem(
                                        onPressed: () {
                                          Navigator.pushNamed(context, PushTokensView.routeName);
                                        },
                                        icon: Icons.notifications,
                                      )
                                    : const SizedBox(),
                              ),
                            ),
                          ),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: EdgeInsets.only(top: navHeight * 0.1, bottom: navHeight * 0.2),
                                child: AppBarItem(
                                  onPressed: () {
                                    Navigator.pushNamed(context, AddTokenManuallyView.routeName);
                                  },
                                  icon: Icons.add_moderator,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: min(110, navHeight * 0.8 + 30)),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: EdgeInsets.only(top: navHeight * 0.1, bottom: navHeight * 0.2),
                                child: AppBarItem(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AddTokenFolderDialog(),
                                      useRootNavigator: false,
                                    );
                                  },
                                  icon: Icons.create_new_folder,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: EdgeInsets.only(top: navHeight * 0.2, bottom: navHeight * 0.1),
                                child: AppBarItem(
                                    onPressed: () {
                                      Navigator.pushNamed(context, SettingsView.routeName);
                                    },
                                    icon: Icons.settings),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
