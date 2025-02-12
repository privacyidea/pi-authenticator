/*
 * privacyIDEA Authenticator
 *
 * Author: Frank Merkel <frank.merkel@netknights.it>
 *
 * Copyright (c) 2025 NetKnights GmbH
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

import '../../../utils/utils.dart';
import '../../enums/token_origin_source_type.dart';
import '../../token_import/token_origin_data.dart';
import '../../tokens/token.dart';
import '../../version.dart';

extension TokenSourceTypeX on TokenOriginSourceType {
  TokenOriginData _toTokenOrigin({
    String data = '',
    String? originName,
    bool? isPrivacyIdeaToken,
    DateTime? createdAt,
    String? creator,
    Version? piServerVersion,
  }) =>
      TokenOriginData(
        source: this,
        data: data,
        appName: originName ?? getCurrentAppName(),
        isPrivacyIdeaToken: isPrivacyIdeaToken,
        createdAt: createdAt ?? DateTime.now(),
        creator: creator,
        piServerVersion: piServerVersion,
      );

  TokenOriginData toTokenOrigin({
    String data = '',
    String? originName,
    bool? isPrivacyIdeaToken,
    DateTime? createdAt,
    String? creator,
    Version? piServerVersion,
  }) =>
      _toTokenOrigin(
        data: data,
        originName: originName,
        isPrivacyIdeaToken: isPrivacyIdeaToken,
        createdAt: createdAt,
        creator: creator,
        piServerVersion: piServerVersion,
      );

  T addOriginToToken<T extends Token>({
    required T token,
    required String data,
    required bool? isPrivacyIdeaToken,
    String? appName,
    DateTime? createdAt,
    String? creator,
    Version? piServerVersion,
  }) =>
      token.copyWith(
          origin: _toTokenOrigin(
        data: data,
        originName: appName,
        isPrivacyIdeaToken: isPrivacyIdeaToken,
        createdAt: createdAt,
        creator: creator,
        piServerVersion: piServerVersion,
      )) as T;
}
