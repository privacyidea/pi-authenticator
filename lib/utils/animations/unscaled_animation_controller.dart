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
import 'dart:async' show Timer;

import 'package:flutter/material.dart' show Animation, AnimationStatus, AnimationStatusListener, VoidCallback;

class UnscaledAnimationController extends Animation<double> {
  static const double _refreshRate = 30; // FPS
  static const double _refreshInterval = 1 / _refreshRate;

  final Duration duration;
  final double lowerBound;
  final double upperBound;
  @override
  AnimationStatus status = AnimationStatus.dismissed;
  @override
  double value;
  Timer? _timer;

  final List<VoidCallback> _listeners = [];
  final List<AnimationStatusListener> _statusListeners = [];

  UnscaledAnimationController({
    required this.duration,
    this.lowerBound = 0,
    this.upperBound = 1,
  })  : assert(lowerBound < upperBound, 'lowerBound must be less than upperBound'),
        assert(duration.inMicroseconds > 0, 'duration must be greater than 0'),
        value = lowerBound;

  void _setStatus(AnimationStatus newStatus) {
    if (status == newStatus) return;
    status = newStatus;
    for (var statusListener in _statusListeners) {
      statusListener(status);
    }
  }

  void _setValue(double newValue) {
    newValue = newValue.clamp(lowerBound, upperBound);
    if (newValue == value) return;
    value = newValue;
    for (var listener in _listeners) {
      listener();
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
    value = lowerBound;
    _listeners.clear();
    _statusListeners.clear();
  }

  void forward({double? from}) {
    if (from != null) _setValue(from);
    _setStatus(AnimationStatus.forward);
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: (_refreshInterval * 1000).toInt()), (timer) {
      final newValue = value + _refreshInterval * (upperBound - lowerBound) / duration.inSeconds;
      if (value >= upperBound) {
        _setValue(upperBound);
        timer.cancel();
        _setStatus(AnimationStatus.completed);
      } else {
        _setValue(newValue);
      }
    });
  }

  void reverse({double? from}) {
    if (from != null) _setValue(from);
    _setStatus(AnimationStatus.reverse);
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: (_refreshInterval * 1000).toInt()), (timer) {
      final newValue = value + _refreshInterval * (upperBound - lowerBound) / duration.inSeconds;
      if (value <= lowerBound) {
        _setValue(lowerBound);
        timer.cancel();
        _setStatus(AnimationStatus.dismissed);
      } else {
        _setValue(newValue);
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _setValue(lowerBound);
    _setStatus(AnimationStatus.dismissed);
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  @override
  void addStatusListener(AnimationStatusListener listener) {
    _statusListeners.add(listener);
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
    _statusListeners.remove(listener);
  }
}
