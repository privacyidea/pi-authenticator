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
import 'package:privacyidea_authenticator/utils/application_theme_utils.dart';

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

class PasswordInputFormField extends StatefulWidget {
  final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(2), borderSide: BorderSide(width: 2));
  final focusBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 2, color: Colors.grey));
  final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(2),
      borderSide: BorderSide(width: 2, color: Colors.red));
  final focusedErrorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(width: 2, color: Colors.red));

  final FocusNode _focusNode;
  final ValueChanged<String> _onFieldSubmitted;
  final ValueChanged<String> _onChanged;
  final String _labelText;
  final Key _formKey;
  final FormFieldValidator<String> _validator;

  PasswordInputFormField(
      {Key key,
      Key formKey,
      FocusNode focusNode,
      ValueChanged<String> onFieldSubmitted,
      ValueChanged<String> onChanged,
      String labelText,
      FormFieldValidator<String> validator})
      : assert(labelText != null),
        assert(formKey != null),
        _validator = validator,
        _formKey = formKey,
        _labelText = labelText,
        _focusNode = focusNode,
        _onFieldSubmitted = onFieldSubmitted,
        _onChanged = onChanged,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _PasswordInputFormFieldState();
}

class _PasswordInputFormFieldState extends State<PasswordInputFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: _obscureText,
      key: widget._formKey,
      focusNode: widget._focusNode,
      onFieldSubmitted: widget._onFieldSubmitted,
      onChanged: widget._onChanged,
      decoration: InputDecoration(
        suffixIcon: GestureDetector(
          child: Icon(
            Icons.remove_red_eye,
            color: _obscureText
                ? Colors.grey
                : getHighlightColor(isDarkModeOn(context)),
          ),
          onTap: () {
            setState(() => _obscureText = !_obscureText);
          },
        ),
        labelText: widget._labelText,
        border: widget.border,
        focusedBorder: widget.focusBorder,
        errorBorder: widget.errorBorder,
        focusedErrorBorder: widget.focusedErrorBorder,
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter your Password'; // TODO Translate
        } else {
          return widget._validator?.call(value);
        }
      },
    );
  }
}
