/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

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

import 'dart:async';

import 'package:flutter/material.dart';

/// Text widget that allows obfuscation of its content.
class HideableTextController {
  var _controller = StreamController<bool>.broadcast();

  void show() {
    _controller.add(true);
  }

  void hide() {
    _controller.add(false);
  }

  void listen(void onData(bool event)?, {Function? onError, void onDone()?, bool? cancelOnError}) {
    _controller.stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  void close() {
    _controller.close();
  }
}

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
/// [controller] handles the tap detection on the widget that un-hides the content.
class HideableText extends StatefulWidget {
  final String text;
  final bool hideOnDefault;
  final double textScaleFactor;
  final Duration showDuration;
  final TextStyle? textStyle;
  final bool enabled;
  final String replaceCharacter;
  final bool replaceWhitespaces;
  final HideableTextController? controller;

  const HideableText({
    Key? key,
    required this.text,
    this.hideOnDefault = true,
    this.textScaleFactor = 1.0,
    required this.showDuration,
    this.textStyle,
    this.enabled = true,
    this.replaceCharacter = '\u2022',
    this.replaceWhitespaces = false,
    this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => HideableTextState(isHidden: this.hideOnDefault);
}

class HideableTextState extends State<HideableText> {
  late bool _isHidden;

  HideableTextState({required bool isHidden}) : _isHidden = isHidden;

  @override
  void initState() {
    super.initState();
    widget.controller?.listen((isShown) {
      if (isShown) showText();
    }, cancelOnError: false);
  }

  void showText() {
    if (!widget.enabled || !_isHidden) return;
    if (mounted)
      setState(() {
        _isHidden = false;
      });

    Timer(widget.showDuration, () {
      if (mounted)
        setState(() {
          widget.controller?.hide();
          _isHidden = true;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    Text text = Text(
      _isHidden && widget.enabled ? widget.text.replaceAll(RegExp(widget.replaceWhitespaces ? r'.' : r'[^\s]'), widget.replaceCharacter) : widget.text,
      textScaleFactor: widget.textScaleFactor,
      style: widget.textStyle != null
          ? widget.textStyle!.copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold)
          : TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
    );

    return widget.controller == null
        ? GestureDetector(
            child: text,
            onTap: showText,
          )
        : text;
  }
}

class MenuItemWithIcon extends StatelessWidget {
  final Icon icon;
  final Text text;

  MenuItemWithIcon({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 10),
          child: icon,
        ),
        text,
      ],
    );
  }
}
