/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2020 NetKnights GmbH

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
  final String hiddenText;
  final bool hideOnDefault;
  final double textScaleFactor;
  final Duration hideDuration;
  final TextStyle textStyle;
  final bool enabled;

  // TODO Change assertions!
  const HideableText(
      {Key key,
      this.text,
      this.hideOnDefault = true,
      this.hiddenText,
      this.textScaleFactor = 1.0,
      this.hideDuration,
      this.textStyle,
      this.enabled = true})
      : assert(text != null, "text is not an optional parameter."),
        assert(
            hideDuration != null, "hideDuration is not an optional parameter."),
        assert(textStyle != null, ""),
        super(key: key);

  @override
  State<StatefulWidget> createState() =>
      HideableTextState(isHidden: this.hideOnDefault);
}

class HideableTextState extends State<HideableText> {
  bool isHidden;

  HideableTextState({bool isHidden}) : this.isHidden = isHidden;

  void showOTPValue() {
    if (!widget.enabled || !isHidden) return;
    setState(() => isHidden = false);
    Timer(widget.hideDuration, () => setState(() => isHidden = true));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text(
        isHidden && widget.enabled ? widget.hiddenText : widget.text,
        textScaleFactor: widget.textScaleFactor,
        style: widget.textStyle,
      ),
      onTap: showOTPValue,
    );
  }
}
