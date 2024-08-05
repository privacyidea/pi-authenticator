/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
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

class LabeledDropdownButton<T> extends StatefulWidget {
  final String label;
  final List<T> values;
  final ValueNotifier<T?> valueNotifier;
  final String postFix;
  final Function(T)? onChanged;

  const LabeledDropdownButton({
    required this.label,
    required this.values,
    required this.valueNotifier,
    this.postFix = '',
    this.onChanged,
    super.key,
  });

  @override
  State<LabeledDropdownButton<T>> createState() => _LabeledDropdownButtonState<T>();
}

class _LabeledDropdownButtonState<T> extends State<LabeledDropdownButton<T>> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 5,
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
        Flexible(
          flex: 3,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 100),
            child: DropdownButton<T>(
              value: widget.valueNotifier.value,
              isExpanded: true,
              items: widget.values.map<DropdownMenuItem<T>>((T value) {
                return DropdownMenuItem<T>(
                  value: value,
                  child: Text(
                    '${value is Enum ? value.name : value}'
                    '${widget.postFix}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                );
              }).toList(),
              onChanged: (T? newValue) {
                if (newValue == null) return;
                setState(() {
                  Logger.info('DropdownButton onChanged: $newValue');
                  widget.onChanged?.call(newValue);
                  widget.valueNotifier.value = newValue;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
