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

  const HideableText(
      {Key key,
      this.text,
      this.hideOnDefault = true,
      this.hiddenText = "",
      this.textScaleFactor = 1.0,
      this.hideDuration,
      this.textStyle, this.enabled = true})
      : assert(text != null, "text is not an optional parameter."),
        assert(hideDuration != null, "hideDuration is not an optional parameter."),
        assert(textStyle != null, ""),
        super(key: key);

  @override
  State<StatefulWidget> createState() => HideableTextState();
}

class HideableTextState extends State<HideableText> {
  bool isHidden;

  @override
  void initState() {
    isHidden = widget.hideOnDefault;
    super.initState();
  }

  void showOTPValue() {
    setState(() => isHidden = false);
    Timer(widget.hideDuration, () => setState(() => isHidden = true));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text(
        isHidden ? widget.hiddenText : widget.text,
        textScaleFactor: widget.textScaleFactor,
        style: widget.textStyle,
      ),
      onTap: showOTPValue,
    );
  }
}
