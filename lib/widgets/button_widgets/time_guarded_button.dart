// /*
//  * privacyIDEA Authenticator
//  *
//  * Author: Frank Merkel <frank.merkel@netknights.it>
//  *
//  * Copyright (c) 2026 NetKnights GmbH
//  *
//  * Licensed under the Apache License, Version 2.0 (the 'License');
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  * http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an 'AS IS' BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */
// import 'dart:async';

// import 'package:flutter/material.dart';

// import '../../utils/customization/theme_extentions/app_dimensions.dart';
// import '../pi_circular_progress_indicator.dart';
// import 'intent_button.dart';

// class IntentButton extends StatefulWidget {
//   final FutureOr<void> Function()? onPressed;
//   final Widget child;
//   final int delaySeconds;
//   final int cooldownMs;
//   final DialogActionIntent intent;

//   const IntentButton({
//     super.key,
//     required this.onPressed,
//     required this.child,
//     this.intent = DialogActionIntent.confirm,
//     this.delaySeconds = 0,
//     this.cooldownMs = 0,
//   });

//   @override
//   State<IntentButton> createState() => _IntentButtonState();
// }

// class _IntentButtonState extends State<IntentButton>
//     with SingleTickerProviderStateMixin {
//   bool _isCooldown = false;
//   late int _currentDelay;
//   late AnimationController _animation;

//   @override
//   void initState() {
//     super.initState();
//     _currentDelay = widget.delaySeconds;
//     _animation = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 1),
//     );
//     if (_currentDelay > 0) _startDelayTimer();
//   }

//   Future<void> _startDelayTimer() async {
//     while (_currentDelay > 0 && mounted) {
//       await Future.wait([
//         _animation.forward(from: 0),
//         Future.delayed(const Duration(seconds: 1)),
//       ]);
//       if (mounted) setState(() => _currentDelay--);
//     }
//   }

//   Future<void> _handlePress() async {
//     if (widget.onPressed == null) return;
//     final result = widget.onPressed!.call();
//     final isFuture = result is Future;
//     if (!isFuture && widget.cooldownMs == 0) return;

//     if (mounted) setState(() => _isCooldown = true);
//     await Future.wait([
//       if (isFuture) result,
//       Future.delayed(Duration(milliseconds: widget.cooldownMs)),
//     ]);
//     if (mounted) setState(() => _isCooldown = false);
//   }

//   @override
//   void dispose() {
//     _animation.dispose();
//     super.dispose();
//   }

//   FutureOr<void> Function()? get effectiveOnPressed {
//     if (widget.onPressed == null || _isCooldown) {
//       return null;
//     }
//     if (_currentDelay > 0) {
//       return () {};
//     }
//     return _handlePress;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dimensions =
//         Theme.of(context).extension<AppDimensions>() ?? const AppDimensions();

//     return IntentButton(
//       intent: widget.intent,
//       onPressed: () async {
//         effectiveOnPressed?.call();
//       },
//       child: _currentDelay > 0
//           ? _buildCountdownStack(dimensions)
//           : widget.child,
//     );
//   }

//   Widget _buildCountdownStack(AppDimensions dimensions) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         AnimatedBuilder(
//           animation: _animation,
//           builder: (context, _) => PiCircularProgressIndicator(
//             size: dimensions.iconSizeMedium,
//             _animation.value,
//             strokeWidth: 3,
//             swapColors: _currentDelay % 2 == 0,
//           ),
//         ),
//         Text(
//           _currentDelay.toString(),
//           style: TextStyle(
//             fontSize: dimensions.spacingMedium * 0.8,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }
// }
