import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../model/mixins/sortable_mixin.dart';
import '../../../logger.dart';

final draggingSortableProvider = StateProvider<SortableMixin?>(
  (ref) {
    Logger.info("New draggingSortableProvider created", name: 'draggingSortableProvider');
    return null;
  },
  name: 'draggingSortableProvider',
);
