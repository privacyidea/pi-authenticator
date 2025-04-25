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
import 'package:mutex/mutex.dart';

class MutexButton extends StatefulWidget {
  final Future<void> Function()? onPressed;
  final Widget child;
  final ButtonStyle? style;
  const MutexButton({super.key, required this.onPressed, required this.child, this.style});

  @override
  State<MutexButton> createState() => _MutexButtonState();
}

class _MutexButtonState extends State<MutexButton> {
  final m = Mutex();
  late bool isPressable = !m.isLocked && widget.onPressed != null;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(3),
        child: ElevatedButton(
          onPressed: isPressable
              ? () => m.protect(() async {
                    setState(() => isPressable = false);
                    await widget.onPressed!();
                    if (!mounted) return;
                    setState(() => isPressable = true);
                  })
              : null,
          style: widget.style?.merge(Theme.of(context).elevatedButtonTheme.style) ?? Theme.of(context).elevatedButtonTheme.style,
          child: widget.child,
        ),
      );
}
