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
import '../pi_circular_progress_indicator.dart';

extension DialogActionIntentX on DialogActionIntent {
  int get priority {
    return switch (this) {
      DialogActionIntent.cancel || DialogActionIntent.neutral => 1,
      DialogActionIntent.external => 2,
      DialogActionIntent.info => 3,
      DialogActionIntent.confirm || DialogActionIntent.destructive => 4,
    };
  }
}

enum DialogActionIntent {
  confirm,
  destructive,
  info,
  neutral,
  cancel,
  external,
}

class IntentButton extends StatefulWidget {
  final DialogActionIntent intent;
  final FutureOr<void> Function()? onPressed;
  final Widget child;
  final int delaySeconds;
  final int cooldownMs;

  const IntentButton({
    super.key,
    required this.intent,
    required this.onPressed,
    required this.child,
    this.delaySeconds = 0,
    this.cooldownMs = 0,
  });

  @override
  State<IntentButton> createState() => _IntentButtonState();
}

class _IntentButtonState extends State<IntentButton>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isCooldown = false;
  late int _currentDelay;
  late AnimationController _animation;

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
    while (_currentDelay > 0 && mounted) {
      _animation.forward(from: 0);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _currentDelay--);
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    if (widget.onPressed == null ||
        _isCooldown ||
        _isLoading ||
        _currentDelay > 0)
      return;

    final result = widget.onPressed!.call();
    final isFuture = result is Future;

    if (!isFuture && widget.cooldownMs == 0) return;

    if (mounted) {
      setState(() {
        if (isFuture) _isLoading = true;
        if (widget.cooldownMs > 0) _isCooldown = true;
      });
    }

    final List<Future<dynamic>> tasks = [];
    if (isFuture) tasks.add(result);
    if (widget.cooldownMs > 0) {
      tasks.add(Future.delayed(Duration(milliseconds: widget.cooldownMs)));
    }

    if (tasks.isNotEmpty) {
      await Future.wait(tasks);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isCooldown = false;
      });
    }
  }

  VoidCallback? get _effectiveOnPressed {
    if (widget.onPressed == null || _isCooldown || _isLoading) return null;
    if (_currentDelay > 0) return () {};
    return _handlePress;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimensions =
        theme.extension<AppDimensions>() ?? const AppDimensions();

    return switch (widget.intent) {
      DialogActionIntent.confirm || DialogActionIntent.destructive =>
        _buildElevatedButton(context, dimensions),
      DialogActionIntent.info => _buildOutlinedButton(context, dimensions),
      DialogActionIntent.neutral ||
      DialogActionIntent.cancel ||
      DialogActionIntent.external => _buildTextButton(context, dimensions),
    };
  }

  Widget _buildElevatedButton(BuildContext context, AppDimensions dimensions) {
    final theme = Theme.of(context);
    final isDestructive = widget.intent == DialogActionIntent.destructive;

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
        minimumSize: Size(0, dimensions.controlHeight),
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
        minimumSize: Size(0, dimensions.controlHeight),
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
        minimumSize: Size(0, dimensions.controlHeight),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        disabledForegroundColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.38,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimensions.borderRadius),
        ),
      ),
      child: widget.intent == DialogActionIntent.external
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
    if (!_isLoading) return widget.child;

    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: 0.0, child: widget.child),
        SizedBox(
          width: dimensions.iconSizeMedium,
          height: dimensions.iconSizeMedium,
          child: CircularProgressIndicator(strokeWidth: dimensions.strokeWidth),
        ),
      ],
    );
  }

  Widget _buildCountdownStack(AppDimensions dimensions) {
    return SizedBox(
      height: dimensions.iconSizeMedium,
      width: dimensions.iconSizeMedium,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, _) => PiCircularProgressIndicator(
              _animation.value,
              strokeWidth: 3,
              swapColors: _currentDelay % 2 == 0,
            ),
          ),
          Text(
            _currentDelay.toString(),
            style: TextStyle(
              fontSize: dimensions.spacingMedium * 0.8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
