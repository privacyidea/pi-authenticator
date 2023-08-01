import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/app_customizer.dart';
import '../../../utils/riverpod_providers.dart';
import '../../add_token_manually_view/add_token_manually_view.dart';
import '../../qr_scanner_view/scanner_view.dart';
import '../../settings_view/settings_view.dart';
import 'app_bar_item.dart';
import 'custom_paint_app_bar.dart';

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
                      showDialog(context: context, builder: (context) => AddTokenCategoryDialog());
                    },
                    icon: Icons.create_new_folder,
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

class AddTokenCategoryDialog extends ConsumerWidget {
  final textController = TextEditingController();

  AddTokenCategoryDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        title: const Text('Add a new category'),
        content: TextFormField(
          controller: textController,
          autofocus: true,
          onChanged: (value) {},
          decoration: const InputDecoration(labelText: 'Category name'),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Category name';
            }
            return null;
          },
        ),
        actions: <Widget>[
          TextButton(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
              child: Text(AppLocalizations.of(context)!.save),
              onPressed: () {
                ref.read(tokenCategoryProvider.notifier).addCategory(textController.text);
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }
}
