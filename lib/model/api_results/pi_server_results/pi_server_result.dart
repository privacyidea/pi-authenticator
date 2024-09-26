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
import 'pi_server_result_error.dart';
import 'pi_server_result_value.dart';

abstract class PiServerResult {
  bool get status;
  PiServerResultError? get asError => this is PiServerResultError ? this as PiServerResultError : null;
  PiServerResultValue? get asValue => this is PiServerResultValue ? this as PiServerResultValue : null;
  const PiServerResult();
}
