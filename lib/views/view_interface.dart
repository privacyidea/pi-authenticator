/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2024 NetKnights GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:flutter_riverpod/flutter_riverpod.dart' show WidgetRef;

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
