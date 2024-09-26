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
import '../../model/processor_result.dart';
import '../../model/tokens/token.dart';
import '../../utils/object_validator.dart';
import '../../utils/riverpod/riverpod_providers/generated_providers/token_notifier.dart';
import '../scheme_processors/token_import_scheme_processors/google_authenticator_qr_processor.dart';
import '../token_import_file_processor/token_import_file_processor_interface.dart';

mixin TokenImportProcessor<T, V> {
  static const resultHandlerType = ObjectValidator<TokenNotifier>();
  static Set<TokenImportProcessor> implementations = {
    const GoogleAuthenticatorQrProcessor(),
    ...TokenImportFileProcessor.implementations,
  };

  Future<List<ProcessorResult<Token>>?> processTokenMigrate(T data, {V args});
}
