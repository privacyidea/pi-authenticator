import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ViewWidget extends Widget {
  RouteSettings get routeSettings;
  const ViewWidget({super.key});
}

abstract class StatelessView extends StatelessWidget implements ViewWidget {
  const StatelessView({super.key});
}

abstract class ConsumerView extends ConsumerWidget implements ViewWidget {
  const ConsumerView({super.key});
}

abstract class StatefulView extends StatefulWidget implements ViewWidget {
  const StatefulView({super.key});
}

abstract class ConsumerStatefulView extends ConsumerStatefulWidget implements ViewWidget {
  const ConsumerStatefulView({super.key});
}
