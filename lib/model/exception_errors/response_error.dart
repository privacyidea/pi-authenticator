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
import 'package:http/http.dart';

class ResponseError {
  final int _statusCode;
  int get statusCode => _statusCode;
  final String _message;
  String get message => _message.substring(0, _message.length > 100 ? 100 : _message.length);
  String get fullMessage => _message;

  const ResponseError._(int statusCode, String message)
      : _statusCode = statusCode,
        _message = message;
//<title>405 Method Not Allowed</title>
//<title>Method Not Allowed</title>
  factory ResponseError(Response response) {
    assert(response.statusCode != 200, 'Status code of an response error should not be 200');
    final regexpCode = RegExp(r'<title>(\d{3})');
    final regexpMessage = RegExp(r'(?<=(<title>\d* ?))[A-Za-z][A-Za-z\s]*(?=</title>)');
    final message = regexpMessage.firstMatch(response.body)?.group(0) ?? response.body;
    final statusCode = int.tryParse(regexpCode.firstMatch(response.body)?.group(1) ?? response.statusCode.toString()) ?? response.statusCode;
    return ResponseError._(statusCode, message);
  }

  @override
  String toString() {
    return '$statusCode: $message';
  }
}
