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

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../model/enums/app_feature.dart';
import '../../../customization/application_customization.dart';

part 'application_customizer_provider.g.dart';

/// Only used for the app customizer
@riverpod
class ApplicationCustomizer extends _$ApplicationCustomizer {
  @override
  Future<ApplicationCustomization> build() async {
    final customization = ApplicationCustomization.defaultCustomization.copyWith(disabledFeatures: AppFeature.values.toSet());
    return customization;
  }

  Future<ApplicationCustomization> setState(ApplicationCustomization newState) async {
    state = AsyncValue.data(newState);
    return newState;
  }

  Future<ApplicationCustomization> updateState(FutureOr<ApplicationCustomization> Function(ApplicationCustomization) updater) async {
    final oldState = await future;
    final newState = await updater(oldState);
    setState(newState);
    return newState;
  }
}
