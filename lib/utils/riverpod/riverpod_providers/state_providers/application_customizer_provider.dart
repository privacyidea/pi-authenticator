import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../customization/application_customization.dart';

/// Only used for the app customizer
final applicationCustomizerProvider = StateProvider<ApplicationCustomization>((ref) {
  return ApplicationCustomization.defaultCustomization;
});
