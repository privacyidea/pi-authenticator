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
      children: <Widget>[
        Text(widget.label, style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(
          width: 100,
          child: DropdownButton<T>(
            value: widget.valueNotifier.value,
            isExpanded: true,
            items: widget.values.map<DropdownMenuItem<T>>((T value) {
              return DropdownMenuItem<T>(
                value: value,
                child: Text(
                  '${value is String || value is int || value is double ? value : enumAsString(value!)}'
                  '${widget.postFix}',
                  style: Theme.of(context).textTheme.titleMedium,
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
      ],
    );
  }
}
