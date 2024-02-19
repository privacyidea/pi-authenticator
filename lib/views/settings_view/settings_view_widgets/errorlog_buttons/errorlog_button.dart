import 'package:flutter/material.dart';

class ErrorlogButton extends StatelessWidget {
  final Function() onPressed;
  final String text;
  const ErrorlogButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) => ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Flexible(child: SizedBox()),
            Expanded(
              flex: 4,
              child: ElevatedButton(
                onPressed: onPressed,
                child: Text(
                  text,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ),
            ),
            const Flexible(child: SizedBox()),
          ],
        ),
      );
}
