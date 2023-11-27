import 'package:flutter/material.dart';

class ErrorlogButton extends StatelessWidget {
  final Function() onPressed;
  final String text;
  const ErrorlogButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      title: LayoutBuilder(builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth * 0.66, maxWidth: constraints.maxWidth),
              child: ElevatedButton(
                onPressed: onPressed,
                child: Text(
                  text,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
