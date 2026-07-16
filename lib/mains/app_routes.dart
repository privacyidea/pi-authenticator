/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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

import '../model/enums/app_feature.dart';
import '../utils/customization/application_customization.dart';
import '../views/add_token_manually_view/add_token_manually_view.dart';
import '../views/container_view/container_view.dart';
import '../views/feedback_view/feedback_view.dart';
import '../views/import_tokens_view/import_tokens_view.dart';
import '../views/license_view/license_view.dart';
import '../views/main_view/main_view.dart';
import '../views/push_token_view/push_tokens_view.dart';
import '../views/qr_scanner_view/qr_scanner_view.dart';
import '../views/settings_view/settings_view.dart';
import '../views/splash_screen/splash_screen.dart';

Map<String, WidgetBuilder> buildAppRoutes(
  ApplicationCustomization customization, {
  bool includeContainerView = false,
}) => {
  AddTokenManuallyView.routeName: (context) => const AddTokenManuallyView(),
  FeedbackView.routeName: (context) => const FeedbackView(),
  ImportTokensView.routeName: (context) => const ImportTokensView(),
  LicenseView.routeName: (context) => LicenseView(
    appImage:
        customization.licensesViewImage?.getWidget ??
        customization.splashScreenImage.getWidget,
    appName: customization.appName,
    websiteLink: customization.websiteLink,
  ),
  MainView.routeName: (context) => MainView(
    appbarIcon: customization.appbarIcon.getWidget,
    backgroundImage: customization.backgroundImage?.getWidget,
    appName: customization.appName,
    disablePatchNotes: customization.disabledFeatures.contains(
      AppFeature.patchNotes,
    ),
  ),
  PushTokensView.routeName: (context) => const PushTokensView(),
  SettingsView.routeName: (context) => const SettingsView(),
  SplashScreen.routeName: (context) =>
      SplashScreen(customization: customization),
  QRScannerView.routeName: (context) => const QRScannerView(),
  if (includeContainerView)
    ContainerView.routeName: (context) => const ContainerView(),
};
