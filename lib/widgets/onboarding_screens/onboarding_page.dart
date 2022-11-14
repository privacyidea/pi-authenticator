import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage(
      {Key? key, required, required this.title, required this.subtitle})
      : super(key: key);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 27.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.subtitle1?.color),
        ),
        const SizedBox(height: 40),
        Text(
          subtitle,
          style: TextStyle(
              fontSize: 17.0,
              color: Theme.of(context).textTheme.subtitle1?.color),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
