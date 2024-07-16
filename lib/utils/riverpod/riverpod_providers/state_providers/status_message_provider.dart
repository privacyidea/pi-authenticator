import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../logger.dart';

final statusMessageProvider = StateProvider<(String, String?)?>(
  (ref) {
    Logger.info("New statusMessageProvider created", name: 'statusMessageProvider');
    return null;
  },
);
