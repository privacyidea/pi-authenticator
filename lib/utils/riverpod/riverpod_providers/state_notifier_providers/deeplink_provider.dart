import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/deeplink.dart';
import '../../state_notifiers/deeplink_notifier.dart';
import '../../../home_widget_utils.dart';
import '../../../logger.dart';

final deeplinkProvider = StateNotifierProvider<DeeplinkNotifier, DeepLink?>(
  (ref) {
    Logger.info("New DeeplinkNotifier created", name: 'deeplinkProvider');
    return DeeplinkNotifier(sources: [
      DeeplinkSource(name: 'uni_links', stream: AppLinks().uriLinkStream, initialUri: AppLinks().getInitialLink()),
      DeeplinkSource(
        name: 'home_widget',
        stream: HomeWidgetUtils().widgetClicked,
        initialUri: HomeWidgetUtils().initiallyLaunchedFromHomeWidget(),
      ),
    ]);
  },
  name: 'deeplinkProvider',
);
