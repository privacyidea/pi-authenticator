/*
 * privacyIDEA Authenticator
 *
 * Author: Krzysztof Wielgosz <14099566+frankii91@users.noreply.github.com>
 *
 * Copyright (c) 2026 Krzysztof Wielgosz
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/globals.dart';
import '../../utils/logger.dart';

enum ImmediateUpdateAvailability { unavailable, available, inProgress }

abstract interface class ImmediateUpdateClient {
  Future<ImmediateUpdateAvailability> checkAvailability();

  Future<void> performImmediateUpdate();
}

class PlayImmediateUpdateClient implements ImmediateUpdateClient {
  const PlayImmediateUpdateClient();

  @override
  Future<ImmediateUpdateAvailability> checkAvailability() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return ImmediateUpdateAvailability.unavailable;
    }

    final updateInfo = await InAppUpdate.checkForUpdate();
    if (updateInfo.updateAvailability ==
        UpdateAvailability.developerTriggeredUpdateInProgress) {
      return ImmediateUpdateAvailability.inProgress;
    }
    if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable &&
        updateInfo.immediateUpdateAllowed) {
      return ImmediateUpdateAvailability.available;
    }
    return ImmediateUpdateAvailability.unavailable;
  }

  @override
  Future<void> performImmediateUpdate() async {
    await InAppUpdate.performImmediateUpdate();
  }
}

class ImmediateUpdateGate extends StatefulWidget {
  static const updateButtonKey = Key('immediate-update');

  final Widget child;
  final ImmediateUpdateClient client;
  final GlobalKey<NavigatorState>? navigatorKey;

  const ImmediateUpdateGate({
    required this.child,
    this.client = const PlayImmediateUpdateClient(),
    this.navigatorKey,
    super.key,
  });

  @override
  State<ImmediateUpdateGate> createState() => _ImmediateUpdateGateState();
}

class _ImmediateUpdateGateState extends State<ImmediateUpdateGate> {
  late final AppLifecycleListener _lifecycleListener;
  bool _checking = false;
  bool _promptHandledForSession = false;
  bool _startingUpdate = false;

  GlobalKey<NavigatorState> get _navigatorKey =>
      widget.navigatorKey ?? globalNavigatorKey;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(onResume: _checkForUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  Future<void> _checkForUpdate() async {
    if (!mounted || _checking) return;

    _checking = true;
    try {
      final availability = await widget.client.checkAvailability();
      if (!mounted) return;

      if (availability == ImmediateUpdateAvailability.inProgress) {
        await _startImmediateUpdate();
        return;
      }
      if (availability != ImmediateUpdateAvailability.available ||
          _promptHandledForSession) {
        return;
      }

      final navigatorContext = _navigatorKey.currentContext;
      if (navigatorContext == null || !navigatorContext.mounted) return;

      _promptHandledForSession = true;
      await showDialog<void>(
        context: navigatorContext,
        barrierDismissible: false,
        builder: (dialogContext) {
          final localizations = AppLocalizations.of(dialogContext)!;
          return PopScope(
            canPop: false,
            child: AlertDialog(
              title: Text(localizations.updateRequired),
              actions: [
                FilledButton(
                  key: ImmediateUpdateGate.updateButtonKey,
                  onPressed: _startImmediateUpdate,
                  child: Text(localizations.updateNow),
                ),
              ],
            ),
          );
        },
      );
    } catch (error, stackTrace) {
      Logger.warning(
        'Could not check or start the Google Play in-app update.',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _checking = false;
    }
  }

  Future<void> _startImmediateUpdate() async {
    if (_startingUpdate) return;

    _startingUpdate = true;
    try {
      await widget.client.performImmediateUpdate();
    } catch (error, stackTrace) {
      Logger.warning(
        'Could not start the Google Play in-app update.',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _startingUpdate = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
