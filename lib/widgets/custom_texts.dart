/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>
           Frank Merkel <frank.merkel@netknights.it>

  Copyright (c) 2017-2023 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the 'License');
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an 'AS IS' BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
import 'package:flutter/material.dart';

/// Text widget that allows obfuscation of its content. This allows to show the
/// content for a specific amount of time before it is hidden.
/// [text] is the un-obfuscated content.
/// If [hideOnDefault] is true, the [text] is obfuscated, if set to false the
/// [text] is visible to the user.
/// [textScaleFactor] mirrors the field of the [Text] widget.
/// [showDuration] specifies how long the [text] should be shown to the user
/// before it is hidden again.
/// [textStyle] mirrors the field of the [Text] widget.
/// If [enabled] is set to true, the widget can be toggled to show its content.
/// [replaceCharacter] defines the character that is shown to the user instead
/// of the real characters in [text].
/// If [replaceWhitespaces] is true, whitespaces in [text] are replaced by
/// [replaceCharacter] too.
/// [isHiddenNotifier] handles the tap detection on the widget that un-hides the content.
class HideableText extends StatelessWidget {
  final String text;
  final bool hideOnDefault;
  final double textScaleFactor;
  final TextStyle? textStyle;
  final bool enabled;
  final String replaceCharacter;
  final bool replaceWhitespaces;
  final ValueNotifier<bool> isHiddenNotifier;

  const HideableText({
    Key? key,
    required this.text,
    required this.isHiddenNotifier,
    this.hideOnDefault = true,
    this.textScaleFactor = 1.0,
    this.textStyle,
    this.enabled = true,
    this.replaceCharacter = '\u2022',
    this.replaceWhitespaces = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      isHiddenNotifier.value && enabled ? text.replaceAll(RegExp(replaceWhitespaces ? r'.' : r'[^\s]'), replaceCharacter) : text,
      textScaleFactor: textScaleFactor,
      style: textStyle != null
          ? textStyle!.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold)
          : TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
    );
  }
}
