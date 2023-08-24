import 'package:flutter/material.dart';

import '../../../utils/logger.dart';
import '../../../utils/utils.dart';

class LabeledDropdownButton<T> extends StatefulWidget {
  final String label;
  final List<T> values;
  final ValueNotifier<T?> valueNotifier;
  final String postFix;

  const LabeledDropdownButton({
    required this.label,
    required this.values,
    required this.valueNotifier,
    this.postFix = '',
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
                    '${value is Enum ? enumAsString(value) : value}'
                    '${widget.postFix}',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                );
              }).toList(),
              onChanged: (T? newValue) {
                if (newValue == null) return;
                setState(() {
                  Logger.info('DropdownButton onChanged: $newValue');
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
