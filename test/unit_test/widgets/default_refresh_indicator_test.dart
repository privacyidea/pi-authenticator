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
import 'package:privacyidea_authenticator/utils/logger.dart';
import 'package:privacyidea_authenticator/views/add_token_manually_view/add_token_manually_view_widgets/add_token_manually_row.dart';

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
    required this.valueNotifier,
    this.enabled = true,
    this.valueLabels,
    this.postFix = '',
    super.key,
  });

  @override
  State<LabeledDropdownButton<T>> createState() =>
      _LabeledDropdownButtonState<T>();
}

class _LabeledDropdownButtonState<T> extends State<LabeledDropdownButton<T>> {
  @override
  void initState() {
    super.initState();
    // Ensure an initial value is set
    widget.valueNotifier?.value ??= widget.values.firstOrNull;
    widget.valueNotifier?.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.valueNotifier?.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    // Determine the current value, fallback to first item if current is invalid/null
    final T? currentValue =
        (widget.valueNotifier?.value != null &&
            widget.values.contains(widget.valueNotifier!.value))
        ? widget.valueNotifier!.value
        : widget.values.firstOrNull;

    final Widget dropdown = AddTokenManuallyRow(
      label: widget.label,
      child: DropdownButton<T>(
        value: currentValue,
        isExpanded: true,
        onChanged: widget.enabled ? _handleChanged : null,
        items: _buildMenuItems(context),
      ),
    );

    if (widget.enabled) return dropdown;

    // Apply deactivation style inline
    return Opacity(opacity: 0.3, child: AbsorbPointer(child: dropdown));
  }

  List<DropdownMenuItem<T>> _buildMenuItems(BuildContext context) {
    return widget.values.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;

      // Determine label: Custom label -> toString() -> Postfix
      String itemLabel =
          (widget.valueLabels != null && index < widget.valueLabels!.length)
          ? widget.valueLabels![index]
          : value.toString();

      if (widget.postFix.isNotEmpty) {
        itemLabel = '$itemLabel ${widget.postFix}';
      }

      return DropdownMenuItem<T>(
        value: value,
        child: Text(
          itemLabel,
          style: Theme.of(context).textTheme.bodyMedium,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
      );
    }).toList();
  }

  void _handleChanged(T? newValue) {
    if (newValue == null) return;
    Logger.info('DropdownButton onChanged: $newValue');
    widget.valueNotifier?.value = newValue;
  }
}
