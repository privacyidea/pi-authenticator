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

import '../../../model/processor_result.dart';
import '../../../utils/globals.dart';
import '../../../utils/home_widget_utils.dart';
import '../../../utils/identifiers.dart';
import '../../../utils/logger.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_folder_notifier.dart';
import '../../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../../../views/link_home_widget_view/link_home_widget_view.dart';
import 'navigation_scheme_processor_interface.dart';

class HomeWidgetNavigateProcessor implements NavigationSchemeProcessor {
  static const resultHandlerType = TypeMatcher<NavigationHandler>();
  HomeWidgetNavigateProcessor();

  static final Map<String, Future<List<ProcessorResult<dynamic>>?> Function(Uri, BuildContext, {bool fromInit})> _processors = {
    'link': _linkHomeWidgetProcessor,
    'showlocked': _showLockedHomeWidgetProcessor,
  };

  @override
  Future<List<ProcessorResult<dynamic>>?> processUri(Uri uri, {BuildContext? context, bool fromInit = false}) async {
    if (context == null) {
      Logger.error(
        'HomeWidgetNavigateProcessor: Cannot Navigate without context',
        error: Exception('context is null'),
        stackTrace: StackTrace.current,
      );
      return [
        const ProcessorResult.failed(
          'Cannot Navigate without context',
          resultHandlerType: resultHandlerType,
        )
      ];
    }
    Logger.warning('HomeWidgetNavigateProcessor: Processing uri: $uri');
    final processor = _processors[uri.host];
    if (processor == null) {
      Logger.warning('HomeWidgetNavigateProcessor: No processor found for host: ${uri.host}');
      return [
        ProcessorResult.failed(
          'No processor found for host: ${uri.host}',
          resultHandlerType: resultHandlerType,
        )
      ];
    }
    return processor.call(uri, context, fromInit: fromInit);
  }

  @override
  Set<String> get supportedSchemes => {'homewidgetnavigate'};

  static Future<List<ProcessorResult<dynamic>>?> _linkHomeWidgetProcessor(Uri uri, BuildContext context, {bool fromInit = false}) async {
    if (uri.host != 'link') {
      Logger.warning('HomeWidgetNavigateProcessor: Invalid host for link: ${uri.host}');
      return [];
    }
    if (uri.queryParameters['id'] == null) {
      Logger.warning('HomeWidgetNavigateProcessor: Missing id for link: ${uri.host}');
      return [
        ProcessorResult.failed(
          'Missing id for link: ${uri.host}',
          resultHandlerType: resultHandlerType,
        )
      ];
    }
    if (fromInit) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => LinkHomeWidgetView(homeWidgetId: uri.queryParameters['id']!)),
      );
    } else {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => LinkHomeWidgetView(homeWidgetId: uri.queryParameters['id']!)),
      );
    }
    return null;
  }

  static Future<List<ProcessorResult<dynamic>>?> _showLockedHomeWidgetProcessor(Uri uri, BuildContext context, {bool fromInit = false}) async {
    if (uri.host != 'showlocked') {
      Logger.warning('Invalid host for showlocked: ${uri.host}', name: 'home_widget_processor.dart#_showLockedHomeWidgetProcessor');
      return [];
    }
    if (uri.queryParameters['id'] == null) {
      Logger.warning('Invalid query parameters for showlocked: ${uri.queryParameters}', name: 'home_widget_processor.dart#_showLockedHomeWidgetProcessor');
      return [
        ProcessorResult.failed(
          'Missing id for showlocked: ${uri.host}',
          resultHandlerType: resultHandlerType,
        )
      ];
    }
    Logger.info('Showing otp of locked Token of homeWidget: ${uri.queryParameters['id']}', name: 'home_widget_processor.dart#_showLockedHomeWidgetProcessor');
    Navigator.popUntil(context, (route) => route.isFirst);

    final tokenId = await HomeWidgetUtils().getTokenIdOfWidgetId(uri.queryParameters['id']!);
    if (tokenId == null) {
      Logger.warning('Could not find token for widget id: ${uri.queryParameters['id']}', name: 'home_widget_processor.dart#_showLockedHomeWidgetProcessor');
      return [
        ProcessorResult.failed(
          'Could not find token for widget id: ${uri.queryParameters['id}']}',
          resultHandlerType: resultHandlerType,
        )
      ];
    }
    await Future.delayed(const Duration(milliseconds: 200));
    if (globalRef == null) {
      Logger.warning('Could not find globalRef', name: 'home_widget_processor.dart#_showLockedHomeWidgetProcessor');
      return [
        const ProcessorResult.failed(
          'Could not find globalRef',
          resultHandlerType: resultHandlerType,
        )
      ];
    }
    final showedToken = await globalRef!.read(tokenProvider.notifier).showTokenById(tokenId);

    if (showedToken?.isHidden == false) {
      final folderId = globalRef!.read(tokenProvider).currentOfId(tokenId)?.folderId;
      if (folderId != null) {
        globalRef!.read(tokenFolderProvider.notifier).expandFolderById(folderId);
      }
    }
    return null;
  }
}

class NavigationHandler<R> with ResultHandler {
  @override
  Future<R?> handleProcessorResult(ProcessorResult result, Map<String, dynamic> args) async {
    if (result is! ProcessorResult<Navigation>) return null;
    if (result.isFailed) return null;
    validateMap(args, {'context': const TypeMatcher<BuildContext>()});
    final navigation = result.asSuccess!.resultData;
    final BuildContext context = args['context'];
    return await navigation(context);
  }

  @override
  Future<List<R>?> handleProcessorResults(List<ProcessorResult> results, Map<String, dynamic> args) async {
    final successResults = results.whereType<ProcessorResult<Navigation>>().toList().successResults;
    if (successResults.isEmpty) return null;
    validateMap(args, {'context': const TypeMatcher<BuildContext>()});
    List<Navigation> navigations = successResults.getData();
    final context = args['context'];
    final retunValues = <R>[];
    for (final navigation in navigations) {
      retunValues.add(await navigation(context));
    }
    return retunValues;
  }
}

typedef Navigation = Future<R> Function<R>(BuildContext context);
