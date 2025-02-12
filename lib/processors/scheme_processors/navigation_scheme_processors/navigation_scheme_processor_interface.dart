/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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

import '../../../model/processor_result.dart';
import '../../../utils/globals.dart';
import '../../../utils/logger.dart';
import '../scheme_processor_interface.dart';
import 'home_widget_navigate_processor.dart';

abstract class NavigationSchemeProcessor implements SchemeProcessor {
  const NavigationSchemeProcessor();

  static Set<NavigationSchemeProcessor> implementations = {
    HomeWidgetNavigateProcessor(),
  };

  @override
  Future<List<ProcessorResult<dynamic>>?> processUri(Uri uri, {BuildContext? context, bool fromInit = false});

  static Future<void> processUriByAny(Uri uri, {BuildContext? context, required bool fromInit}) async {
    if (context == null) {
      Logger.info('Current context is null, waiting for navigator context');
      final key = await contextedGlobalNavigatorKey;
      context = key.currentContext;
    }
    Logger.info('Processing scheme: ${uri.scheme}');
    final futures = <Future<void>>[];
    for (final processor in implementations) {
      Logger.info('Supported schemes [${processor.supportedSchemes}] for processor ${processor.runtimeType}');
      if (processor.supportedSchemes.contains(uri.scheme)) {
        Logger.info('Processing scheme ${uri.scheme} with ${processor.runtimeType}');
        // ignoring use_build_context_synchronously is ok because we got the context after the await. The Context cannot be expired.
        // ignore: use_build_context_synchronously
        futures.add(processor.processUri(uri, context: context, fromInit: fromInit));
      }
    }
    await Future.wait(futures);
    return;
  }
}
