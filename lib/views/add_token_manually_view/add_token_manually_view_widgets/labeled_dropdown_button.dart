/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2026 NetKnights GmbH
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

import '../../../utils/logger.dart';
import 'add_token_manually_row.dart';

class LabeledDropdownButton<T> extends StatefulWidget {
  final String label;
  final List<T> values;
  final bool enabled;
  final List<String>? valueLabels;
  final ValueNotifier<T?>? valueNotifier;
  final String postFix;

  const LabeledDropdownButton({
    required this.label,
    required this.values,
    this.enabled = true,
    this.valueLabels,
    this.postFix = '',
    super.key,
    required this.valueNotifier,
  });

  @override
  State<LabeledDropdownButton<T>> createState() =>
      _LabeledDropdownButtonState<T>();
}

class _LabeledDropdownButtonState<T> extends State<LabeledDropdownButton<T>> {
  void _setState() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.valueNotifier?.value ??= widget.values.firstOrNull;
    widget.valueNotifier?.addListener(_setState);
  }

  @override
  void dispose() {
    widget.valueNotifier?.removeListener(_setState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dropdown = AddTokenManuallyRow(
      label: widget.label,
      child: DropdownButton<T>(
        value:
            widget.valueNotifier?.value != null &&
                widget.values.contains(widget.valueNotifier!.value)
            ? widget.valueNotifier!.value
            : widget.values.firstOrNull,
        isExpanded: true,
        items: [
          for (var i = 0; i < widget.values.length; i++)
            DropdownMenuItem<T>(
              value: widget.values[i],
              child: Text(
                '${widget.valueLabels != null && i < widget.valueLabels!.length ? widget.valueLabels![i] : widget.values[i].toString()}${widget.postFix.isNotEmpty ? ' ${widget.postFix}' : ''}',
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
        ],
        onChanged: widget.enabled
            ? (T? newValue) {
                if (newValue == null) return;
                Logger.info('DropdownButton onChanged: $newValue');
                widget.valueNotifier?.value = newValue;
              }
            : null, // Disabling the callback also helps with visual state
      ),
    );

    if (widget.enabled) {
      return dropdown;
    }

    // Inline Deactivateable logic: Apply opacity and absorb pointers
    return Opacity(opacity: 0.3, child: AbsorbPointer(child: dropdown));
  }
}
