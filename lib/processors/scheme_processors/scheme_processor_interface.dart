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
import 'package:privacyidea_authenticator/model/processor_result.dart';

import '../../utils/logger.dart';
import 'home_widget_processor.dart';
import 'navigation_scheme_processors/navigation_scheme_processor_interface.dart';
import 'token_container_processor.dart';
import 'token_import_scheme_processors/token_import_scheme_processor_interface.dart';

/// On new impelementations, add them to the [SchemeProcessor.implementations] list
abstract class SchemeProcessor {
  const SchemeProcessor();
  Set<String> get supportedSchemes;
  Future<List<ProcessorResult<dynamic>>?> processUri(Uri uri, {bool fromInit = false});

  static final List<SchemeProcessor> implementations = [
    const HomeWidgetProcessor(),
    ...NavigationSchemeProcessor.implementations,
    ...TokenImportSchemeProcessor.implementations,
    const TokenContainerProcessor(),
  ];
  static Future<List<ProcessorResult<dynamic>>?> processUriByAny(Uri uri, {bool fromInit = false}) async {
    for (SchemeProcessor processor in implementations) {
      if (processor.supportedSchemes.contains(uri.scheme)) {
        Logger.info('Processing URI with processor: $processor');
        final result = await processor.processUri(uri, fromInit: fromInit);
        if (result != null) {
          return result;
        }
      }
    }
    Logger.warning('Unsupported scheme');
    return null;
  }
}
