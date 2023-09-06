import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({Key? key, required, required this.title, required this.subtitle, this.onPressed, this.buttonTitle}) : super(key: key);

  final String title;
  final String subtitle;
  final VoidCallback? onPressed;
  final String? buttonTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 27.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 17.0,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (onPressed != null && buttonTitle != null)
                OutlinedButton(
                  onPressed: onPressed,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      buttonTitle!,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
