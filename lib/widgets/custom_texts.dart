/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2021 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:async';

import 'package:flutter/material.dart';

class HideableText extends StatefulWidget {
  final String text;
  final bool hideOnDefault;
  final double textScaleFactor;
  final Duration hideDuration;
  final TextStyle? textStyle;
  final bool enabled;
  final String replaceCharacter;
  final bool replaceWhitespaces;

  const HideableText(
      {Key? key,
      required this.text,
      this.hideOnDefault = true,
      this.textScaleFactor = 1.0,
      required this.hideDuration,
      this.textStyle,
      this.enabled = true,
      this.replaceCharacter = "\u2022",
      this.replaceWhitespaces = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      HideableTextState(isHidden: this.hideOnDefault);
}

class HideableTextState extends State<HideableText> {
  bool isHidden;

  HideableTextState({required bool isHidden}) : this.isHidden = isHidden;

  void showText() {
    if (!widget.enabled || !isHidden) return;
    setState(() => isHidden = false);
    Timer(widget.hideDuration, () => setState(() => isHidden = true));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text(
        isHidden && widget.enabled
            ? widget.text.replaceAll(
                widget.replaceWhitespaces ? r'.' : r'[^\s]',
                widget.replaceCharacter)
            : widget.text,
        textScaleFactor: widget.textScaleFactor,
        style: widget.textStyle ??
            TextStyle(
              fontFamily: "monospace",
              fontWeight: FontWeight.bold,
            ),
      ),
      onTap: showText,
    );
  }
}
