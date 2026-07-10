/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024-2025 NetKnights GmbH
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

import '../l10n/app_localizations.dart';

class PiTextField extends StatefulWidget {
  final String? labelText;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final AutovalidateMode autovalidateMode;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final bool enabled;
  final String? errorText;

  const PiTextField({
    super.key,
    this.labelText,
    this.onChanged,
    this.controller,
    this.keyboardType,
    this.focusNode,
    this.autofocus = false,
    this.obscureText = false,
    this.autocorrect = false,
    this.enableSuggestions = false,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.enabled = true,
    this.errorText,
  });

  @override
  State<PiTextField> createState() => _PiTextFieldState();
}

class _PiTextFieldState extends State<PiTextField> {
  late bool _obscureText = widget.obscureText;

  @override
  Widget build(BuildContext context) => TextFormField(
    decoration: InputDecoration(
      labelText: widget.labelText,
      errorText: widget.errorText,
      errorMaxLines: 2,
      suffixIcon: widget.obscureText
          ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
              ),
              tooltip: _obscureText
                  ? AppLocalizations.of(context)!.showPassword
                  : AppLocalizations.of(context)!.hidePassword,
              onPressed: widget.enabled
                  ? () => setState(() => _obscureText = !_obscureText)
                  : null,
            )
          : null,
    ),
    onChanged: widget.onChanged,
    controller: widget.controller,
    keyboardType: widget.keyboardType,
    focusNode: widget.focusNode,
    autofocus: widget.autofocus,
    enabled: widget.enabled,
    obscureText: _obscureText,
    autocorrect: widget.autocorrect,
    enableSuggestions: widget.enableSuggestions,
    textInputAction: widget.textInputAction,
    onFieldSubmitted: widget.onFieldSubmitted,
    style: Theme.of(context).textTheme.titleSmall,
    autovalidateMode: widget.autovalidateMode,
    validator: widget.validator,
  );
}
