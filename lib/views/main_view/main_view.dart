import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacyidea_authenticator/model/states/app_state.dart';
import 'package:privacyidea_authenticator/utils/riverpod_providers.dart';
import 'package:privacyidea_authenticator/utils/appCustomizer.dart';
import 'package:privacyidea_authenticator/views/add_token_manually_view/add_token_manually_view.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/main_view_body.dart';
import 'package:privacyidea_authenticator/views/onboarding_view/onboarding_view.dart';
import 'package:privacyidea_authenticator/views/qr_scanner_view/scanner_view.dart';
import 'package:privacyidea_authenticator/views/settings_view/settings_view.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/app_bar_item.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/custom_paint_app_bar.dart';
import 'dart:async';
import 'dart:convert';

import 'package:base32/base32.dart';
import 'package:collection/collection.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterlifecyclehooks/flutterlifecyclehooks.dart';
import 'package:pi_authenticator_legacy/pi_authenticator_legacy.dart';
import 'package:privacyidea_authenticator/utils/appCustomizer.dart';
import 'package:privacyidea_authenticator/utils/crypto_utils.dart';
import 'package:privacyidea_authenticator/utils/identifiers.dart';
import 'package:privacyidea_authenticator/utils/license_utils.dart';
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/utils/parsing_utils.dart';
import 'package:privacyidea_authenticator/utils/push_provider.dart';
import 'package:privacyidea_authenticator/utils/storage_utils.dart';
import 'package:privacyidea_authenticator/utils/utils.dart';
import 'package:privacyidea_authenticator/widgets/two_step_dialog.dart';
import 'package:uni_links/uni_links.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:privacyidea_authenticator/views/main_view/main_view_widgets/no_token_screen.dart';

class MainView extends ConsumerStatefulWidget {
  static const routeName = '/';

  final _title;

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
    final tokenList = ref.watch(tokenProvider);
    final Size size = MediaQuery.of(context).size;

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
      body: Container(
        width: size.width,
        height: size.height,
        child: Stack(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          children: [
            tokenList.isEmpty ? NoTokenScreen() : MainViewBody(tokenList),
            Positioned(
              child: Container(
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
                          /// Open the QR-code scanner and call `_handleOtpAuth`, with the scanned
                          /// code as the argument.

                          final qrCode = await Navigator.push<String?>(context, MaterialPageRoute(builder: (context) => QRScannerView()));
                          if (qrCode != null) ref.read(tokenProvider.notifier).addTokenFromOtpAuth(otpAuth: qrCode, context: context);
                        },
                        tooltip: AppLocalizations.of(context)!.scanQrCode,
                        child: Icon(Icons.qr_code_scanner_outlined),
                      ),
                    ),
                    Container(
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
                                    applicationVersion: ref.read(platformInfoProvider).appVersion,
                                  ), //TODO: Test this
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
              bottom: 0,
              left: 0,
            ),
          ],
        ),
      ),
    );
  }
}
