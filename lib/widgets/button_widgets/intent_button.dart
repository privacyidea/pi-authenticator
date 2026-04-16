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
import 'dart:async';

import 'package:flutter/material.dart';

import '../../utils/customization/theme_extentions/app_dimensions.dart';
import '../pi_progress_circle.dart';

extension DialogActionIntentX on ActionIntent {
  int get priority {
    return switch (this) {
      ActionIntent.cancel || ActionIntent.neutral => 1,
      ActionIntent.external => 2,
      ActionIntent.info => 3,
      ActionIntent.confirm || ActionIntent.destructive => 4,
    };
  }
}

enum ActionIntent { confirm, destructive, info, neutral, cancel, external }

class IntentButton extends StatefulWidget {
  final ActionIntent intent;
  final FutureOr<void> Function()? onPressed;
  final Widget child;
  final int delaySeconds;
  final int cooldownMs;
  final bool isLoading;
  final bool _isIconOnly;
  final String? semanticsLabel;
  final double? iconSize;

  const IntentButton({
    super.key,
    required this.intent,
    required this.onPressed,
    required this.child,
    this.delaySeconds = 0,
    this.cooldownMs = 0,
    this.isLoading = false,
    this.semanticsLabel,
  }) : _isIconOnly = false,
       iconSize = null;

  IntentButton.icon({
    super.key,
    required this.intent,
    required this.onPressed,
    required IconData icon,
    this.delaySeconds = 0,
    this.cooldownMs = 0,
    this.isLoading = false,
    this.semanticsLabel,
    this.iconSize,
  }) : _isIconOnly = true,
       child = Icon(icon);

  @override
  State<IntentButton> createState() => _IntentButtonState();
}

class _IntentButtonState extends State<IntentButton>
    with SingleTickerProviderStateMixin {
  bool _isInternalLoading = false;
  bool _isCooldown = false;
  late int _currentDelay;
  late AnimationController _animation;
  Timer? _cooldownTimer;
  Timer? _delayTimer;

  bool get _effectiveLoading => widget.isLoading || _isInternalLoading;

  @override
  void initState() {
    super.initState();
    _currentDelay = widget.delaySeconds;
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (_currentDelay > 0) _startDelayTimer();
  }

  Future<void> _startDelayTimer() async {
    _delayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_currentDelay > 0) {
        setState(() {
          _currentDelay--;
        });
        if (_currentDelay > 0) {
          _animation.forward(from: 0);
        }
      }

      if (_currentDelay <= 0) {
        timer.cancel();
      }
    });

    if (_currentDelay > 0 && mounted) {
      _animation.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _cooldownTimer?.cancel();
    _animation.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    if (widget.onPressed == null ||
        _isCooldown ||
        _effectiveLoading ||
        _currentDelay > 0) {
      return;
    }

    final result = widget.onPressed!.call();
    final isFuture = result is Future;

    if (!isFuture && widget.cooldownMs == 0) return;

    if (mounted) {
      setState(() {
        if (isFuture) _isInternalLoading = true;
        if (widget.cooldownMs > 0) _isCooldown = true;
      });
    }

    if (isFuture) {
      try {
        await result;
      } finally {
        if (mounted) {
          setState(() => _isInternalLoading = false);
        }
      }
    }

    if (widget.cooldownMs > 0) {
      _cooldownTimer?.cancel();
      _cooldownTimer = Timer(Duration(milliseconds: widget.cooldownMs), () {
        if (mounted) {
          setState(() => _isCooldown = false);
        }
      });
    } else {
      if (mounted) {
        setState(() => _isCooldown = false);
      }
    }
  }

  VoidCallback? get _effectiveOnPressed {
    if (widget.onPressed == null || _isCooldown || _effectiveLoading) {
      return null;
    }
    if (_currentDelay > 0) return () {};
    return _handlePress;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimensions =
        theme.extension<AppDimensions>() ?? const AppDimensions();

    Widget button = widget._isIconOnly
        ? _buildIconButton(context, dimensions)
        : _buildStandardButton(context, dimensions);

    if (widget.semanticsLabel != null) {
      return Semantics(label: widget.semanticsLabel, child: button);
    }
    return button;
  }

  Widget _buildStandardButton(BuildContext context, AppDimensions dimensions) {
    return switch (widget.intent) {
      ActionIntent.confirm ||
      ActionIntent.destructive => _buildElevatedButton(context, dimensions),
      ActionIntent.info => _buildOutlinedButton(context, dimensions),
      ActionIntent.neutral ||
      ActionIntent.cancel ||
      ActionIntent.external => _buildTextButton(context, dimensions),
    };
  }

  Widget _buildIconButton(BuildContext context, AppDimensions dimensions) {
    final theme = Theme.of(context);
    final size = widget.iconSize ?? dimensions.iconSizeMedium;

    final Color iconColor = switch (widget.intent) {
      ActionIntent.destructive => theme.colorScheme.error,
      ActionIntent.confirm => theme.colorScheme.primary,
      ActionIntent.info => theme.colorScheme.secondary,
      ActionIntent.external => theme.colorScheme.tertiary,
      ActionIntent.neutral ||
      ActionIntent.cancel => theme.colorScheme.onSurfaceVariant,
    };

    return IconButton(
      onPressed: _effectiveOnPressed,
      iconSize: size,
      color: iconColor,
      disabledColor: theme.colorScheme.onSurface.withValues(alpha: 0.38),
      icon: _buildChildWithStatus(dimensions),
    );
  }

  Widget _buildElevatedButton(BuildContext context, AppDimensions dimensions) {
    final theme = Theme.of(context);
    final isDestructive = widget.intent == ActionIntent.destructive;

    return ElevatedButton(
      onPressed: _effectiveOnPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDestructive ? theme.colorScheme.error : null,
        foregroundColor: isDestructive ? theme.colorScheme.onError : null,
        disabledBackgroundColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.12,
        ),
        disabledForegroundColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.38,
        ),
        minimumSize: Size(dimensions.controlMinWidth, dimensions.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimensions.borderRadius),
        ),
      ),
      child: _buildChildWithStatus(dimensions),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, AppDimensions dimensions) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: _effectiveOnPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(dimensions.controlMinWidth, dimensions.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        disabledForegroundColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.38,
        ),
        side: BorderSide(
          color: _effectiveOnPressed == null
              ? theme.colorScheme.onSurface.withValues(alpha: 0.12)
              : theme.dividerColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimensions.borderRadius),
        ),
      ),
      child: _buildChildWithStatus(dimensions),
    );
  }

  Widget _buildTextButton(BuildContext context, AppDimensions dimensions) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: _effectiveOnPressed,
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurface,
        minimumSize: Size(dimensions.controlMinWidth, dimensions.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        disabledForegroundColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.38,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimensions.borderRadius),
        ),
      ),
      child: widget.intent == ActionIntent.external
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildChildWithStatus(dimensions),
                const SizedBox(width: 4),
                Icon(
                  Icons.open_in_new,
                  size: 16,
                  color: _effectiveOnPressed == null
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                      : theme.colorScheme.onSurface,
                ),
              ],
            )
          : _buildChildWithStatus(dimensions),
    );
  }

  Widget _buildChildWithStatus(AppDimensions dimensions) {
    if (_currentDelay > 0) return _buildCountdownStack(dimensions);
    if (!_effectiveLoading) return widget.child;

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: 0.0, child: widget.child),
        SizedBox(
          width: widget.iconSize ?? dimensions.iconSizeMedium,
          height: widget.iconSize ?? dimensions.iconSizeMedium,
          child: CircularProgressIndicator(strokeWidth: dimensions.strokeWidth),
        ),
      ],
    );
  }

  Widget _buildCountdownStack(AppDimensions dimensions) {
    final size = widget.iconSize ?? dimensions.iconSizeMedium;
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, _) => PiProgressCircle(
              _animation.value,
              strokeWidth: 3,
              swapColors: _currentDelay % 2 == 0,
            ),
          ),
          Text(
            _currentDelay.toString(),
            style: TextStyle(fontSize: size * 0.6, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
