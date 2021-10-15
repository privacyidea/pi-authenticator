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

class HideableTextController {
  var _controller = StreamController<bool>.broadcast();

  void tap() {
    _controller.add(true);
  }

  void listen(void onData(bool event)?,
      {Function? onError, void onDone()?, bool? cancelOnError}) {
    _controller.stream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }

  void close() {
    _controller.close();
  }
}

class HideableText extends StatefulWidget {
  final String text;
  final bool hideOnDefault;
  final double textScaleFactor;
  final Duration hideDuration;
  final TextStyle? textStyle;
  final bool enabled;
  final String replaceCharacter;
  final bool replaceWhitespaces;
  final HideableTextController? controller;

  const HideableText(
      {Key? key,
      required this.text,
      this.hideOnDefault = true,
      this.textScaleFactor = 1.0,
      required this.hideDuration,
      this.textStyle,
      this.enabled = true,
      this.replaceCharacter = "\u2022",
      this.replaceWhitespaces = false,
      this.controller})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      HideableTextState(isHidden: this.hideOnDefault);
}

class HideableTextState extends State<HideableText> {
  late bool _isHidden;

  HideableTextState({required bool isHidden}) : this._isHidden = isHidden;

  @override
  void initState() {
    super.initState();
    widget.controller?.listen((event) => showText(), cancelOnError: false);
  }

  void showText() {
    if (!widget.enabled || !_isHidden) return;
    _isHidden = false;
    if (mounted) setState(() {});

    Timer(widget.hideDuration, () {
      _isHidden = true;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Text text = Text(
      _isHidden && widget.enabled
          ? widget.text.replaceAll(
              RegExp(widget.replaceWhitespaces ? r'.' : r'[^\s]'),
              widget.replaceCharacter)
          : widget.text,
      textScaleFactor: widget.textScaleFactor,
      style: widget.textStyle != null
          ? widget.textStyle!
              .copyWith(fontFamily: 'monospace', fontWeight: FontWeight.bold)
          : TextStyle(
              fontFamily: "monospace",
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
