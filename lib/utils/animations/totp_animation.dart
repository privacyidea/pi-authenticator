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
 * distributed under the License is distributed on an 'A   IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'package:flutter/material.dart';
import 'package:privacyidea_authenticator/model/extensions/color_extension.dart';

class TotpAnimation {
  final BuildContext context;
  final TickerProvider vsync;
  final Function(TotpAnimationCallback) callback;
  final Function onPeriodEnd;
  final Color defaultColor;
  final Duration totalDuration;
  final Color warningColor;
  final Duration warningDuration;
  final Color criticalColor;
  final Duration criticalDuration;

  /// Creates a new animation that changes the color of a circle based on the time left.</br>
  /// The color will fade from [defaultColor] to [warningColor] for [warningDuration] before entering [criticalColor].</br>
  /// The color will fade from [warningColor] to [criticalColor] for [criticalDuration] before the period ends. Will fade from [defaultColor] to [criticalColor] if [warningDuration] is 0.
  TotpAnimation({
    required this.context,
    required this.vsync,
    required this.callback,
    required this.onPeriodEnd,
    required this.defaultColor,
    required this.totalDuration,
    this.warningColor = const Color(0xFFFFD3AC),
    this.warningDuration = const Duration(seconds: 0),
    required this.criticalColor,
    required this.criticalDuration,
  });

  DateTime lastResync = DateTime.now();

  /// The initial elapsed time is [initPassedTime].
  AnimationController createAnimation() {
    final colorAnimation = AnimationController(
      vsync: vsync,
      lowerBound: 0,
      upperBound: totalDuration.inSeconds.toDouble(),
      duration: totalDuration,
    );
    colorAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onPeriodEnd();
        colorAnimation.forward(from: DateTime.now().millisecondsSinceEpoch % (totalDuration.inMilliseconds) / 1000);
      }
    });
    colorAnimation.forward(from: DateTime.now().millisecondsSinceEpoch % (totalDuration.inMilliseconds) / 1000);
    colorAnimation.addListener(() {
      final passedDuration = Duration(milliseconds: (colorAnimation.value * 1000).toInt());
      Color color;
      if (passedDuration > (totalDuration - criticalDuration)) {
        final factor = (totalDuration - passedDuration).inMilliseconds / criticalDuration.inMilliseconds;
        color = criticalColor.mixWith(warningDuration.inMilliseconds < 1 ? defaultColor : warningColor, factor);
      } else if (passedDuration > (totalDuration - warningDuration - criticalDuration)) {
        final factor = (totalDuration - passedDuration - criticalDuration).inMilliseconds / warningDuration.inMilliseconds; // 0-1
        color = warningColor.mixWith(defaultColor, factor);
      } else {
        color = defaultColor;
      }
      final callbackValue = TotpAnimationCallback(
        color,
        (totalDuration.inMilliseconds - passedDuration.inMilliseconds) / 1000,
      );
      callback(callbackValue);

      // Resync every second but do not skip the AnimationStatus.completed
      if (DateTime.now().difference(lastResync).inSeconds > 1 && colorAnimation.value > 0.5) {
        lastResync = DateTime.now();
        colorAnimation.forward(from: DateTime.now().millisecondsSinceEpoch % (totalDuration.inMilliseconds) / 1000);
      }
    });
    return colorAnimation;
  }
}

class TotpAnimationCallback {
  final Color color;
  final double secondsUntilNextOTP;

  TotpAnimationCallback(this.color, this.secondsUntilNextOTP);
}
