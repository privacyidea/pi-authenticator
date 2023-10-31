import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/focused_item.dart';
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
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final navWidth = constraints.maxWidth;
          final navHeight = constraints.maxHeight * 0.10;
          const focusedItem = 2;
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
                    const Center(
                      heightFactor: 0.6,
                      child: FocusedItem(isFocused: true, tooltipWhenFocused: 'Scan a Token!', child: QrScannerButton()),
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
                                  onPressed: () {
                                    Navigator.pushNamed(context, AddTokenManuallyView.routeName);
                                  },
                                  icon: const FocusedItem(
                                    isFocused: focusedItem == 1,
                                    tooltipWhenFocused: 'Add token manually',
                                    child: FittedBox(
                                      child: Icon(Icons.add_moderator),
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
                                child: AppBarItem(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AddTokenFolderDialog(),
                                      useRootNavigator: false,
                                    );
                                  },
                                  icon: const FocusedItem(
                                    isFocused: focusedItem == 3,
                                    tooltipWhenFocused: 'Add folder',
                                    child: FittedBox(
                                      child: Icon(Icons.create_new_folder),
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
                                  onPressed: () {
                                    Navigator.pushNamed(context, SettingsView.routeName);
                                  },
                                  icon: const FocusedItem(
                                    isFocused: focusedItem == 4,
                                    tooltipWhenFocused: 'Nothing here!',
                                    child: FittedBox(
                                      child: Icon(Icons.settings),
                                    ),
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
          );
        },
      ),
    );
  }
}
