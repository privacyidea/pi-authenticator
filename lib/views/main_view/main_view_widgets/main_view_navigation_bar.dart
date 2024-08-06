/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/enums/introduction.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/introduction_provider.dart';
import '../../../utils/riverpod/riverpod_providers/state_providers/app_constraints_provider.dart';
import '../../../widgets/focused_item_as_overlay.dart';
import '../../add_token_manually_view/add_token_manually_view.dart';
import '../../settings_view/settings_view.dart';
import 'app_bar_item.dart';
import 'custom_paint_navigation_bar.dart';
import 'folder_widgets/add_token_folder_dialog.dart';
import 'main_view_navigation_buttons/license_push_view_button.dart';
import 'main_view_navigation_buttons/qr_scanner_button.dart';

class MainViewNavigationBar extends ConsumerWidget {
  const MainViewNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    BoxConstraints? constraints = ref.watch(appConstraintsProvider);
    final introProv = ref.watch(introductionNotifierProvider);
    constraints ??= const BoxConstraints();
    final navWidth = constraints.maxWidth;
    final navHeight = constraints.maxHeight * 0.10;
    return SizedBox(
      width: constraints.maxWidth,
      height: constraints.maxHeight,
      child: Column(
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
                  child: FocusedItemAsOverlay(
                      onComplete: () {
                        ref.read(introductionNotifierProvider.notifier).complete(Introduction.scanQrCode);
                      },
                      isFocused: introProv.whenOrNull(data: (data) => data.isConditionFulfilled(ref, Introduction.scanQrCode)) ?? false,
                      tooltipWhenFocused: AppLocalizations.of(context)!.introScanQrCode,
                      child: const QrScannerButton()),
                ),
                Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: navHeight * 0.2, bottom: navHeight * 0.1),
                            child: const LicensePushViewButton(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: navHeight * 0.1, bottom: navHeight * 0.2),
                            child: AppBarItem(
                              tooltip: AppLocalizations.of(context)!.addTokenManually,
                              onPressed: () {
                                Navigator.pushNamed(context, AddTokenManuallyView.routeName);
                              },
                              icon: FocusedItemAsOverlay(
                                onComplete: () => ref.read(introductionNotifierProvider.notifier).complete(Introduction.addManually),
                                isFocused: introProv.whenOrNull(data: (data) => data.isConditionFulfilled(ref, Introduction.addManually)) ?? false,
                                tooltipWhenFocused: AppLocalizations.of(context)!.introAddTokenManually,
                                child: FittedBox(
                                  child: Icon(
                                    Icons.add_moderator,
                                    color: Theme.of(context).navigationBarTheme.iconTheme?.resolve({})?.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: navHeight * 0.1, bottom: navHeight * 0.2),
                            child: FocusedItemAsOverlay(
                              isFocused: introProv.whenOrNull(data: (data) => data.isConditionFulfilled(ref, Introduction.addFolder)) ?? false,
                              tooltipWhenFocused: AppLocalizations.of(context)!.introAddFolder,
                              onComplete: () => ref.read(introductionNotifierProvider.notifier).complete(Introduction.addFolder),
                              child: AppBarItem(
                                tooltip: AppLocalizations.of(context)!.addFolder,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AddTokenFolderDialog(),
                                    useRootNavigator: false,
                                  );
                                },
                                icon: FittedBox(
                                  child: Icon(
                                    Icons.create_new_folder,
                                    color: Theme.of(context).navigationBarTheme.iconTheme?.resolve({})?.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: navHeight * 0.2, bottom: navHeight * 0.1),
                            child: AppBarItem(
                              tooltip: AppLocalizations.of(context)!.settings,
                              onPressed: () {
                                Navigator.pushNamed(context, SettingsView.routeName);
                              },
                              icon: const FittedBox(
                                child: Icon(Icons.settings),
                              ),
                            ),
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
      ),
    );
  }
}
