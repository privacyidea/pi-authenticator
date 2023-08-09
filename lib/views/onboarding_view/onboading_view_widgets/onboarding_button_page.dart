import 'package:flutter/material.dart';

class OnboardingButtonPage extends StatelessWidget {
  const OnboardingButtonPage({Key? key, required, required this.title, required this.subtitle, required this.onPressed, required this.buttonTitle})
      : super(key: key);

  final String title;
  final String subtitle;
  final VoidCallback onPressed;
  final String buttonTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 27.0, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.titleMedium?.color),
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 17.0,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.fade,
              softWrap: false,
            ),
            OutlinedButton(
                onPressed: onPressed,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    buttonTitle,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ))
          ],
        ),
      ],
    );
  }
}
