import 'dart:ui';

extension ColorExtension on Color {
  Color mixWith(Color other) {
    return Color.fromARGB(
      (alpha + other.alpha) ~/ 2.clamp(0, 255),
      (red + other.red) ~/ 2.clamp(0, 255),
      (green + other.green) ~/ 2.clamp(0, 255),
      (blue + other.blue) ~/ 2.clamp(0, 255),
    );
  }

  Color opposite() {
    return Color.fromARGB(
      alpha,
      255 - red,
      255 - green,
      255 - blue,
    );
  }
}
