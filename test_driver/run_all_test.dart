/*
  privacyIDEA Authenticator

  Authors: Timo Sturm <timo.sturm@netknights.it>

  Copyright (c) 2017-2019 NetKnights GmbH

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

// Imports the Flutter Driver API.

import 'test_components/add_token_test.dart';
import 'test_components/copy_to_clipboard_test.dart';
import 'test_components/rename_and_delete_test.dart';
import 'test_components/totp_token_test.dart';

void main() {
  addTokenTest();
  renameAndDeleteTest();
//  totpTokenUpdateTest(); // FIXME This fails because of race-conditions!
  copyToClipboardTest();
}
